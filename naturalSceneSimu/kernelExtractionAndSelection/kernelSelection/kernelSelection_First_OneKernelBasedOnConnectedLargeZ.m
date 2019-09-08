function [kernelZ,kernelSmoothZ,barSelected,maxConnectedArea,maxNoiseConnectedArea] = kernelSelection_First_OneKernelBasedOnConnectedLargeZ(kernel, noiseKernel,varargin)
nSampled = 1000; % 1000 number, took 0.3 seconds for one roi.
threshZ = 2;
plotFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% the flag will be put out of the function...

[nEle,nMultiBars,nBoot] = size(noiseKernel);
barSelected = false(nMultiBars,1);
noiseBars = reshape(noiseKernel,[nEle,nMultiBars * nBoot]);
entryStd = std(noiseBars(:));
kernelZ = kernel/entryStd;
% noiseKernelZ = noiseKernel/entryStd;

%% calculat the smoothed kernel.
smoothRange = 5;
h_smooth = fspecial('gaussian',smoothRange);
kernel_smooth = MyImfilter(kernel,h_smooth,smoothRange,1);

%%
noiseKernelReComb = kernelSelection_createFirstNoiseKernel(noiseKernel,nSampled);
noiseKernel_smooth = zeros(size(noiseKernelReComb));
for ii = 1:1:nSampled
    noiseKernel_smooth(:,:,ii) =  MyImfilter(noiseKernelReComb(:,:,ii),h_smooth,smoothRange,1);
end
% calculate the stdard deviate for each entry and 
entryStdSmooth = zeros(nEle,1);
for jj = 1:1:nEle
    a = noiseKernel_smooth(jj,:,:);
    entryStdSmooth(jj) = std(a(:));
end
% entryStd_smooth = sqrt(sum(h_smooth(:).^2)) * entryStd; % analytical result, not suitable for the first and last entries of smoothed kernel.
kernelSmoothZ = kernel_smooth./repmat(entryStdSmooth,[1,nMultiBars]);
noiseKernelSmoothZ =  noiseKernel_smooth./repmat(entryStdSmooth,[1,nMultiBars,nSampled]);

%% used the smoothed kernel to find the region...
[maxConnectedArea,barSelected] = kernelSelection_First_CalculateMaximunConnectedRegion(kernelSmoothZ,'plotFlag',plotFlag,'threshZ',threshZ);
maxNoiseConnectedArea = zeros(nSampled,1);
for ii = 1:1:nSampled
    [maxNoiseConnectedArea(ii),~] = kernelSelection_First_CalculateMaximunConnectedRegion(noiseKernelSmoothZ(:,:,ii),'threshZ',threshZ);
end
end