function [pairlist,stopFlag] = MyHHCA_Untils_CombineNearest_Utils_SortSimilarity(corrVec,distVec,roiSizeSumVec, lambda,beta, n_pair_max) % you might need other conditions in the future;
% if there is only two group. tried to combine smaller size.
% you will use a more complex alrogithm to select which pair of roi to use...
% 1. correlation is high: corrVec
% 2. distance is small: distVec
% 3. roisize is small: roiSizeSumVec
% for T4T5
% 4. ESI/DSI has not been decreased. (ESI has not been decreased. This is more likely to happen)
% 5. Response is not the shifted version of each other.

% every pair has a rank
% ESI/DSI as a threshold.
% shift as a threshold.
% if there is no suitable, continue searching? compute it one by one.

% in the end, find the pair which has the largest value.
% + sign. It is better to have large correlation, sort by ascend, so that
% correlation has larger rank is prefered.
[~, ~, rank_corr] = unique(corrVec); % this would be super slow...

% - sign. It is better to have smaller correlation. sort by ascend, so that
% distance has smaller rank is prefered.
[~, ~, rank_dist] = unique(distVec);

% - sign. It is better to have smaller roi size. sort by ascend, so
% that roi size has smaller rank is prefered.
[~, ~, rank_roi_size] = unique(roiSizeSumVec);

% larger score is prefered.
score = rank_corr - lambda * rank_dist - beta * rank_roi_size;

M = round(1 + sqrt(2 * length(corrVec)));

L = tril(true(M,M),-1);
[indx, indy] = ndgrid(1:M,1:M);indxVec = indx(L);indyVec = indy(L); % very very bad idea, you had better calculate it.
[~,IVec] = sort(score,'descend');
numPairCombined = min([n_pair_max,length(corrVec)]);

% judge whether to go through this trouble... although it is a genenous
% function.
if numPairCombined == 0
    pairlist = [];
    stopFlag = true;
else
    pairlist = zeros(numPairCombined,2);
    pairlist(:,1) = indxVec(IVec(1:numPairCombined ));
    pairlist(:,2) = indyVec(IVec(1:numPairCombined ));
    stopFlag = false;
end