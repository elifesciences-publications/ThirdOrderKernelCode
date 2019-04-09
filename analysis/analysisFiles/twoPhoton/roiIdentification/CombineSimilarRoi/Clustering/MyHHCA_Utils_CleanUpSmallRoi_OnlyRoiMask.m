function roiMask =  MyHHCA_Utils_CleanUpSmallRoi_OnlyRoiMask(roiMask,minRoiCleanUpSize)
    objName = unique(roiMask(:)); objName(objName == 0) = [];
    nRoi = length(objName);
    for rr = 1:1:nRoi
        if sum(sum(roiMask == objName(rr))) <= minRoiCleanUpSize
            roiMask(roiMask == objName(rr)) = 0;
        end
    end
    
end