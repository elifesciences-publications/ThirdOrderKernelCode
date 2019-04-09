function [grouplist,stopFlag] = MyHHCA_Untils_CombineNearest_Utils_ChooseMany_WithStopFlag(corrVec,distVec,lambda,K,corrThresh,distThresh) % you might need other conditions in the future;
% you have to know how many objects do you have now.
M = round(1 + sqrt(2 * length(corrVec)));
similarityVec = corrVec -  distVec * lambda; % If there is only one group.
pair_use = (corrVec > corrThresh) & (distVec <= distThresh);
% do you want to bias towards smaller roisize? yes. lambda

% when you sort, you should only sort those which has satisfied threshold.
L = tril(true(M,M),-1);
[indx, indy] = ndgrid(1:M,1:M);indxVec = indx(L);indyVec = indy(L); % very very bad idea, you had better calculate it.

% sort everything, find the most similar pair of rois which satisfy two thresholds.
% in the sorting space.

[~,IVec] = sort(similarityVec,'descend');
pair_use_sort = pair_use(IVec);

% ATTENTION. DO YOU WANT A STOPPING CONDITION LIKE THIS?
numPairCombined = min([K - 1,sum((corrVec > corrThresh) & (distVec <= distThresh) )]);

% judge whether to go through this trouble... although it is a genenous
% function.
if numPairCombined == 0
    grouplist = [];
    stopFlag = true;
else
    pairlist = zeros(numPairCombined,2);
    % you should decide which pair to use.
    a = find(pair_use_sort);
    pairlist(:,1) = indxVec(IVec(a(1:numPairCombined)));
    pairlist(:,2) = indyVec(IVec(a(1:numPairCombined)));
%     corrVec(IVec(a(1:numPairCombined)))
    if numPairCombined == 1
        grouplist  = {pairlist};
        stopFlag = false;
    else
        grouplist = MyClustering_InitialBatchCluster_Utils_GraphPartition_Combine(pairlist);
        stopFlag = false;
    end
end