function cov_mat_all = tp_Compute_CovarianceMatrix_FristOrderKernelSub(respData, stimIndexes,stimData,firstOrderKernel, repStimAll)
% get a response,
[maxTau,nMultiBars] = size(firstOrderKernel{1});
% you might have to do it
D = maxTau * nMultiBars;

% for a given roi. get the path.
% for this version, forget about the trial...
nRoi = length(respData);
cov_mat_all = cell(nRoi,1);
for rr = 1:1:nRoi
    cov_mat = zeros(D, D);
    stim_mean = firstOrderKernel{rr}(:);
    % for each roi, response will be shared between different bars.
    resp = respData{rr};  % could be put out. but more clear here.
    stimIndexesThisRoi = stimIndexes{rr};
    
    respInRepStimInd = ismember(stimIndexesThisRoi,repStimAll);
    nT = length(respData{rr});
    startInd = floor(maxTau/(60/13));
    %     endInd = nT - floor(reverseMaxTau/(60/13)); % stimulus 60Hz, response 13 Hz, 1 second is 4.6 response. why do you have to do this? only for reverseMaxTau
    endInd = nT;
    % non repeated part... used to extract nonlinearity.
    % easy to change to non repeated version?
    
    respUsedInd = respInRepStimInd & (1:nT >= startInd)' & (1:nT <= endInd)';
    
    RR = resp(respUsedInd);
    RR = RR - mean(RR);
    
    stimIndStart =  int32(stimIndexesThisRoi(respUsedInd));
    offSet = int32(0:1:maxTau - 1); % row vector.
    nTMat = length(stimIndStart); %
    offSet = repmat(offSet,[nTMat,1]);
    stimInd = bsxfun(@minus,stimIndStart,offSet);
    
    % there are 14682 cases to be dealt with.
    tic
    for tt = 1:1:nTMat
        % for every response. find its corresponding stimulus.
        stim_mat = stimData(stimInd(tt,:),:);
        stim_vec = stim_mat(:);
        
        % 
        stim_vec_sub = stim_vec - stim_vec' * stim_mean * stim_mean/(stim_mean' * stim_mean);
        
        cov_mat = cov_mat + stim_vec_sub * stim_vec_sub' * RR(tt);
    end
    toc
    cov_mat = cov_mat/nTMat;
    cov_mat_all{rr} = cov_mat;
    % this would be the second order kernel.
end