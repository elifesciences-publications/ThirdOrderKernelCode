% tic
% N = size(edgeTrace,2);
% edgeTrace = cell2mat(edgeTraceCell');
% roiMask = roiMaskMat;
% centerOfMass = MyClustering_Untils_ComputeCenterOfMass(roiMask);
% corrMat = corr(edgeTrace);
% distMat = squareform(pdist(centerOfMass'));
% objectName = 1:1:N;
% lambda = 0.1;
% nRound = N - 1;

 clusteredObjectRecord = cell(N,1);
 edgeClusterRecord = cell(N,1);
 clusteredObjectRecord{1}.objectName = objectName; 
 edgeClusterRecord{1} = edgeTrace;
 % something wrong here. you have to debug your code, to figure out 
for ii = 1:1:nRound
 [edgeTrace,roiMask,centerOfMass,corrMat,distMat,objectName,whichCombined] = MyHCA_Untils_CombineNearest(edgeTrace,roiMask,centerOfMass,corrMat,distMat,objectName,N + ii,lambda);
 % you will remember a lot of things.
 clusteredObjectRecord{ii + 1}.objectName = objectName;
 clusteredObjectRecord{ii}.which = whichCombined;
 edgeClusterRecord{ii + 1} = edgeTrace;

end
toc % 1 second...

% visualization?
roiMaskClusterRecord = cell(nRound + 1,1);
roiNumber = repmat((1:1:nRoi)',[1,127 * 256]);
roiNumber = reshape(roiNumber', [127,256,nRoi]);
roiMaskMatNumber = roiMaskMat.*roiNumber;
roiMaskClusterRecord{1} = roiMaskMatNumber;
% show traces...
% first round

for ii = 1:1:nRound
   roiMaskClusterRecord{ii + 1} = CombineSameRoi_Clustering_Visualization_Utils_CombineRoiMasks(roiMaskClusterRecord{ii},clusteredObjectRecord{ii},clusteredObjectRecord{ii + 1}.objectName(end));
end
F(nRound) = struct('cdata',[],'colormap',[]);

MakeFigure;
for ii = 1:1:nRound
CombineSameRoi_Clustering_Visualization_Utils_ShowOneRoiMask(roiMaskClusterRecord{ii},edgeClusterRecord{ii},clusteredObjectRecord{ii});
pause(2);
F(ii) = getframe(gcf);
end

MakeFigure;
movie(figure,F,2);
v = VideoWriter('firstTry.avi','Uncompressed AVI');
v.FrameRate = 0.5;
open(v);
writeVideo(v,F);
close(v);
