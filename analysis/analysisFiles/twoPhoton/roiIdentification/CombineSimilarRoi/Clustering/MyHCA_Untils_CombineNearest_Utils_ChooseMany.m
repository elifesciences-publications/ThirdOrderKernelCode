function grouplist= MyHCA_Untils_CombineNearest_Utils_ChooseMany(corrVec,distVec,lambda,maxNumGroupCombined,corrThresh,distThresh)
% you have to know how many objects do you have now.
M = round(1 + sqrt(2 * length(corrVec)));
similarityVec = corrVec -  distVec * sqrt(var(corrVec)/var(distVec))* lambda;
L = tril(true(M,M),-1);
[indx, indy] = ndgrid(1:M,1:M);indxVec = indx(L);indyVec = indy(L); % very very bad idea, you had better calculate it.
[~,IVec] = sort(similarityVec,'descend');
% set a abosolute value would be much better and a number here...
numPairCombined = min([maxNumGroupCombined - 1,sum(corrVec > corrThresh),sum(distVec <= distThresh )]);
pairlist = zeros(numPairCombined,2);
pairlist(:,1) = indxVec(IVec(1:numPairCombined ));
pairlist(:,2) = indyVec(IVec(1:numPairCombined ));
grouplist = MyClustering_InitialBatchCluster_Utils_GraphPartition_Combine(pairlist);
% you also want your seed to spread out... the within group distance /
% between group similarities would be largest... at first...think about
% this...
end