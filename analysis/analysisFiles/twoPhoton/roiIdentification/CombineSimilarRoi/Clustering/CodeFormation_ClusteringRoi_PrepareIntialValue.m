tic
load('debugDataSet_TraceAndRoiMask'); % very fast
toc
% initial value;
nPixelVer = 127;
nPixelHor = 256;

N = sum(pixelInUse(:));
indPixelInUse = find(pixelInUse > 0);
centerOfMAssInitial = zeros(2,N);
[centerOfMAssInitial(1,:),centerOfMAssInitial(2,:)] = ind2sub([nPixelVer,nPixelHor],indPixelInUse);
roiMaskInitial = false(nPixelVer,nPixelHor,N);
tic
for nn = 1:1:N
    roiMaskInitial(centerOfMAssInitial(1,nn),centerOfMAssInitial(2,nn),nn) = true;
end
toc 

%%
tic % 5 seconds, really really fast. good!
distVecInitial = pdist(centerOfMAssInitial')'; % slower than corr, not clearer why. 4 minutes. without gpu.
toc

% before you calculte the correlation, smooth the data first.
% use for loop? 
edgeTraceInitialSmooth = smooth(edgeTraceInitial(:),5); %
edgeTraceInitialSmooth = reshape(edgeTraceInitialSmooth ,size(edgeTraceInitial));
tic
corrMatInitial = corr(edgeTraceInitialSmooth); % only 7 seconds! cool!
toc
% corrMatInitialSmooth = corr(edgeTraceInitialSmooth);
% corrMatInitial = corrMatInitialSmooth;
% MakeFigure;
% h{1} = histogram(corrMatInitial); hold on;
% h{2} = histogram(corrMatInitialSmooth);
% Histogram_Untils_SetBinWidthLimitsTheSame(h,'normByProbabilityFlag',true);

% also only store the edge response/
%%
