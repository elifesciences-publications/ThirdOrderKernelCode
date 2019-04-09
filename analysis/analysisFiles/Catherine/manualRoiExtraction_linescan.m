function [timeByRois,watershededMean,extraVars] = manualRoiExtraction_linescan(filteredMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
        % function to manually select ROIs for linescan data (the other
        % option is to use watershed, which works okay but not great)
        extraVars = [];
        meanImg = mean(filteredMovie, 3);
        close all
        figure
            
        roiImage = repmat(meanImg, size(meanImg, 2), 1);
        imshow(roiImage/max(roiImage(:)));
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

        num_rois_cell = inputdlg('How many ROIs are there?', 'ROI Count', 1, {'0'}, struct('WindowStyle', 'normal'));
        num_rois_str = num_rois_cell{1};
        num_rois = str2num(num_rois_str);

        %linear ROI
        title(['Select your ROI bounds for the ' num_rois_str ' ROI(s). Select left to right.']);
        [roi_x, roi_y] = ginput(2*num_rois);
        roi_x = round(roi_x);
        
        roi_selection_lines = size(meanImg, 2);
            
       
        ROI.roiMasks = [];

        for i=1:num_rois
            roi_data.points{i} = [roi_x(2*i-1:2*i) [0; 0]; roi_x(2*i:-1:2*i-1) [roi_selection_lines+1; roi_selection_lines+1]; roi_x(2*i-1) 0];
            roi_data.roi_x = roi_x;
            blankMask = logical(zeros(size(roiImage)));
            blankMask(:, roi_x(2*i-1):roi_x(2*i)) = true;
            ROI.roiMasks = cat(3, ROI.roiMasks, blankMask);
        end

        for k = 1:size(ROI.roiMasks, 3)
            newRoiMasks(:, :, k) = ROI.roiMasks(:, :, k)*k;
        end
        watershededMean = sum(newRoiMasks, 3);
        numRois = length(unique(watershededMean))-1;
        
        movieMatrix = reshape(deltaFOverF,[numel(meanImg) size(filteredMovie,3)])';
        
       timeByRois = zeros(size(filteredMovie,3),numRois);
       watershededMean = watershededMean(1, :);
        for rr = 1:numRois
            thisRoiMask = watershededMean == rr;
            thisRoiMask = reshape(thisRoiMask,[1 numel(thisRoiMask)]);
            timeByRois(:,rr) = mean(movieMatrix(:,thisRoiMask),2);
        end
    
end