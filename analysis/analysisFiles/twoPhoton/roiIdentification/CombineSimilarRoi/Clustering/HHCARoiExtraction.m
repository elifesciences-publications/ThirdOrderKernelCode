function [flyResp, roiMask, extraVals] = HHCARoiExtraction(backgroundSubtractedMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)
epochsForIdentificationForFly_T4T5 = {'Right Light Edge','Right Dark Edge','Left Light Edge','Left Dark Edge','Square Right','Square Left','Square Down','Square Up',...
    'Up Light Edge','Up Dark Edge','Down Light Edge','Down Dark Edge'};
epochsForIdentificationForFly_T4T5 = lower(epochsForIdentificationForFly_T4T5);
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
dFoF = deltaFOverF;
imageSize = [127,256];
% roiMask_movement_corrected_cord = size(deltaFOverF); roiMask_movement_corrected_cord = roiMask_movement_corrected_cord(1:2);




%% first, look at the mean image, and select pixels which has some good thing in it..
meanImg = mean(dFoF,3);
varImg = var(dFoF,0,3);
meanThresh = prctile(meanImg(:),20);
varThresh = prctile(varImg (:),20); % try to use this new threshold.

% the background has not been get rid of... more than half of the data.
pixelInUse =  meanImg > meanThresh & varImg  > varThresh ; % 16971 a lot of pixels, should be okay,
% MakeFigure;imagesc(meanImg); colormap gray; colorbar;
% MakeFigure; imagesc(meanImg .* pixelInUse);colormap gray; colorbar;
MakeFigure; imagesc(varImg); colormap gray; colorbar;
MakeFigure; imagesc(varImg .* pixelInUse);colormap gray; colorbar;


%% second, calculate the time traces which will be used to compute the roi mask.

% choose epoch
epoch_name = {params.epochName};
epoch_name = lower(epoch_name); epochsForIdentificationForFly = lower(epochsForIdentificationForFly);
% change everything into lower case;

n_epoch = length(epochsForIdentificationForFly); % the probe has been changed.
inds = cell(n_epoch,1);
% if it is T4T5, only use the first two trials.
for qq = 1:1:n_epoch
    epoch_name_this = epochsForIdentificationForFly{qq};
    edge_ind = find(strcmp(epoch_name_this, epoch_name));
    epoch_start_time_this = epochStartTimes{edge_ind}; % all the starting time, there are three of them. just use first two of them.
    epoch_duration_this = epochDurations{edge_ind};
    if isempty(find(strcmp(epoch_name_this,epochsForIdentificationForFly_T4T5),1));
        % average over all trials.
    else
        % if it is T4T5 dataset, you can only use first 2 trials.
        epoch_start_time_this = epoch_start_time_this(1:2);
        epoch_duration_this = min(epoch_duration_this(1:2));
        
        inds{qq} = zeros(epoch_duration_this,2);
        for ii = 1:1:2
            inds{qq}(:,ii) = epoch_start_time_this(ii): epoch_start_time_this(ii) + epoch_duration_this - 1;
        end
    end
end
indsAllEdge = cell2mat(inds); %

% average the epoch and use trace
edgeTraceFirst = dFoF(:,:,indsAllEdge(:,1));
edgeTraceSecond = dFoF(:,:,indsAllEdge(:,2));
edgeTrace = (edgeTraceFirst + edgeTraceSecond)/2;
A = permute(edgeTrace,[3,1,2]); B = reshape(A,size(A,1),[]);
edgeTraceInitial = B(:, pixelInUse);
% you might use the epochStartTimes and epochDuration,
roiWindow_imaging_cord = ICA_DFOVERF_Untils_InferWindowMask(pixelInUse,imageSize);
pixelInUse_imaging_cord = false(size(roiWindow_imaging_cord));
pixelInUse_imaging_cord(roiWindow_imaging_cord) = pixelInUse;

roiMask_imaging_cord = HHCARoiExtraction_Main(edgeTraceInitial, pixelInUse_imaging_cord);
roiMask = roiMask_imaging_cord(roiWindow_imaging_cord); roiMask = reshape(roiMask,size(pixelInUse));
% you also have to change the corrdination back.
if ~exist('extraVals', 'var')
    extraVals = [];
end
flyResp = [];

MakeFigure;imagesc(roiMask);
end