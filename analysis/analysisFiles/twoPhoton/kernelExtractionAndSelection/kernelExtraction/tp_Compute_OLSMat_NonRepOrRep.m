function [OLSMat] = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,repStimIndInFrame,repSegFlag,varargin)
% comput OLS Matrix used for kernel extraction.

% tp_kernels_OLS(respData,stimData,stimIndexes,'order',1,'maxTau',30,'nMultiBars',20,'reverseKernelFlag',false);
order = 1;
maxTau = 30;
nMultiBars = 20;
reverseKernelFlag = false;
reverseMaxTau = 0;

% there should also be a flag, which controls the direction of conting.

dx = 1; % this might be useful in the future.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nRoi = length(respData);
stimMatrix = cell(nMultiBars,nRoi); % content of each cell is a matrix.
respMatrix = cell(nRoi,1); % content of each cell is a vector.

if repSegFlag
    % the the repeated part. the first maxTau of repeatition data is thrown
    % out.
    % for the repearted part, you need the predicted response, as well as
    % the real reponse trial by trial...
    
    % first, check whether the last trial is finished.
    lastFrames = max(stimIndexes{1}) - maxTau;
    if max(repStimIndInFrame(:)) > lastFrames % you should check the stimIndexes
        outBoundaryTrials = repStimIndInFrame(end,:) > lastFrames;
        repStimIndInFrame(:,outBoundaryTrials) = [];
        % there is a corner situation?
    end
    repStimAllMatrix = repStimIndInFrame(maxTau + 1:end,:);
    repStimAll = repStimAllMatrix(:);
    
    nSeg = size(repStimAllMatrix,2);
    stimMatrixByTrial = cell(nSeg,nMultiBars,nRoi);
    stimRepByTrialUpSample = cell(nMultiBars,nRoi);
    respByTrial = cell(nRoi,1);
    relativeTimePointsEachTrial = cell(nRoi,1);
else
    % the non repeated part. after repeatition, maxTau data is throwed out.
    repStimPlusMaxTau = bsxfun(@plus,repmat((1:1:maxTau)',1,size(repStimIndInFrame,2)),repStimIndInFrame(end,:));
    repStimAll = cat(1,repStimIndInFrame,repStimPlusMaxTau);
    repStimAll = repStimAll(:);
end


for rr = 1:1:nRoi
    % for each roi, response will be shared between different bars.
    resp = respData{rr};  % could be put out. but more clear here.
    stimIndexesThisRoi = stimIndexes{rr};
    
    respInRepStimInd = ismember(stimIndexesThisRoi,repStimAll);
    nT = length(respData{rr});
    startInd = floor(maxTau/(60/13));
    endInd = nT - floor(reverseMaxTau/(60/13)); % stimulus 60Hz, response 13 Hz, 1 second is 4.6 response. why do you have to do this? only for reverseMaxTau
    
    % non repeated part... used to extract nonlinearity.
    % easy to change to non repeated version?
    if repSegFlag
        respUsedInd = respInRepStimInd & (1:nT >= startInd)' & (1:nT <= endInd)';
    else
        respUsedInd = ~respInRepStimInd & (1:nT >= startInd)' & (1:nT <= endInd)';
    end
    
    RR = resp(respUsedInd);
    RR = RR - mean(RR);
    respMatrix{rr} = RR;
    
    
    stimIndStart =  int32(stimIndexesThisRoi(respUsedInd));
    stimMatrix(:,rr) = tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimIndStart,maxTau,reverseKernelFlag,reverseMaxTau,nMultiBars,order,dx);
    
    % organize the response by trials
    if repSegFlag
        nSeg = size(repStimAllMatrix,2);
        respByTrial{rr} = cell(nSeg,1);
        
        % stimulus data by trials, 13Hz
        for ss = 1:1:nSeg
            respInRepStimInd = ismember(stimIndexesThisRoi, repStimAllMatrix(:,ss));
            respUsedInd = respInRepStimInd & (1:nT >= startInd)' & (1:nT <= endInd)';
            
            if length(stimIndexesThisRoi) ~= length(unique(stimIndexesThisRoi)) % frame drop.
                % set the repeated frames in respUsedInd into zeros.
                % find the places where there is repeated frames, and set
                % that respUsedInd to zeros.
                warning('Frames repeated here, ask Emilio!')
                repeatedFrames = find(diff(stimIndexesThisRoi) == 0) + 1; %
                respUsedInd(repeatedFrames) = false;
            end
            respByTrial{rr}{ss} = resp(respUsedInd);
            relativeTimePointsEachTrial{rr}(:,ss) = ismember(repStimAllMatrix(:,ss),stimIndexesThisRoi);
            
            stimIndStart =  int32(stimIndexesThisRoi(respUsedInd));
            % the format is perfect. trial, qq, rr
            stimMatrixByTrial(ss,:,rr) = tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimIndStart,maxTau,reverseKernelFlag,reverseMaxTau,nMultiBars,order,dx);
        end
        
        % stimulus data, one trial, 60 Hz
        %                 stimRepByTrialUpSample{qq,rr} = zeros(,maxTau);
        stimIndStart = int32(repStimAllMatrix(:,1)); % you should have a small function to do this transformation.
        % it is not very useful. predicted response from the raw
        % stimulus would have high frequency.
        stimRepByTrialUpSample(:,rr) =  tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimIndStart,maxTau,reverseKernelFlag,reverseMaxTau,nMultiBars,order,dx);
        
    end
end


OLSMat.stim = stimMatrix;
OLSMat.resp = respMatrix;

if repSegFlag
    OLSMat.respByTrial = respByTrial;
    OLSMat.relativeTimePointsEachTrial = relativeTimePointsEachTrial;
    OLSMat.stimMatrixByTrial = stimMatrixByTrial; % do you need this? not at all...
    OLSMat.stimRepByTrialUpSample = stimRepByTrialUpSample;
end
