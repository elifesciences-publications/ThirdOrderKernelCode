function kernel = tp_Compute_2DKernel_TwoBar_OnlyPositivePair(respData,stimData,stimIndexes,barLeft, barRight)
% tp_kernels_OLS(respData,stimData,stimIndexes,'order',1,'maxTau',30,'nMultiBars',20,'reverseKernelFlag',false);

maxTau = 50;
nT = length(respData);
% there should also be a flag, which controls the direction of conting.
% for ii = 1:2:length(varargin)
%     eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
% end

% nRoi = length(respData);
% stimMatrix = cell(nMultiBars,nRoi); % content of each cell is a matrix.
% respMatrix = cell(nRoi,1); % content of each cell is a vector.

RR = respData(maxTau:1:nT);
RR = RR - mean(RR);

stimIndStart =  stimIndexes((maxTau:1:nT));
offSet = uint32(0:1:maxTau - 1); % row vector.

offSet = repmat(offSet,[nT - maxTau + 1,1]);
stimInd = bsxfun(@minus,stimIndStart,offSet);

stim_1 = stimData(:,barLeft);
stim_2 = stimData(:,barRight); % watch out for q == 20; if q == 20, q + 1 = 21? no mod(q+1,20)
%                 SS_1 = zeros(nT - maxTau + 1,maxTau);
%                 SS_2 = zeros(nT - maxTau + 1,maxTau);
%                  SS = zeros(nT - maxTau + 1, maxTau^2);
SS_1 = stim_1(stimInd);
SS_2 = stim_2(stimInd);
SS = OLSGenerationSS_OneDToTwoD(SS_1,SS_2);

SS(SS < 0) = 0;
kernel = SS\RR; % only one kernel between this two bars....

end