function ROI =  HCA_ROIIdentification(Z)
edgeTypes = {'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge','Square Left','Square Right','Square Up','Square Down'};
nEdges = length(edgeTypes);
%% Select background
bkgdMask = roiUtils_dimConnectedBg( Z );
% Update the windowMask so that background regions are excluded from
% all future selection.
Z.grab.windowMask = Z.grab.windowMask .* ~bkgdMask;

%% compute the inds of those epoches.
controlEpochInds = cell(nEdges,1);
inds = cell(nEdges,2);
indsAllEdge = []; % first presentation, and second presentation.
for qq = 1:nEdges
    % Grabbing the frames in which the edge types occurred
    controlEpochInds{qq} = getEpochInds(Z, edgeTypes{qq});
    inds{qq,2} = [];
    for r = 1:length(controlEpochInds{qq})
        inds{qq,r} = controlEpochInds{qq}{r};
    end
    if length(inds{qq,1}) > length(inds{qq,2})
        inds{qq,1} = inds{qq,1}(1:length(inds{qq,2}));
    else
        inds{qq,2} = inds{qq,2}(1:length(inds{qq,1}));
    end
end
indsAllEdge = cell2mat(inds); % 

% you still want to cut more pixels away... keep the top 25 is
% reasonable...

%% compute the quality of one pixel using correlation between two epoches.
imgFrames = Z.grab.imgFrames;
meanImg = mean(imgFrames,3);
varImg = var(imgFrames,0,3);
% MakeFigure; subplot(221); histogram(meanImg(:)); subplot(222);histogram(varImg(:));
meanThresh = prctile(meanImg(:),50);
varThresh = prctile(varImg (:),50); % try to use this new threshold.

% try to 
pixelInUse = Z.grab.windowMask & meanImg > meanThresh & varImg  > varThresh ;
% MakeFigure;imagesc(meanImg); colormap gray; colorbar;
% MakeFigure; imagesc(meanImg .* pixelInUse);colormap gray; colorbar;
% MakeFigure; imagesc(varImg); colormap gray; colorbar;
% MakeFigure; imagesc(varImg .* pixelInUse);colormap gray; colorbar;

% % prepare for the roiMaskInitial;
N = sum(pixelInUse(:));
indPixelInUse = find(pixelInUse > 0);
centerOfMAssInitial = zeros(2,N);
[centerOfMAssInitial(1,:),centerOfMAssInitial(2,:)] = ind2sub(size(meanImg),indPixelInUse);
roiMasksInitial = zeros([size(meanImg),N]);
% 
% 
% % organize the thing...
edgeTraceFirst = imgFrames(:,:,indsAllEdge(:,1));
edgeTraceSecond = imgFrames(:,:,indsAllEdge(:,2));
edgeTrace = (edgeTraceFirst + edgeTraceSecond)/2;
A = permute(edgeTrace,[3,1,2]); B = reshape(A,size(A,1),[]); 
edgeTraceInitial = B(:, pixelInUse);
cd('C:\Users\Clark Lab\Documents\Holly_log\04_21_2016');
save('debugDataSet_TraceAndRoiMask','edgeTraceInitial','pixelInUse','-v7.3');
% 
% combine them together first? 

% you need a lot of preprocessing to decrease the data set...
% you can compute the variance and mean, go get rid of very black spots.
% how many of them get you get rid of?


% edgeTrace = B;
% corrMat = C;
% % preprocessing,
% tic
% C = corr(B); %% good, only one minute.
% toc
% centerOfMass is fixed.
% distMat is fixed. 

% [nPixelVer ,nPixelHor] = size(imgFrames(:,:,1));
% 
% centerOfMass 
% save('debugDataSet_TraceAndRoiMask','edgeTraceInitial','pixelInUse','-v7.3'); % much faster this time... good good.

end