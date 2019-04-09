function centerOfMass = MyClustering_Untils_ComputeCenterOfMass(roiMask)
nRoi = size(roiMask,3);
centerOfMass = zeros(2,nRoi);
for rr = 1:1:nRoi
roiMaskThis = roiMask(:,:,rr) > 0;
centerOfMass(1,rr) = mean(find(sum(roiMaskThis,2))); % vertical center of mass
centerOfMass(2,rr) = mean(find(sum(roiMaskThis,1))); % horizontal center of mass 
end
end