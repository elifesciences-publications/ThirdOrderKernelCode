function roiMaskNumber = CombineSameRoi_Clustering_Visualization_Utils_CombineRoiMasks(roiMaskNumber,clusteredObject, nameOfNewObject)
% from there, you know how the first will to go the next.
% find the combined two...

objCombined = clusteredObject.which;
objNameArray = clusteredObject.objectName;
objIndex1 = find( objNameArray == objCombined(1));objIndex2 = find( objNameArray == objCombined(2));
% rember those two, 
roiMaskCombine = roiMaskNumber(:,:,objIndex1) > 0  | roiMaskNumber(:,:,objIndex2) > 0;
roiMaskNumber(:,:,[objIndex1;objIndex2]) = [];
roiMaskNumber = cat(3,roiMaskNumber,roiMaskCombine.* nameOfNewObject);


end