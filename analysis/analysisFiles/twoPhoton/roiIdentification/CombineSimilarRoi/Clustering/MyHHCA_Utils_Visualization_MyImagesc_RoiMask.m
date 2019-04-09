function MyHHCA_Utils_Visualization_MyImagesc_RoiMask(roiMask)
objectName = unique(roiMask(:));   nColor = length(unique(roiMask(:)));
    for nn = 1:1:nColor
        roiMask(roiMask == objectName(nn)) = nn -1;
    end
    imagesc(roiMask)
end