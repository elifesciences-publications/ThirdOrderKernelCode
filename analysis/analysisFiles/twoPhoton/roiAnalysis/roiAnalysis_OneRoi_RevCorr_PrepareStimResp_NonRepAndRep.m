function [nonRepData,repData] = roiAnalysis_OneRoi_RevCorr_PrepareStimResp_NonRepAndRep(respData,stimData,stimIndexes,repStimuIndInFrame,nMultiBars)

%% first, do the repeated data
nSeg = size(repStimuIndInFrame,2);
respByTrial = cell(nSeg,1);
stimByTrial = cell(nSeg,1);
respData = respData{1};
stimIndexes = stimIndexes{1};
for ss = 1:1:nSeg
    respByTrial{ss} = respData(ismember(stimIndexes,repStimuIndInFrame(:,ss)));
    nT = sum(ismember(stimIndexes,repStimuIndInFrame(:,ss)));
    stimByTrial{ss} = zeros(nT,nMultiBars);
    for qq = 1:1:nMultiBars
        stimIndexesUsedThis = stimIndexes(ismember(stimIndexes,repStimuIndInFrame(:,ss)));
        stimByTrial{ss}(:,qq) = stimData(stimIndexesUsedThis,qq);
    end
end
repData.stim = stimByTrial;
repData.resp = respByTrial;

%% non repeated segments. 
respByTrial = cell(nSeg,1);
stimByTrial = cell(nSeg,1);
for ss = 1:1:nSeg
    if ss == nSeg
        nonRespStimInFame = repStimuIndInFrame(end,ss) + 1:1:stimIndexes(end);
    else
        nonRespStimInFame = repStimuIndInFrame(end,ss) + 1:1:repStimuIndInFrame(1,ss + 1) - 1;
    end
    respByTrial{ss} = respData(ismember(stimIndexes,nonRespStimInFame));
    nT = sum(ismember(stimIndexes,nonRespStimInFame));
    stimByTrial{ss} = zeros(nT,nMultiBars);
    for qq = 1:1:nMultiBars
        stimIndexesUsedThis = stimIndexes(ismember(stimIndexes,nonRespStimInFame));
        stimByTrial{ss}(:,qq) = stimData(stimIndexesUsedThis,qq);
    end
end
nonRepData.stim = stimByTrial;
nonRepData.resp = respByTrial;


end