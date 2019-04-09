function [deltaFOverF, exponential, A] = CalcDeltaFOverF(movieIn,epochStartTimes,epochDurations,interleaveEpoch,takeSqrt,noTrueInterleave, linescan, byROICall)
% the goal of this function is to fit the movie to an exponential where
% each pixel is p(x,t) = A(x)*exp(tau*t); Tau is the exponential decay over
% time as fit over all pixels. The matrix A is the amplitude of each
% pixel after dividing out exp(tau*t);

if nargin<6
    noTrueInterleave = false;
elseif nargin<5
    takeSqrt = false;
    noTrueInterleave = false;
end
if nargin < 7
    linescan = 0;
end
if nargin < 8
    byROICall = 0;
end

% in this way there is one exponential decay for the whole data set,
% but each pixel fits its own amplitude. The exponential p(x,t) is then
% used as our estimate of fo and the movie is converted to delta F over
% F by subtracting and dividing by p(x,t)
movieSize = size(movieIn);
%% extract the response during the interleave for movie
if noTrueInterleave
    % In this case we calculated DF/F by fitting the time trace on all
    % non-probe stimuli
    earliestStartOfEpochs = cellfun(@(epochStarts) min(epochStarts), epochStartTimes(interleaveEpoch:end));
    startFrame = min(earliestStartOfEpochs);
    latestStartOfEpochs = cellfun(@(epochStarts) max(epochStarts), epochStartTimes(interleaveEpoch:end));
    [lastEpochStartFrame, lastEpoch] = max(latestStartOfEpochs);
    endFrame = lastEpochStartFrame + epochDurations{interleaveEpoch+lastEpoch-1};
    interleaveResp = movieIn(:, :, startFrame:endFrame);
    interleaveLoc = (startFrame:endFrame)';
else
    [interleaveResp,interleaveLoc] = GetMeanResponsesFromMovie(movieIn,epochStartTimes,epochDurations,interleaveEpoch);
end

%% the spatially averaged interleaves will be used to calculate the tau
% for the whole movie
if linescan ~= 1 && byROICall == 0
    spatialAveragedInterleaveResp = reshape(mean(mean(interleaveResp,1),2),[size(interleaveResp,3) 1 1]);
    %         if linescan == 1
    %             spatialAveragedInterleaveResp = interleaveResp';
    %         end
    
    % measure fo by fitting an exponential to the interleaves
    p = polyfit(interleaveLoc,log(spatialAveragedInterleaveResp),1);
    tau = p(1);
    
    %% the temporally averaged interleaves will be used to calculate the
    % amplitude of each pixel
    bleachExp = exp(tau*permute(interleaveLoc,[2 3 1]));
    
    % calculate the exponential amplitude A by averaging over the movie
    % after dividing out the bleaching
    A = mean(bsxfun(@rdivide,interleaveResp,bleachExp),3);
    
    %% calculate deltaFoverF by subtracting and dividing by the exponential
    % evaluate exponential
    t = zeros(1,1,movieSize(3));
    t(1,1,:) = 1:movieSize(3);
    
    % since we cant do the outerproduct of A and bleachExp, repmat the
    % exponetial to the full matrix and bsxfun multiply it with A
    exponential = bsxfun(@times,A,repmat(exp(tau*t),[movieSize(1) movieSize(2) 1]));
    
    if takeSqrt
        deltaFOverF = (movieIn-exponential)./sqrt(exponential);% +4000
    else
        deltaFOverF = (movieIn-exponential)./(exponential);
    end
elseif linescan == 1
    % try something similar to the old code
    interleaveResp = mean(movieIn(:,:,:),2);
    % find the average background subtracted signal
    roi_avg_intensity = interleaveResp;
    if size(roi_avg_intensity, 1) > 1
        roi_avg_intensity = mean(movieIn(:, :, :, 1));
    end
    
    % log that average in order to fit all nonzero/nonnegative values
    % to an exponential
    roi_avg_fit = roi_avg_intensity(:, :);
    log_average = log(roi_avg_fit);
    eval_pts_avg = (1:size(roi_avg_intensity, 3))';
    log_average(roi_avg_fit <= 0) = [];
    log_average = log_average';
    eval_pts_avg(roi_avg_fit <= 0) = [];
    polyfit_average = polyfit(eval_pts_avg, log_average, 1);
    
    % find that exponential's time constant to create the fitted
    % exponential
    tau = polyfit_average(1);
    if tau > 0
        warning(['tau is larger than 0, and the value is ', num2str(tau)]);
        tau = 0;
    end
    eval_pts_fit = (1:size(roi_avg_intensity, 3))';
    exp_fit = exp(tau*eval_pts_fit);
    
    % determine each ROI's amplitude by seeing what multiple of the
    % exponential it is on average
    if size(movieIn, 1) > 1
        exp_fit_amp = repmat(exp_fit, 1, size(movieIn, 1))';
        exp_fit_amp = reshape(exp_fit_amp, size(movieIn, 1), size(movieIn, 2), size(movieIn, 3));
        bgd_sub_amp = movieIn(:, :, :);
        roi_amplitudes = mean(bgd_sub_amp./exp_fit_amp,  3);
        
        % fit an exponential to each ROI
        roi_exp_fit = bsxfun(@times, roi_amplitudes, repmat(exp_fit, 1, size(movieIn, 1))');
        roi_exp_normalized = movieIn-reshape(roi_exp_fit, size(movieIn, 1), size(movieIn, 2), size(movieIn, 3));
        roi_exp_normalized = bsxfun(@rdivide, roi_exp_normalized, reshape(roi_exp_fit, size(movieIn, 1), size(movieIn, 2), size(movieIn, 3)));
        if tau < 0
            deltaFOverF = roi_exp_normalized;
        else
            a = mean(movieIn, 3);
            b = repmat(a, 1, size(movieIn, 3));
            c = reshape(b, size(movieIn, 1), size(movieIn, 2), size(movieIn, 3));
            deltaFOverF = movieIn-c;
            deltaFOverF = bsxfun(@rdivide, deltaFOverF, c);
        end
        exponential = exp_fit_amp;
        A = roi_amplitudes;
    else
        exp_fit_amp = repmat(exp_fit, 1, size(movieIn, 2))';
        exp_fit_amp = reshape(exp_fit_amp, size(movieIn, 1), size(movieIn, 2), size(movieIn, 3));
        bgd_sub_amp = movieIn(:, :, :);
        roi_amplitudes = mean(bgd_sub_amp./exp_fit_amp,  3);
        roi_exp_fit = bsxfun(@times, roi_amplitudes, repmat(exp_fit, 1, size(movieIn, 2)));
        roi_exp_normalized = movieIn-reshape(roi_exp_fit', size(movieIn, 1), size(movieIn, 2), size(movieIn, 3));
        roi_exp_normalized = bsxfun(@rdivide, roi_exp_normalized, reshape(roi_exp_fit', size(movieIn, 1), size(movieIn, 2), size(movieIn, 3)));
        
        
%         if tau < 0
%             deltaFOverF = roi_exp_normalized;
%         else
%             deltaFOverF = movieIn;
%         end
        deltaFOverF = roi_exp_normalized;
        exponential = exp_fit_amp;
        A = roi_amplitudes;
    end
elseif linescan == 0 && byROICall == 1
    low_frequency = 1/20;
    high_frequency = 1000;
    fs = 13.0208;
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

        background_subtracted = squeeze(movieIn)';
        baseline_lowpass_filter_frequency = 0.01;
        baseline_low_pass_filter_freq = 2*baseline_lowpass_filter_frequency/fs;

        %NOTE the padding: we're taking the median along the entire stimulus
        %run because unless this neuron spends more time depolarized than not,
        %that should be a valid point of zero.
        padding_beginning = repmat(median(background_subtracted(:, :)), round(fs/baseline_lowpass_filter_frequency), 1);
        padding_end = repmat(median(background_subtracted(:, :)), round(fs/baseline_lowpass_filter_frequency), 1);
        backgroundSubtractedPadded = [padding_beginning; background_subtracted; padding_end];

        [bl_z,bl_p,bl_k] = butter(2, baseline_low_pass_filter_freq, 'low');
        [bl_sos, bl_g] = zp2sos(bl_z,bl_p,bl_k);

        % We don't particularly care for the SOS matrix warning, cuz we
        % kinda know it
        warning('off', 'signal:filtfilt:ParseSOS');
        low_pass_overall_signal = filtfilt(bl_sos, bl_g, backgroundSubtractedPadded);
        roi_avg_intensity_filtered=filtfilt(sos,g,backgroundSubtractedPadded);
        warning('on', 'signal:filtfilt:ParseSOS');

        %Get rid of that padding!
        low_pass_overall_signal(1:length(padding_beginning),:) = [];
        low_pass_overall_signal(end-length(padding_end)+1:end, :) = [];
        roi_avg_intensity_filtered(1:length(padding_beginning),:) = [];
        roi_avg_intensity_filtered(end-length(padding_end)+1:end,:) = [];

        roi_avg_intensity = mean(background_subtracted, 2)-min(background_subtracted(:));
        if any(roi_avg_intensity==0)
            disp('Note! Trying to get rid of 0 values in the roi_avg_intensity that will get in the way of the baseline signal calculation.');
            zeroValIndexes = find(roi_avg_intensity==0);
            zeroValIndexesDist = diff(zeroValIndexes);
            for i = length(zeroValIndexes):-1:1
                if i > length(zeroValIndexes)
                    % You might think we'd never get in here, but there are
                    % while loops on below that get rid of more
                    % zeroValIndexes indexes and might cause this cleverly
                    % designed backwards for loop to still fail.
                    continue;
                end
                if zeroValIndexes(i) == length(roi_avg_intensity)
                    diffInd = i-1;
                    replaceInds = zeroValIndexes(i);
                    zeroValIndexes(i) = [];
                    while diffInd ~= 0 && zeroValIndexesDist(diffInd) == 1 %this will break if your data is only one point >.>
                        replaceInds = [replaceInds zeroValIndexes(diffInd)];
                        zeroValIndexes(diffInd) = [];
                        diffInd = diffInd - 1;
                        if diffInd == 0
                            if replaceInds(end)==1
                                error('No way about it, your background signal doesn''t exist!');
                            else
                                break;
                            end
                        end
                    end
                    roi_avg_intensity(replaceInds) = roi_avg_intensity(replaceInds(end)-1);
                else
                    boundaryEnd = zeroValIndexes(i) + 1;
                    diffInd = i-1;
                    replaceInds = zeroValIndexes(i);
                    zeroValIndexes(i) = [];
                    while diffInd ~= 0 && zeroValIndexesDist(diffInd) == 1
                        replaceInds = [replaceInds zeroValIndexes(diffInd)]
                        zeroValIndexes(diffInd) = [];
                        diffInd = diffInd - 1;
                        if diffInd==0
                            break;
                        end
                    end
                    if replaceInds(end)==1
                        boundaryStart = boundaryEnd;
                    else
                        boundaryStart = replaceInds(end)-1;
                    end
                    roi_avg_intensity(replaceInds) = mean(roi_avg_intensity([boundaryStart, boundaryEnd]));
                end
            end
        end
        log_average = log(roi_avg_intensity);



        eval_pts = (1:length(log_average))';
        polyfit_average = polyfit(eval_pts, log_average, 1);
        low_pass_overall_signal = exp(polyval(polyfit_average, eval_pts));
        low_pass_overall_signal = repmat(low_pass_overall_signal, [1, size(background_subtracted, 2)]);

        % roi_avg_intensity_filtered_normalized includes the roi_avg_intensity
        % as the first entry! Often you'll likely only want cols >1
        roi_avg_intensity_filtered_normalized = roi_avg_intensity_filtered./low_pass_overall_signal;
%         roi_avg_intensity_filtered_normalized = background_subtracted./low_pass_overall_signal-1;
        deltaFOverF = roi_avg_intensity_filtered_normalized';
        exponential = exp(polyval(polyfit_average, eval_pts));
        A = roi_avg_intensity_filtered;

end


end