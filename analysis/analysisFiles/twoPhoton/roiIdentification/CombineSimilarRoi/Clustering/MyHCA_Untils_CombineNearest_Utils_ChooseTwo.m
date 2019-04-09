function  [ob1,ob2,largestSimilarity] = MyHCA_Untils_CombineNearest_Utils_ChooseTwo(corrMat,distMat,lambda)
similarityMat = corrMat - lambda * distMat; 
similarityMat(eye(size(similarityMat,2)) == 1) = -inf; % set it to be a real 
% if it is 0.4 and if it is larger than 20...select a new one...
[largestSimilarity,I] = max(similarityMat(:));
N = size(corrMat,1);
[ob1,ob2 ]= ind2sub([N,N],I);


% corrOb1Ob2 = 0;
% distOb1Ob2 = inf;
% [similarityMatSort,I] = sort(similarityMat(:),'descend');
% % [maxValue,maxInd] = max(similarityMat(:));
% % [maxValue,maxInd] = max(similarityMat(:));
% count = 1;
% while ((corrOb1Ob2 < 0.3) || (distOb1Ob2> 20)) && count <= N;
% [ob1,ob2 ]= ind2sub([N,N],I(count));
% corrOb1Ob2 = corrMatrix(ob1,ob2);
% distOb1Ob2 = distBetweenRoiNorm(ob1,ob2);
% count = count + 2;
% end
% 
% if count >= N
%     stopCluteringFlag = true;
% else
%     stopCluteringFlag = false;
% end
end