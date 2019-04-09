function ROI = diffRoiPix( Z )
% Creates one foreground ROI that is the difference between the direction
% selectivities of the left and right epochs

    dirThresh = .95;
	loadFlexibleInputs(Z)
    threshL = percentileThresh(Z.diffEp.differentialImages(:,:,1),dirThresh);
    fgL = Z.diffEp.differentialImages(:,:,1) > threshL;
    fgL = fgL .* Z.grab.windowMask;
    threshR = percentileThresh(Z.diffEp.differentialImages(:,:,2),dirThresh);
    fgR = abs(Z.diffEp.differentialImages(:,:,2)) > threshR;
    fgR = fgR .* Z.grab.windowMask;
  
    lMasks = find(fgL(:) > 0);
    rMasks = find(fgR(:) > 0);
    allMasks = [lMasks; rMasks];
    
    for q = 1:length(allMasks)
        thisMap = zeros(imgSize(1),imgSize(2));
        thisMap = thisMap(:);
        thisMap(allMasks(q)) = 1;
        ROI.roiMasks(:,:,q) = reshape(thisMap,imgSize(1),imgSize(2));
    end
    
    bgMask = 1 - (fgR + fgL);
    
%     figure; 
%     subplot(2,1,1); imagesc(fgL-fgR);
%     subplot(2,1,2); imagesc(bgMask);
%     
%     ROI.roiMasks = cat(3,fgL,fgR);

    figure; imagesc(sum(ROI.roiMasks,3));
    ROI.roiMasks = cat(3,ROI.roiMasks,bgMask);

end

