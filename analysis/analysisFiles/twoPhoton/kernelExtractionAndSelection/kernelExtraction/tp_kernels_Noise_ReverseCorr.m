function kernels =  tp_kernels_Noise_ReverseCorr(respData,stimIndexes,stimData,varargin)
order = 1;
maxTau = 60;
repCVFlag = false;
repStimIndInFrame = [];
noiseKernelReps = 100;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if order == 2
    maxTau = 64;
end
nMultiBars = size(stimData,2);
nRoi = length(respData);

if repCVFlag
    [respDataGPU,stimDataGPU1,numElementsSummed,stimDataVar] = tp_kernels_ReverseCorrGPU_Prepare_Rep(respData,stimIndexes,stimData,maxTau,repStimIndInFrame);

else
    [respDataGPU,stimDataGPU1,numElementsSummed,stimDataVar] = tp_kernels_ReverseCorrGPU_Prepare(respData,stimIndexes,stimData,maxTau);
end

nT = size(respDataGPU{1},1);
rotBy = zeros(noiseKernelReps,1);
switch order
    case 1
        kernelsRaw = zeros(maxTau,noiseKernelReps,nMultiBars,nRoi);
        kernels = zeros(maxTau,noiseKernelReps,nMultiBars,nRoi);
    case 2
        maxTauSquared = maxTau * maxTau;
        kernelsRaw = zeros(maxTauSquared,noiseKernelReps,nMultiBars,nRoi);
        kernels = zeros(maxTauSquared,noiseKernelReps,nMultiBars,nRoi);
end

for nn = 1:1:noiseKernelReps
    
    % prepare the response data, stimulus is constant everytime.
    % rotBy(n) = floor(rand*nT);%maxTau+floor(rand*(nT-128));
    rotBy(nn) = maxTau * 2 + floor(rand*(nT - maxTau * 3));
    firstBunch = 1:rotBy(nn);
    secondBunch = rotBy(nn)+1:nT;
    kernelIndsUse = [secondBunch firstBunch];% shuffle(kernelInds)
    respDataGPU{1} = single(respDataGPU{1}(kernelIndsUse,:));
    % stim
    % convert maxTau to maxTau
    maxTau = single(maxTau);
    
    switch order
        case 1
            sumGPU = oned_gpu(maxTau,stimDataGPU1,respDataGPU);
            for qq = 1:nMultiBars
                kernelsRaw(:,nn,qq,:) = permute(sumGPU{qq},[1 3 4 2]);
            end
            
            for qq = 1:1:nMultiBars
                for rr = 1:1:nRoi
                    kernels(:,:,qq,rr) = kernelsRaw(:,:,qq,rr)/(numElementsSummed(rr) * stimDataVar(qq));
                end
            end
            
        case 2
            maxTau = single(64); % overwrite the maxTau.
            stimDataGPU2 = stimDataGPU1([2:end 1]); % shift it?
            sumGPU = twod_gpu(maxTau,stimDataGPU1,stimDataGPU2,respDataGPU);
            for qq = 1:nMultiBars
                kernelsRaw(:,nn,qq,:) = reshape(sumGPU{qq},[maxTauSquared,nRoi]);
            end
            
            for qq = 1:1:nMultiBars
                for rr = 1:1:nRoi
                    kernels(:,:,qq,rr) = kernelsRaw(:,:,qq,rr)/(numElementsSummed(rr) * stimDataVar(qq).^2);
                end
            end
    end
end


warning('check the stimulus variance again')

end