function kernels = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,varargin)
% kernels = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',1,'maxTau',60,'dx',1)
order = 1;
maxTau = 2;
dx = 1;
repCVFlag = false;
repStimIndInFrame = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
maxTau = single(maxTau);
%%
nMultiBars = size(stimData,2);
nRoi = length(respData);
% if repCVFlag = true, only use part of the stimulus and response.
if repCVFlag
    [respDataGPU,stimDataGPU1,numElementsSummed,stimDataVar] = tp_kernels_ReverseCorrGPU_Prepare_Rep(respData,stimIndexes,stimData,maxTau,repStimIndInFrame);

else
    [respDataGPU,stimDataGPU1,numElementsSummed,stimDataVar] = tp_kernels_ReverseCorrGPU_Prepare(respData,stimIndexes,stimData,maxTau);
end
switch order
    case 1
        sumGPU = oned_gpu(maxTau,stimDataGPU1,respDataGPU);
        
        kernelsRaw = zeros(maxTau,nMultiBars,nRoi);
        for qq = 1:1:nMultiBars
            kernelsRaw(:,qq,:) = permute(sumGPU{qq},[1,3,2]);
        end
        kernels = zeros(maxTau,nMultiBars,nRoi);
        
        for qq = 1:1:nMultiBars
            for rr = 1:1:nRoi
                kernels(:,qq,rr) = kernelsRaw(:,qq,rr)/(numElementsSummed(rr) * stimDataVar(qq));
            end
        end
        
    case 2
        maxTau = single(64); % overwrite the maxTau.
        stimDataGPU2 = stimDataGPU1([(1 + dx):end 1:dx]); % shift it?
        sumGPU = twod_gpu(maxTau,stimDataGPU1,stimDataGPU2,respDataGPU);
        
        maxTauSquared = maxTau * maxTau;
        kernelsRaw = zeros(maxTauSquared,nMultiBars,nRoi);
        for qq = 1:1:nMultiBars
            kernelsRaw(:,qq,:) = reshape(sumGPU{qq},[maxTauSquared,1,nRoi]);
        end
        kernels = zeros(maxTauSquared,nMultiBars,nRoi);
        
        for qq = 1:1:nMultiBars
            for rr = 1:1:nRoi
                kernels(:,qq,rr) = kernelsRaw(:,qq,rr)/(numElementsSummed(rr) * stimDataVar(qq).^2);
            end
        end
end
end