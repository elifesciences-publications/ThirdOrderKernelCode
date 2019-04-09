function movieDFOVERF = ICA_DFOVERF_Utils_DFOVERFTraceToMovie(roiMask,normTraces)
    [nVer,nHor,~] = size(roiMask);
    nFrames = size(normTraces,1);
    movieDFOVERF = zeros(nVer,nHor,nFrames);
    nRoi = size(roiMask,3);
    nRoi = nRoi - 1; % the last one is the background.
    % for loop or multiplication.
    for rr = 1:1:nRoi
        [subI, subJ] = ind2sub([nVer,nHor],find(roiMask(:,:,rr) == 1));
        movieDFOVERF(subI, subJ,:) = normTraces(:,rr);
    end
end