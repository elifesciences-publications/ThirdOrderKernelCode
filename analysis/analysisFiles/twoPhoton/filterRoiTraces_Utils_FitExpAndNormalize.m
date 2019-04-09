function [roi_avg_intensity_filtered_normalized, roi_exp_fit] = filterRoiTraces_Utils_FitExpAndNormalize(baseline_roi_intensities,roi_avg_intensity_for_fitting_fnaught,firstFittingTimePoint, lastFittingTimePoint)

  % Find the average background subtracted signal
    roi_avg_intensity = mean(roi_avg_intensity_for_fitting_fnaught, 2);%-min(roi_avg_intensity_for_fitting_fnaught(:));
    
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
    if tau > 0
        tau = 0;
    end
    
    eval_pts_fit = (1:size(roi_avg_intensity, 1))';
    exp_fit = exp(tau*eval_pts_fit);
    
    % Determine each ROI's amplitudes by seeing what multiple of the
    % exponential it is on average %% is this true?
    exp_fit_amp = exp_fit(firstFittingTimePoint:lastFittingTimePoint);
    bgd_sub_amp = roi_avg_intensity_for_fitting_fnaught(firstFittingTimePoint:lastFittingTimePoint, :);
    roi_amplitudes = mean(bgd_sub_amp./repmat(exp_fit_amp,  [1, size(roi_avg_intensity_for_fitting_fnaught, 2)]));
    
    % Fit an exponential to each ROI--this is \bar{F}
    roi_exp_fit = bsxfun(@times, roi_amplitudes, repmat(exp_fit, [1, size(roi_avg_intensity_for_fitting_fnaught, 2)]));
    
    % Calculate F - \bar{F}
    roi_exp_normalized = baseline_roi_intensities - roi_exp_fit;
    
    
    % Now calculated (F-\bar{F})/\bar{F}--note that the variable is
    % named kinda wrong here, but as it's saved in Z this name has to
    % remain unchanged otherwise problems percolate across the system
    roi_avg_intensity_filtered_normalized = bsxfun(@rdivide, roi_exp_normalized, roi_exp_fit);
end