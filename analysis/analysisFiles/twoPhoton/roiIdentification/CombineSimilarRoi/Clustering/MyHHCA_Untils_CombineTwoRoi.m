function [edgeTrace,edgeTraceForCorr,roiMask,centerOfMass,corrVec,distVec,objectName,objectNameNext,whichCombine,stopFlag] =...
    MyHHCA_Untils_CombineTwoRoi(edgeTrace,edgeTraceForCorr,roiMask,centerOfMass,corrVec,distVec,objectName,objectNameNext,varargin)
lambda = 0.1;
beta = 3;
corrThresh = 0;
distThresh = +inf;
smoothEdgeFlag = true;
n_pair_max = 50;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%% check whether this group of points need to be clustered anymore.
N = size(edgeTrace,2);
stopFlag = true;
if N > 1
    stopFlag = true;
    roiSize = MyHHCA_Utils_CalculateRoiSizeFromRoiMaskNum(roiMask,objectName);
    roiSizeSumMat = bsxfun(@plus,roiSize,roiSize');
    roiSizeSumVec = roiSizeSumMat(tril(true(N,N),-1));
    % you would determine whether the correlation threshold is satisfied.
    [pairlist_sort,~] = MyHHCA_Untils_CombineNearest_Utils_SortSimilarity(corrVec, distVec, roiSizeSumVec, lambda, beta, n_pair_max);
    
    % check whether the correlation is larger than certain threshold.
    corrMat = squareform(corrVec);
    distMat = squareform(distVec);
    for pp = 1:1:size(pairlist_sort,1)
        if corrMat(pairlist_sort(pp,1),pairlist_sort(pp,2)) > corrThresh &&  distMat(pairlist_sort(pp,1),pairlist_sort(pp,2)) < distThresh
            stopFlag = false; % because find one which satisfy my standard.
            break
        end
    end
    grouplist = {pairlist_sort(pp,:)};

end
if ~stopFlag
    %% roiMask with number to roiMask with 1/0 window.
    roiMaskWindow = false(size(roiMask,1),size(roiMask,2),N);
    for nn = 1:1:N
        roiMaskWindowThis = false(size(roiMask)); roiMaskWindowThis(roiMask == objectName(nn)) = true;
        roiMaskWindow(:,:,nn) = roiMaskWindowThis;
    end
    
    % compute the edgeTrace... for newly formed group.
    nGroup = length(grouplist);
    edgeTraceCombine = zeros(size(edgeTrace,1),nGroup);
    centerOfMassCombine = zeros(2,nGroup);
    roiMaskCombineWindow = false(size(roiMask,1),size(roiMask,2),nGroup);
    whichCombine = cell(nGroup,1);
    for nn = 1:1:nGroup
        obj = grouplist{nn};
        [whichCombine{nn},edgeTraceCombine(:,nn),centerOfMassCombine(:,nn),roiMaskCombineWindow(:,:,nn)] = MyHCA_Untils_CombineBatch_Utils_CombineElementsInOneGroup(obj,objectName,edgeTrace,roiMaskWindow);
    end
    
    
    
    %% clean up old groups.
    objUsed = cell2mat(grouplist');
    objUsedName = objectName(objUsed);
    
    roiMask(ismember(roiMask,objUsedName)) = 0;
    centerOfMass(:,objUsed) = [];
    edgeTrace(:,objUsed) = [];
    edgeTraceForCorr(:,objUsed) = [];
    corrMat = squareform(corrVec); corrMat(objUsed,:) = [];corrMat(:,objUsed) = [];
    distMat = squareform(distVec); distMat(objUsed,:) = [];distMat(:,objUsed) = [];
    %% compute corrMat and disMat again, keep in mind that the format becomes
    if smoothEdgeFlag
        edgeTraceCombineSmooth = smooth(edgeTraceCombine(:),5); edgeTraceCombineSmooth = reshape(edgeTraceCombineSmooth ,size(edgeTraceCombine));
        edgeTraceForCorrCombine = edgeTraceCombineSmooth;
    else
        edgeTraceForCorrCombine = edgeTraceCombine;
    end
    corrMatCombine = corr(edgeTraceForCorrCombine);
    if  nGroup == 1;% if there are only one group, within group distance would be 0.
        distMatCombine = 0;
    else
        distMatCombine = squareform(pdist(centerOfMassCombine'));
    end
    
    % it is also possible that the whole thing was grouped together.
    if length(objectName) == length(objUsed)
        corrMatMix = [];
        distMatMix = [];
    else
        corrMatMix = corr(edgeTraceForCorr, edgeTraceForCorrCombine); % N - M traces, with M traces
        distMatMix = pdist2(centerOfMass',centerOfMassCombine');
    end
    % make it into Vector format...
    N_ = N + nGroup - length(objUsed);
    corrMat = [corrMat,corrMatMix;corrMatMix',corrMatCombine]; corrVec = corrMat(tril(true(N_,N_),-1));
    distMat = [distMat,distMatMix;distMatMix',distMatCombine]; distVec = distMat(tril(true(N_,N_),-1));
    
    %%
    newObjectName = (objectNameNext: objectNameNext + nGroup - 1)';
    objectName(objUsed) = [];
    objectName = cat(1,objectName,newObjectName);
    newObjectNameTemp = zeros(1,1,nGroup);newObjectNameTemp(:) = newObjectName;
    roiMaskNewObject = bsxfun(@times,roiMaskCombineWindow,newObjectNameTemp);
    roiMask = roiMask + sum(roiMaskNewObject,3);
    centerOfMass = cat(2,centerOfMass,centerOfMassCombine);
    edgeTrace = cat(2,edgeTrace,edgeTraceCombine);
    edgeTraceForCorr = cat(2,edgeTraceForCorr ,edgeTraceForCorrCombine);
    objectNameNext = newObjectName(end) + 1;
else
    whichCombine = [];
end



end

