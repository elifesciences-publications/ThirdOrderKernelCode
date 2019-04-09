function flyResp = InterpolateHighMotionFrames(flyResp,alignmentData,zoomLevel)
    % First attempt to get rid of data points where there is too much motion

    % ySize = imgSize(2);
    % xSize = imgSize(1);
    % dSize = sqrt(ySize^2 + xSize^2);

    fullShift = sqrt(alignmentData(:, 1).^2 + alignmentData(:, 2).^2);

    micronMovementMax = 5;
    sysConfig = GetSystemConfiguration;
    pixelMotionMax = micronMovementMax * sysConfig.twoPhotonOneXPixelPerMicron * zoomLevel;


    % diffShift = [0 0; diff(alignmentData(:, 1:2))];
    % diffFullShift = sqrt(diffShift(:, 1).^2 + diffShift(:, 2).^2);

    % We're tracking the diffShift here for if the image ends up at a resting
    % state...
    overMovedFrames = fullShift > pixelMotionMax;%(alignmentData(:, 1)>xSize*.1 | alignmentData(:, 1)>ySize*.1 | fullShift > dSize*.1);% & (diffShift(:, 1)>xSize*.1 | diffShift(:, 1)>ySize*.1 | diffFullShift > dSize*.1);

    % response is zeros...
    badFrameBeginInd = find(diff(overMovedFrames)>0);
    badFrameEndInd = find(diff(overMovedFrames)<0)+1;
    
    for ff = 1:length(badFrameBeginInd)-1
        frameRange = (badFrameBeginInd(ff):badFrameEndInd(ff))';
        
        firstFrameForInterp = flyResp(:,:,badFrameBeginInd(ff));
        secondFrameForInterp = flyResp(:,:,badFrameEndInd(ff));
        
        x = [badFrameBeginInd(ff) badFrameEndInd(ff)]';
        v = [reshape(firstFrameForInterp,[1 numel(firstFrameForInterp)]); reshape(secondFrameForInterp,[1 numel(secondFrameForInterp)])];
        xq = (badFrameBeginInd(ff):badFrameEndInd(ff))';
        permutedInterp = permute(interp1(x,v,xq),[3 2 1]);
        interpolatedFrames = reshape(permutedInterp,[size(flyResp,1) size(flyResp,2) length(frameRange)]);
        flyResp(:,:,frameRange) = interpolatedFrames;
    end
end