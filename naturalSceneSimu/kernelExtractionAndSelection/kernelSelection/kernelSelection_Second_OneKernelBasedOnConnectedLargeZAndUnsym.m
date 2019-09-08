function [kernelZ,maxConnectedArea,maxNoiseConnectedArea] = kernelSelection_Second_OneKernelBasedOnConnectedLargeZAndUnsym(kernel,noiseKernel,varargin)

threshZ = 3;
plotFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[nEle,nMultiBars,nBoot] = size(noiseKernel);
nSampled  = nBoot * nMultiBars;
noiseKernel = reshape(noiseKernel,[nEle,nSampled]);
entryStd = std(noiseKernel(:));
% mean is almost zero...
kernelZ = kernel/entryStd;
%%
%% do this for all the noisy kernels,
kernelSym = zeros(size(kernel));
noiseKernelSym = zeros(size(noiseKernel));
kernelSymSmooth = zeros(size(kernel));
noiseKernelSymSmooth = zeros(size(noiseKernel));
a = 0.2;
h_smooth = [a/2,a/4,0,0;a/4,a,a/2,0;0,a/2,a,a/4;0,0,a/4,a/2];

for qq = 1:1:nMultiBars
    kernelSym(:,qq) = KernelSelection_Second_Utils_SymAndUpDia(kernel(:,qq));
    kernelSymSmooth(:,qq) =  MyImfilter(kernelSym(:,qq),h_smooth,0,2);
end

for ii = 1:1:nSampled
    noiseKernelSym(:,ii) = KernelSelection_Second_Utils_SymAndUpDia(noiseKernel(:,ii));
    noiseKernelSymSmooth(:,ii) = MyImfilter(noiseKernelSym(:,ii),h_smooth,0,2);
end

% calculate Z value from the smoothed kernel.
entryStdSymSmooth = std(noiseKernelSymSmooth,1,2);
entryStdSymSmooth(entryStdSymSmooth == 0) = 1e9;
kernelSymSmoothZ = kernelSymSmooth./repmat(entryStdSymSmooth,[1,nMultiBars]);
noiseKernelSymSmoothZ = noiseKernelSymSmooth./repmat(entryStdSymSmooth,[1,nSampled]);


%%
maxConnectedArea = zeros(nMultiBars,1);
for qq = 1:1:nMultiBars
    maxConnectedArea(qq)  = kernelSelection_Second_CalculateMaximunConnectedRegion(kernelSymSmoothZ(:,qq),'threshZ',threshZ,'plotFlag',plotFlag,'direction',1);
end

maxNoiseConnectedArea = zeros(nSampled,1);
for ii = 1:1:nSampled
    maxNoiseConnectedArea(ii) = kernelSelection_Second_CalculateMaximunConnectedRegion(noiseKernelSymSmoothZ(:,ii),'threshZ',threshZ,'direction',1);
end

end
