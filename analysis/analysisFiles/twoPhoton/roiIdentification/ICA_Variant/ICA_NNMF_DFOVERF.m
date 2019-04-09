function ROI = ICA_NNMF_DFOVERF(Z)
% Attempt to segment regions of the image by edge selectivity. This assumes
% that all the edge types have been presented (variable edgeTypes). Note
% that this script requires imgFrame!
roiMinPixNumber = 5;
loadFlexibleInputs(Z);
edgeTypes = {'Left Light Edge','Right Light Edge','Left Dark Edge','Right Dark Edge'};
nEdges = length(edgeTypes); % the edgeTypes will be hard coded??
imgSize = size(Z.grab.imgFrames);

%% househould.
bkgdMask = roiUtils_dimConnectedBg( Z );
Z.grab.windowMask = Z.grab.windowMask .* ~bkgdMask;

%% get the image for ICA subtraction
imgFrames = Z.grab.imgFrames;
meanImg = mean(imgFrames,3);
% [~,roiMask_ICA_F,~] = IcaRoiExtraction(meanImg,imgFrames);

numEpochs = 1; % I only have one epoch.
epochStartTimes = cell(numEpochs,1);
epochDurations = cell(numEpochs,1);
% epochStartTimes{1} = Z.params.trigger_inds.epoch_13.bounds(1);
epochStartTimes{1} = Z.params.trigger_inds.epoch_13.trigger_data;
epochDurations{1} = diff([Z.params.trigger_inds.epoch_13.trigger_data; Z.params.trigger_inds.epoch_13.bounds(2)]);
interleaveEpoch = 1;
deltaFOverF = CalcDeltaFOverF(imgFrames,epochStartTimes,epochDurations,interleaveEpoch);

[~,roiMask_ICA_DFOverF,~] = IcaRoiExtraction(meanImg,deltaFOverF);

% try the one without df/f first.
roiMask_ICA = roiMask_ICA_DFOverF;
nRoi = max(max(roiMask_ICA));
roiMask_ICA_BW = zeros([size(roiMask_ICA), nRoi]);
for rr = 1:1:nRoi
    roiMask_ICA_BW(:,:,rr) = roiMask_ICA == rr;
end

MakeFigure;
quickViewRois(roiMask_ICA_BW);
roiMask_ICA = roiMask_ICA_BW;
% put the roiMask_ICA into the format I like...
% make sure the roi is in the window.
for rr = 1:1:nRoi
    roiMask_ICA(:,:,rr) = roiMask_ICA(:,:,rr) & Z.grab.windowMask;    
end



%%
%% prepare image traces for ICA.
controlEpochInds = cell(nEdges,1);
inds = cell(nEdges,2); % time for four epoches time
nEachEpoch = zeros(nEdges,1);
indsAll = [];
for qq = 1:nEdges
    % Grabbing the frames in which the edge types occurred
    controlEpochInds{qq} = getEpochInds(Z, edgeTypes{qq});
    inds{qq,1} = [];
    for ii = 1:length(controlEpochInds{qq})
        % indscat contains all the indexes for those frames in linear
        % form, as opposed to separated into presentations as in
        % controlEpochInds
        inds{qq,ii} = controlEpochInds{qq}{ii};
    end
    if length(inds{qq,1}) > length(inds{qq,2})
        inds{qq,1} = inds{qq,1}(1:length(inds{qq,2}));
    else
        inds{qq,2} = inds{qq,2}(1:length(inds{qq,1}));
    end
    nEachEpoch(qq) = length( inds{qq,2});
    indsAll = [indsAll;inds{qq,1},inds{qq,2}];
end

edgeRespImgMean = imgFrames(:,:,indsAll(:,1)) + imgFrames(:,:,indsAll(:,2));

%%
nRoi = size(roiMask_ICA,3) - 1;
roiSize = zeros(nRoi,1);
for rr = 1:1:nRoi
    roiSize(rr) = sum(sum(roiMask_ICA(:,:,rr)));
end

threshSize = 25; % might not be very useful...
roiSelectedBySize = roiSize > threshSize;
%
roiSelected = roiSelectedBySize;
roiUse = find(roiSelected);
nRoiUse = length(roiUse);
%%
roiMasksNew = [];
splitFlagAll = zeros(nRoiUse,1);
for ii = 1:1:nRoiUse
    rr = roiUse(ii);
    roiMaskThis = squeeze(roiMask_ICA(:,:,rr));
    %     waterShed_JuyueTest_PixelsResponse(roiMask,Z.grab.imgFrames,Z);
    [splitFlag,subRoiMask] = getSubRoiMask(roiMaskThis,edgeRespImgMean,meanImg,rr);
    splitFlagAll(ii) = splitFlag;
    if splitFlag
        roiMasksNew = cat(3,roiMasksNew,subRoiMask);
    end
end
roiMasksOld = roiMask_ICA;
roiMasksOld(:,:,roiUse(splitFlagAll == 1)) = [];

roiMask_ICA_InWindow = cat(3,roiMasksOld,roiMasksNew);
roiMask_ICA_InWindow = cat(3,roiMask_ICA_InWindow,bkgdMask);

% Holly's code to remove very small rois. But, only eliminate very small rois
nRoiOrig = size(roiMask_ICA_InWindow,3);
remove = zeros(nRoiOrig,1);
for q = 1:nRoiOrig
    if sum(sum(roiMask_ICA_InWindow(:,:,q))) < roiMinPixNumber
        remove(q) = 1;
    end
end
remove = ( remove ~= 0 );
roiMask_ICA_InWindow(:,:,remove) = [];
ROI.roiMasks = roiMask_ICA_InWindow;
end