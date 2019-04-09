function [timeByRoisOut,roiMaskOut] = RoiSelectionSizeAndResp(timeByRois,roiMask,epochStartTimes,epochDurations,epochsForSelectivity,params,varargin)
    sizeMin = 3;
    sizeMax = inf;
    epochRespPercentThreshold = 70;
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    numRoiExtractions = size(epochsForSelectivity,1);
    timeByRoisOut = cell(numRoiExtractions,1);
    roiMaskOut = cell(numRoiExtractions,1);
    numEpochComparisons = size(epochsForSelectivity,2)/2;
    
    if mod(size(epochsForSelectivity,2),2)~=0
        error('epochsForSelectivity must have an even number of epochs');
    end
    
    %% loop through the different ROI selections
    for ex = 1:numRoiExtractions;
        numRoisInitial = size(timeByRois,2);

        %% ROI selection methods
        % Get rid of ROIs that are too big or too small
        roisSelectedBySize = SelectRoisBySize(timeByRois,roiMask,[sizeMin sizeMax]);

        % select Rois by epoch response
        roisSelectedByEpochResponse = false(numEpochComparisons,numRoisInitial);
        for ss = 1:numEpochComparisons
            % calculate direction selective index
            roisSelectedByEpochResponse(ss,:) = SelectRoisByFourierResponse(timeByRois,roiMask,epochStartTimes,epochDurations,epochsForSelectivity(ex,2*ss-1:2*ss),params,epochRespPercentThreshold);
        end
        
        % combine all the selection methods (and operation by
        % multiplication
        selectedRois = logical(prod([roisSelectedBySize; roisSelectedByEpochResponse;],1));

        %% remove ROIs that were not selected and generate the new roiMask
        % extract the ROIs we selected
        timeByRoisOut{ex} = timeByRois(:,selectedRois);

        % create the new ROI mask
        roiMaskOut{ex} = zeros(size(roiMask));
        newRoiIndex = 0;

        for rr = 1:numRoisInitial
            if selectedRois(rr)
                newRoiIndex = newRoiIndex + 1;
                roiMaskOut{ex}(roiMask==rr) = newRoiIndex;
            end
        end

        MakeFigure;
        imagesc(roiMaskOut{ex});
        ConfAxis('fTitle','selected ROIs');
        colorbar;
    end
end