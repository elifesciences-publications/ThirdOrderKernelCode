function ROI = diffRoi( Z )
% Creates one foreground ROI that is the difference between the direction
% selectivities of the left and right epochs
    
    if ~isfield('Z','diffEp')
        load([Z.params.filename(1:end-3) 'mat'],'imgFrames_ch1');
        Z.grab.imgFrames = imgFrames_ch1;
        clear imgFrames_ch1;
    	Z = diffEp(Z);
    end
    dirThresh = .99;
	loadFlexibleInputs(Z)
    
    threshL = percentileThresh(Z.diffEp.differentialImages(:,:,1),dirThresh);
    fgL = Z.diffEp.differentialImages(:,:,1) > threshL;
    fgL = fgL .* Z.grab.windowMask;
    threshR = percentileThresh(Z.diffEp.differentialImages(:,:,2),dirThresh);
    fgR = abs(Z.diffEp.differentialImages(:,:,2)) > threshR;
    fgR = fgR .* Z.grab.windowMask;
    
%     bgMask = 1 - (fgR + fgL);
    bgMask = zeros(size(fgR));
    bgMask(end-49:end,end-49:end) = 1;
    bgMask = bgMask .* Z.grab.windowMask;
%     bgMask = max(abs(fgMask(:))) - abs(fgMask);
%     bgMask = bgMask .* Z.grab.windowMask;
%     bgMask = bgM
    figure; 
    subplot(2,1,1); imagesc(fgL-fgR);
    subplot(2,1,2); imagesc(bgMask);
    
    ROI.roiMasks = cat(3,fgL,fgR);
    ROI.roiMasks = cat(3,ROI.roiMasks,bgMask);

end

