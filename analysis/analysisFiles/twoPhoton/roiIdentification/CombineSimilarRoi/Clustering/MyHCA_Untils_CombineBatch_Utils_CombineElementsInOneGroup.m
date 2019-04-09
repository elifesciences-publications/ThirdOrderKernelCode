function [whichCombined,edgeTraceCombine,centerOfMassCombine,roiMaskCombineWindow] = MyHCA_Untils_CombineBatch_Utils_CombineElementsInOneGroup(obj,objectName,edgeTrace,roiMaskWindow)
% nObj = length(obj);
whichCombined = objectName(obj);
% roiMaskIs a little bit complicated. expand it to large guy?
roiMaskCombineWindow = roiMaskWindow(:,:,obj); % you would add them together and larger than 0. % i
objSize = squeeze(sum(sum(roiMaskCombineWindow,1),2));
roiMaskCombineWindow = sum(roiMaskCombineWindow,3) > 0;
edgeTraceCombine = sum(bsxfun(@times,edgeTrace(:,obj),objSize'),2)/sum(objSize);
centerOfMassCombine = MyClustering_Untils_ComputeCenterOfMass(roiMaskCombineWindow);

end