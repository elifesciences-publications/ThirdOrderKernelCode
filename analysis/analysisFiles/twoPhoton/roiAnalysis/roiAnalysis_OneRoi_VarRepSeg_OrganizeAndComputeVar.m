function varInfo = roiAnalysis_OneRoi_VarRepSeg_OrganizeAndComputeVar(respFull,respByTrial,respRepByTrialTimeLag,varargin)
interpolationFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
nSeg = size(respFull,2);

if interpolationFlag
    meanRespTrain = mean(respFull,2);
else
    respFull = nan(size(respRepByTrialTimeLag));
    for ss = 1:1:nSeg
        respFull(respRepByTrialTimeLag(:,ss),ss) = respByTrial{ss};
    end
    meanRespTrain = nanmean(respFull,2); % what if there is nan in one time point. that would still be nan, do not worry...
end

meanRespByTrial = cell(nSeg,1);
for ss = 1:1:nSeg;
    meanRespByTrial{ss} = meanRespTrain(respRepByTrialTimeLag(:,ss));
end
% do the cross validation.
meanVec = cell2mat(meanRespByTrial);
respVec = cell2mat(respByTrial);

varInfo = roiAnalysis_OneRoi_VarRepSeg_ComputeVar(respVec,meanVec);

% sometimes, you might want to compute from the non interpolated noise.
% try to get everything calculate again.

% varmean, varresp, varresidual, ratio, correlation.