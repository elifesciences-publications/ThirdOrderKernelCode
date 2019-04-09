function [ Z ] = mapsToRoiData( Z )
% Intakes a set of binary masks for regions of interest, outputs their time
% traces, appends a background region, and puts in proper format for
% downstream twoPhotonAnalyzer. This assumes that the background mask is
% the last slice in roiMasks
    diffProjMovie = false;

    loadFlexibleInputs(Z)
    
    % Grab movie
    try
        inMovie = Z.grab.imgFrames;
    catch err
        if strcmp(err.identifier, 'MATLAB:nonExistentField');
            [Z.grab.imgFrames, ~, ~, ~] = twoPhotonImageParser(Z);
            inMovie = Z.grab.imgFrames;
        end
    end
    % Delete imgFrames; save movie average
    Z.rawTraces.movieMean = mean(Z.grab.imgFrames,3);
    Z.grab = rmfield(Z.grab,'imgFrames');
    
    if Z.params.linescan
        %Take the mean across the line for the ROI
%             roi_points = [roi_data.points{:}];
%             %This indexing looks random. It works :D
%             roi_x = roi_points(1:2, 1:2:end);
%             roi_x = roi_x(:);
            roiMasks = Z.ROI.roiMasks;
            imgSize = size(inMovie);
            
            roiMasks = repmat(roiMasks, [imgSize(3)*imgSize(1)/size(roiMasks, 1), 1,  1]);
            
            intensity = zeros(imgSize(1)*imgSize(3), imgSize(2));

            %We're grabbing each pixel of the line individually and plotting it
            %down! (Probably gonna change this to an ROI at some point)
            for i = 1:size(inMovie, 2)
                intensity(:, i) = reshape(inMovie(:, i, :), [imgSize(1)*imgSize(3), 1]);
            end
            
            for i = 1:size(roiMasks, 3) 
                roi_intensities(:, i) = sum(intensity.*roiMasks(:, :, i), 2)/sum(roiMasks(1,:,i));
            end
            
            %Don't include the background
            roi_avg_intensity = mean(roi_intensities(:, 1:end-1), 2);
            
            Z.rawTraces.roi_intensities = roi_intensities(:,1:end-1);
            Z.rawTraces.bkgd_intensity = roi_intensities(:,end);
            Z.rawTraces.roi_avg_intensity = roi_avg_intensity;
    else
        bgMethod = 'mask';
        percentileLevel = .1;
        roiMasks = Z.ROI.roiMasks;
        nMaps = size(roiMasks,3);
       
        loadFlexibleInputs(Z)
        
        if diffProjMovie
            inMovie = differentialImageProject( inMovie, Z.diffEp.differentialImages, 0, 0 );
        end
        
        % Roll up ROI masks
        for q = 1:nMaps
            thisMap =  roiMasks(:,:,q);
            maskRoll(:,q) = thisMap(:) / sum(thisMap(:));
        end
        
        % extract traces
        nFrames = size(inMovie,3);
        for q = 1:nFrames
            thisFrame = inMovie(:,:,q);
            movRoll(:,q) = thisFrame(:);
        end
        allTraces = movRoll'*maskRoll;
        roi_avg_intensity = mean(allTraces(:, 1:end-1), 2);
        
        % output trace formating
        Z.rawTraces.roi_intensities = allTraces(:,1:end-1);
        Z.rawTraces.roi_avg_intensity = roi_avg_intensity;
        
        % create background trace
        switch bgMethod
            case 'mask'
                Z.rawTraces.bkgd_intensity = allTraces(:,end);
            case 'percentile'
                for q = 1:size(inMovie,3)
                    thisFrame = inMovie(:,:,q);
                    Z.rawTraces.bkgd_intensity(q,1) = percentileThresh(thisFrame(:),percentileLevel);
                end
            case 'none'
                Z.rawTraces.bkgd_intensity = zeros(size(allTraces,1),1);
        end        
    end
    
%     Z.grab = rmfield(Z.grab,'imgFrames');
    fprintf('Raw traces created.\n'); toc
    
end

