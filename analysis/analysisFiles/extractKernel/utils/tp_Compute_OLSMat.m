function [OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,varargin)
% comput OLS Matrix used for kernel extraction.

% tp_kernels_OLS(respData,stimData,stimIndexes,'order',1,'maxTau',30,'nMultiBars',20,'reverseKernelFlag',false);
order = 1;
maxTau = 30;
nMultiBars = size(stimData, 2);
reverseKernelFlag = false;
reverseMaxTau = 0;
arma_flag = false;
maxTau_r = 0;
% there should also be a flag, which controls the direction of conting.

dx = 1; % this might be useful in the future.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% for each roi, there would be new response and new stimulus indexes.
% mean subtraction ?

nRoi = length(respData);
stimMatrix = cell(nMultiBars,nRoi); % content of each cell is a matrix.
respMatrix = cell(nRoi,1); % content of each cell is a vector.
resp_auto_Matrix = cell(nRoi,1);

% how should I organize the data structure so that Omer could use it??
for rr = 1:1:nRoi
    % for each roi, response will be shared between different bars.
    resp = respData{rr};  % could be put out. but more clear here.
    stimIndexesThisRoi = stimIndexes{rr};
    
    nT = length(respData{rr});
    %             RR = zeros(nTMat,1);
    %             stimInd = zeros(nTMat,reverseMaxTau + maxTau);
    %
    % instead of for loop, you can do it pretty fast. cool. Thanks,
    % Emilio!
    startInd = maxTau;
    endInd = nT - reverseMaxTau;
    nTMat = endInd - startInd + 1;
    
    % because it is really fast to calculate, do not store it?
    RR = resp(startInd:1:endInd);
    RR = RR - mean(RR);
    
    respMatrix{rr} = RR;
    
    
    stimIndStart = int32(stimIndexesThisRoi((startInd:1:endInd)));
    stimMatrix(:,rr) = tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimIndStart,maxTau,reverseKernelFlag,reverseMaxTau,nMultiBars,order,dx,varargin{:});
    
    if arma_flag
        if maxTau_r == 0
            error('auto correlation time lag should be larger than zero');
        
        elseif maxTau_r == 1
            resp_mean_sub = resp - mean(resp(startInd:1:endInd));
            RR_auto =  resp_mean_sub(startInd - 1:1:endInd - 1); % use the previous one.
            resp_auto_Matrix{rr} =  RR_auto;
        else
            warning('maxtau for autoregression is very large');
            resp_mean_sub = resp - mean(resp(startInd:1:endInd));
            temp = toeplitz(resp_mean_sub, resp_mean_sub(1:maxTau_r + 1)); RR_auto = temp(startInd:1:endInd, 2:end);
            resp_auto_Matrix{rr} =  RR_auto;
        end
    else
         resp_auto_Matrix{rr} = [];
    end
    
end

OLSMat.stim = stimMatrix;
OLSMat.resp = respMatrix;
OLSMat.resp_auto =  resp_auto_Matrix;
