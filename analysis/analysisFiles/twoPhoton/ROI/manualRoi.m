function [ ROI ] = manualRoi( Z )
% Manual ROI selection for non-linescan images. 
    
    loadFlexibleInputs(Z);

%     figure
%     %A little wonky, but imshow has a bad habit of showing minified images;
%     %we ensure a big image by using imagesc, and then use imshow to create
%     %a well displayed image
%     roiImage = var(Z.grab.imgFrames, 0, 3);
%     nEdges = length(edgeTypes);
%     % Activity image based on PEAK, not average
%     percentileImg = zeros(imgSize(1),imgSize(2),nEdges);
%     percentileDiff = zeros(imgSize(1),imgSize(2),nEdges/2); 
%     for q = 1:nEdges
%         % Grabbing the frames in which the edge types occurred
%         controlEpochInds{q} = getEpochInds(Z, edgeTypes{q});
%         indsCat{q} = [];
%         for r = 1:length(controlEpochInds{q})
%             % indscat contains all the indexes for those frames in linear
%             % form, as opposed to separated into presentations as in
%             % controlEpochInds
%             indsCat{q} = cat(1,indsCat{q},controlEpochInds{q}{r});
%         end
%         for m = 1:imgSize(1)
%             for n = 1:imgSize(2)
%                 % percentileImg will contain the value of the pixel at the
%                 % time point when, if all the time points in the
%                 % presentation of the given edge type were sorted by
%                 % intensity, the intensity value would be the
%                 % percentileThreshold percent of the way through the sorted
%                 % values
%                 
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 percentileThreshold = 0.99;
%                 percentileImg(m,n,q) = percentileThresh( Z.grab.imgFrames(m,n,indsCat{q}),percentileThreshold);
%             end
%         end
%         percentileImg(:,:,q) = percentileImg(:,:,q); % .* Z.grab.windowMask;
%         if mod(q,2) == 0
%             % Percentile diff is the difference between every two epochs
%             percentileDiff(:,:,q/2) = percentileImg(:,:,q-1)-percentileImg(:,:,q);
%         end
%     end
    
    roiImage = Z.params.meanImg;
%     roiImage = sum(percentileDiff, 3);
    imagesc(roiImage);
    colormap(b2r(min(roiImage(:).*Z.grab.windowMask(:)), max(roiImage(:).*Z.grab.windowMask(:))));
%     imshow(roiImage/max(roiImage(:)), 'InitialMagnification', 'fit');

    num_rois_cell = inputdlg('How many ROIs are there?', 'ROI Count', 1, {'0'}, struct('WindowStyle', 'normal'));
    num_rois_str = num_rois_cell{1};
    num_rois = str2num(num_rois_str);

    %linear ROI
    title(['Create a polygon surrounding your ROI for the ' num_rois_str ' ROI(s). Double click twice to finish each one.']);

    %We're gonna store these rois in a cell
    %     roi_data = cell(0);
    for i = 1:num_rois
        [roi_mask x y] = roipoly;
        ROI.roiMasks(:,:,i) = roi_mask;
    end

    title('Choose your polygonal ROI for the background signal. Double click twice when you are done.');
    [roi_mask x_back y_back] = roipoly;
    ROI.roiMasks(:,:,i+1) = roi_mask;
    
end

