function [edgeTrace,roiMask,centerOfMass,corrVec,distVec,objectName,whichCombine] = MyHCA_Untils_CombineBatch(edgeTrace,roiMask,centerOfMass,corrVec,distVec,objectName,newObjectName,lambda)

% corrVec and distVec...
tic
N = length(objectName);
% you have not decide to use num of pixels, or the 
maxNumGroupCombined = 1000;
corrThresh = 0.3;
distThresh = 10;
[grouplist] = MyHCA_Untils_CombineNearest_Utils_ChooseMany(corrVec,distVec,lambda,maxNumGroupCombined,corrThresh,distThresh);
%
nGroup = length(grouplist);
edgeTraceCombine = zeros(size(edgeTrace,1),nGroup);
centerOfMassCombine = zeros(2,nGroup);
roiMaskCombine = false(size(roiMask,1),size(roiMask,2),nGroup);
whichCombine = cell(nGroup,1);
for ii = 1:1:nGroup
    obj = grouplist{ii};
    [whichCombine{ii},edgeTraceCombine(:,ii),centerOfMassCombine(:,ii),roiMaskCombine(:,:,ii)] = MyHCA_Untils_CombineBatch_Utils_CombineElementsInOneGroup(obj,objectName,edgeTrace,roiMask);
end
toc

% 10% is too aggresive...

%% clean up old groups.
objUsed = cell2mat(grouplist');
roiMask(:,:,objUsed) = [];
centerOfMass(:,objUsed) = [];
edgeTrace(:,objUsed) = [];
corrMat = squareform(corrVec); corrMat(objUsed,:) = [];corrMat(:,objUsed) = [];
distMat = squareform(distVec); distMat(objUsed,:) = [];distMat(:,objUsed) = [];

%% compute corrMat and disMat again, keep in mind that the format becomes
% award now...
tic
corrMatCombine = corr(edgeTraceCombine);
distMatCombine = squareform(pdist(centerOfMassCombine'));
corrMatMix = corr(edgeTrace, edgeTraceCombine); % N - M traces, with M traces
distMatMix = pdist2(centerOfMass',centerOfMassCombine');
toc
% make it into Vector format...
N_ = N + nGroup - length(objUsed);
corrMat = [corrMat,corrMatMix;corrMatMix',corrMatCombine]; corrVec = corrMat(tril(true(N_,N_),-1));
distMat = [distMat,distMatMix;distMatMix',distMatCombine]; distVec = distMat(tril(true(N_,N_),-1));
%%
roiMask = cat(3,roiMask,roiMaskCombine);
centerOfMass = cat(2,centerOfMass,centerOfMassCombine);
edgeTrace = cat(2,edgeTrace,edgeTraceCombine);
%
objectName(objUsed) = [];
newObjectName = newObjectName: newObjectName + nGroup - 1;
objectName = cat(2,objectName,newObjectName);

% lambda could also be changing...
end

