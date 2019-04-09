function [edgeTrace,roiMask,centerOfMass,corrMat,distMat,objectName,whichCombined] = MyHCA_Untils_CombineNearest(edgeTrace,roiMask,centerOfMass,corrMat,distMat,objectName,newObjectName,lambda)

[ob1,ob2] = MyHCA_Untils_CombineNearest_Utils_ChooseTwo(corrMat,distMat,lambda); % you might need other conditions in the future;
whichCombined = objectName([ob1;ob2]);

% first, recalculate the roiMask and centerOfMass;
roiMaskOb1 = roiMask(:,:,ob1);
roiMaskOb2 = roiMask(:,:,ob2);
roiMaskNew = roiMaskOb1 | roiMaskOb2;
centerOfMassNew = MyClustering_Untils_ComputeCenterOfMass(roiMaskNew);

% second, recalculate the edgeTrace;
ob1Size = sum(roiMaskOb1(:));
ob2Size = sum(roiMaskOb2(:));
edgeTraceOb1 = edgeTrace(:,ob1);
edgeTraceOb2 = edgeTrace(:,ob2);
edgeTraceNew = (edgeTraceOb1 * ob1Size + edgeTraceOb2 * ob2Size )/(ob1Size + ob2Size );

% rearrange roiMask, centerOfMass, and edgeTrace;
roiMask(:,:,[ob1,ob2]) = [];
centerOfMass(:,[ob1,ob2]) = [];
edgeTrace(:,[ob1,ob2]) = [];
corrMat([ob1,ob2],:) = [];corrMat(:,[ob1,ob2]) = [];
distMat([ob1,ob2],:) = [];distMat(:,[ob1,ob2]) = [];

% recalucalte correlation and distance. test which is faster later on.
% this one is too slow...
corrNew = MyLoop_ArrayByArray(@corr,edgeTrace,edgeTraceNew);
distNew = MyLoop_ArrayByArray(@(x,y)sqrt(sum((x -y).^2)),centerOfMass,centerOfMassNew);
% recalculate correlation and distance.
%     corrNew = zeros(size(roiMask,3),1);
% tic
% corrNew = MyBsxFun_ArrayByArray(@corr,edgeTrace,edgeTraceNew);
% distNew = MyBsxFun_ArrayByArray(@(x,y)sqrt(sum((x -y).^2)),centerOfMass,centerOfMassNew);
% toc% decide later which is faster later....
% tic
% corrNewLoop = zeros(size(edgeTrace,2),1);
% for ii = 1:1:size(edgeTrace,2)
%     corrNewLoop(ii) = corr(edgeTrace(:,ii),edgeTraceNew);
% end
% distNewLoop = zeros(size(edgeTrace,2),1);
% f = @(x,y)sqrt(sum((x -y).^2));
% for ii = 1:1:size(centerOfMass,2)
%     distNewLoop(ii) = f(centerOfMass(:,ii),centerOfMassNew);
% end
% toc
% do you need function? yes....
roiMask = cat(3,roiMask,roiMaskNew);
centerOfMass = cat(2,centerOfMass,centerOfMassNew);
edgeTrace = cat(2,edgeTrace,edgeTraceNew);

%

corrMat = cat(2,corrMat,corrNew);
corrMat = cat(1,corrMat,[corrNew',1]); % self correlation is 1;

distMat = cat(2,distMat,distNew);
distMat = cat(1,distMat,[distNew',0]); % self correlation is 0;

%
objectName([ob1,ob2]) = [];
objectName = cat(2,objectName,newObjectName);

% lambda could also be changing...
end

