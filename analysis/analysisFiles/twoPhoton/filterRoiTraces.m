function [ Z ] = filterRoiTraces( Z )
% Subtract background trace, convert ot delta f over f, filter.

    rawTraceFields = fieldnames(Z.rawTraces);
    for ii = 1:length(rawTraceFields)
        eval([rawTraceFields{ii} ' = Z.rawTraces.' rawTraceFields{ii} ';']);
    end

    loadFlexibleInputs(Z)

    if filterTraces && ~isempty(roi_intensities)
        low_freq = 2*low_frequency/fs;
        high_freq = 2*high_frequency/fs;
        if low_freq <= 0
            [z,p,k] = butter(2, high_freq, 'low');
            [sos, g] = zp2sos(z,p,k);
        elseif high_freq >= 1
            [z,p,k] = butter(2, low_freq, 'high');
            [sos, g] = zp2sos(z,p,k);
        else
            [z,p,k] = butter(2, [low_freq high_freq]);
            [sos, g] = zp2sos(z,p,k);
        end

%         background_subtracted = [roi_avg_intensity roi_intensities]-repmat(bkgd_intensity, [1 1+size(roi_intensities,2)]);
        if all(isnan(bkgd_intensity))
            bkgd_intensity = zeros(length(bkgd_intensity), 1);
        end
        background_subtracted = roi_intensities-repmat(bkgd_intensity, [1 size(roi_intensities,2)]);

        
        % We fit to the flicker which we know is there if there's only an
        % epoch 13 available past the probe...
        if ~isfield(Z.params.trigger_inds, sprintf('epoch_%d', length(Z.stimulus.probeParams{1})+2))
            firstFittingTimePoint = round(Z.params.trigger_inds.epoch_13.bounds(1));
            lastFittingTimePoint = round(Z.params.trigger_inds.epoch_13.bounds(2));
        else
            firstFittingTimePoint = 1;
            lastFittingTimePoint = size(roi_avg_intensity, 1);
        end


        % Find the average background subtracted signal
        roi_avg_intensity = mean(background_subtracted, 2);%-min(background_subtracted(:));
       
        % Log that average in order to fit all nonzero/nonnegative values
        % to an exponential
        roi_avg_fit = roi_avg_intensity(firstFittingTimePoint:lastFittingTimePoint, :);
        log_average = log(roi_avg_fit);
        eval_pts_avg = (firstFittingTimePoint:lastFittingTimePoint)';
        log_average(roi_avg_fit<=0) = [];
        eval_pts_avg(roi_avg_fit<=0) = [];
        polyfit_average = polyfit(eval_pts_avg, log_average, 1);
        
        % Find that exponential's time constant to create the fitted
        % exponential
        tau = polyfit_average(1);
        eval_pts_fit = (1:size(roi_avg_intensity, 1))';
        exp_fit = exp(tau*eval_pts_fit);
        
        % Determine each ROI's amplitudes by seeing what multiple of the
        % exponential it is on average
        exp_fit_amp = exp_fit(firstFittingTimePoint:lastFittingTimePoint);
        bgd_sub_amp = background_subtracted(firstFittingTimePoint:lastFittingTimePoint, :);
        roi_amplitudes = mean(bgd_sub_amp./repmat(exp_fit_amp,  [1, size(background_subtracted, 2)]));
        
        % Fit an exponential to each ROI--this is \bar{F}
        roi_exp_fit = bsxfun(@times, roi_amplitudes, repmat(exp_fit, [1, size(background_subtracted, 2)]));
        
        % Calculate F - \bar{F}
        roi_exp_normalized = background_subtracted-roi_exp_fit;

        
        % Now calculated (F-\bar{F})/\bar{F}--note that the variable is
        % named kinda wrong here, but as it's saved in Z this name has to
        % remain unchanged otherwise problems percolate across the system
        roi_avg_intensity_filtered_normalized = bsxfun(@rdivide, roi_exp_normalized, roi_exp_fit);
        
%         MakeFigure;
%         subplot(221)
%         plot(bkgd_intensity);
%         title('bkgd intensity');
%         subplot(222)
%         plot(roi_avg_intensity);
%         title('after bkgd subtraction, before df/t');
%         subplot(223)
%         plot(mean(roi_exp_normalized,2));
%         title('average df/f')
%         subplot(224)
%         plot(exp_fit);
%         title('exponential fitting only on the white noise');
        
    else
%         roi_avg_intensity_filtered_normalized=[roi_avg_intensity roi_intensities];
%         Getting rid of appending average as first ROI
        roi_avg_intensity_filtered_normalized = roi_intensities;
        roi_avg_intensity_filtered_normalized = roi_avg_intensity_filtered_normalized - repmat(mean(roi_avg_intensity_filtered_normalized), size(roi_avg_intensity_filtered_normalized, 1), 1);
    end

%     Z.filtered.roi_avg_intensity_filtered = roi_avg_intensity_filtered;
    Z.filtered.roi_avg_intensity_filtered_normalized = roi_avg_intensity_filtered_normalized;
%    Z.ROI.roiIndsOfInterest = extractROIsBySelectivity(Z);
    
    fprintf('Traces filtered.\n'); 
    
end

