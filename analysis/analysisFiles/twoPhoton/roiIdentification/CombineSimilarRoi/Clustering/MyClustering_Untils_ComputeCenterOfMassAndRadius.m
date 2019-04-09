function [radius,centerOfMass] = MyClustering_Untils_ComputeCenterOfMassAndRadius(roiMask)
[nPixelVer,nPixelHor,nRoi] = size(roiMask);
centerOfMass = zeros(2,nRoi);
radius = zeros(nRoi,1);
for rr = 1:1:nRoi
roiMaskThis = roiMask(:,:,rr) > 0;
centerOfMass(1,rr) = mean(find(sum(roiMaskThis,2))); % vertical center of mass
centerOfMass(2,rr) = mean(find(sum(roiMaskThis,1))); % horizontal center of mass 
% radius.
% mean distance between center of mass and other pixels.
[indx, indy] = ind2sub([nPixelVer,nPixelHor],find(roiMaskThis(:)));
radius(rr) = mean(sqrt((indx - centerOfMass(1,rr)).^2  + (indy - centerOfMass(2,rr)).^2)); % check this your self. which is different from the size of the.
end
end