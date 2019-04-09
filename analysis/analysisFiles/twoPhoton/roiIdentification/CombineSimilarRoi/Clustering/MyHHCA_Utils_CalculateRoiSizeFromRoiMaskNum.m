function roiSize = MyHHCA_Utils_CalculateRoiSizeFromRoiMaskNum(roiMask, objName)
N = length(objName);
roiSize = zeros(N,1);
for nn = 1:1:N
    roiSize(nn) = sum(sum(roiMask == objName(nn)));
end

end
