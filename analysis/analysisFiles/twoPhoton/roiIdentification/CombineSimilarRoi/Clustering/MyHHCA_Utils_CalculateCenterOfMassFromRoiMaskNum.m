function centerOfMass = MyHHCA_Utils_CalculateCenterOfMassFromRoiMaskNum(roiMask,objName)
N = length(objName);
centerOfMass = zeros(2,N);
[nPixelVer,nPixelHor] = size(roiMask);
for nn = 1:1:N
    [indx,indy] = ind2sub([nPixelVer,nPixelHor],find(roiMask == objName(nn)));
    centerOfMass(1,nn) = mean(indx); centerOfMass(2,nn) = mean(indy);
end
% it is indexed by number...
end