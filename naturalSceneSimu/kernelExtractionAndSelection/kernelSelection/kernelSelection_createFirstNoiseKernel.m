function noiseKernelReComb = kernelSelection_createFirstNoiseKernel(noiseKernel,nSampled)
[nEle,nBars,nBoots] = size(noiseKernel);
nBootsBars = nBars * nBoots;
noiseBars = reshape(noiseKernel,[nEle,nBars * nBoots]);

noiseKernelReComb = zeros(nEle,nBars,nSampled);
for ii = 1:1:nSampled
    % find 20 bars from 
    a = randperm(nBootsBars);
    chosedBars = a(1:nBars);
    noiseKernelReComb(:,:,ii) = reshape(noiseBars(:,chosedBars),[nEle,nBars]);
end
end