function roiMask = ICA_DFOVERF_Utils_CreatePixelRoiMask(windowMask,bkgdMask)
    [nVer,nHor] = size(windowMask);
    nRoi = sum(windowMask(:));
    roiNum = find(windowMask == 1);
    [subI,subJ] = ind2sub([nVer,nHor],roiNum );
    % create a huge windowMask...
    roiMask = false(nVer,nHor,nRoi);
    for rr = 1:1:nRoi
        roiMask(subI(rr),subJ(rr),rr) = true;
    end
    roiMask = cat(3,roiMask,bkgdMask);
end