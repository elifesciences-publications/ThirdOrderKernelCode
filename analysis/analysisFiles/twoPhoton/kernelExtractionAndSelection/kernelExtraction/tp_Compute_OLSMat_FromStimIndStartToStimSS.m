function  stimMatrix = tp_Compute_OLSMat_FromStimIndStartToStimSS(stimData,stimIndStart,maxTau,reverseKernelFlag,reverseMaxTau,nMultiBars,order,dx,varargin)
setBarUseFlag = false;
% barUse',barUse
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% you spend some time change this!! this morning... so bad....

offSet = int32(0:1:maxTau - 1); % row vector.
if reverseKernelFlag
    offSet = int32(-reverseMaxTau:1:maxTau - 1);
    stimIndStart = int32(stimIndStart);
end
nTMat = length(stimIndStart); %
offSet = repmat(offSet,[nTMat,1]);
stimInd = bsxfun(@minus,stimIndStart,offSet);


if setBarUseFlag
    nMultiBarsUse = length(find(barUse~=0));
    if ~exist('barUse','var')
        error('barUse is not set');
    end
else
    nMultiBarsUse = size(stimData,2);
    barUse = 1:nMultiBarsUse;
end
stimMatrix = cell(nMultiBarsUse,1);
switch order
    case 1
        
        
        for qq = 1:1:nMultiBarsUse
            barUseThis = barUse(qq);
            stim = stimData(:,barUseThis);
            SS = stim(stimInd);
            stimMatrix{qq} = SS;
            
        end
        
    case 2
       
        
        for qq = 1:1:nMultiBarsUse;
            barUseThis = barUse(qq);
            stim_1 = stimData(:,barUseThis);
            stim_2 = stimData(:,mod(barUseThis,nMultiBars) + dx); % watch out for q == 20; if q == 20, q + 1 = 21? no mod(q+1,20)
            %                 SS_1 = zeros(nT - maxTau + 1,maxTau);
            %                 SS_2 = zeros(nT - maxTau + 1,maxTau);
            %                  SS = zeros(nT - maxTau + 1, maxTau^2);
            SS_1 = stim_1(stimInd);
            SS_2 = stim_2(stimInd); % the only extra step? no way....
            SS = OLSGenerationSS_OneDToTwoD(SS_1,SS_2);
            
            % after this matrix, you might need another process to
            stimMatrix{qq} = SS;
        end
end
end