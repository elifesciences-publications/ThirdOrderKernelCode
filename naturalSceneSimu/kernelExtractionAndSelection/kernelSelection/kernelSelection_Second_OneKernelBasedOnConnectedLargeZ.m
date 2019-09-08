function [kernelZ,kernelSmoothZ,maxConnectedArea,maxNoiseConnectedArea] = kernelSelection_Second_OneKernelBasedOnConnectedLargeZ(kernel,noiseKernel,varargin)

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
% noiseKernelZ = noiseKernel/entryStd;

%% do the smooth...it could not work very well, but at least better than nothing...

% for one roi, it takes 0.6 second.
a = 0.2;
h_smooth = [a/2,a/4,0,0;a/4,a,a/2,0;0,a/2,a,a/4;0,0,a/4,a/2];
kernelSmooth = zeros(size(kernel));
noiseKernelSmooth = zeros(size(noiseKernel));
for qq = 1:1:nMultiBars
    kernelSmooth(:,qq) = MyImfilter(kernel(:,qq),h_smooth,0,2); 
end
for ii = 1:1:nSampled
    noiseKernelSmooth(:,ii) = MyImfilter(noiseKernel(:,ii),h_smooth,0,2);
end
%%
entryStdSmooth = std(noiseKernelSmooth,1,2);
% entryMeanSmooth = mean(noiseKernelSmooth,2);
% MakeFigure;
% % quickViewOneKernel(entryStdSmooth,2);
% quickViewOneKernel(entryMeanSmooth,2);
% MakeFigure;
% histogram(kernelSmooth(:))
% analytical result; entryStdSmooth = sqrt(sum(h_smooth(:).^2)) * entryStd
%% assume the mean value is zero.
kernelSmoothZ = kernelSmooth./repmat(entryStdSmooth,[1,nMultiBars]);
noiseKernelSmoothZ = noiseKernelSmooth./repmat(entryStdSmooth,[1,nSampled]);

%%
maxConnectedArea = zeros(nMultiBars,1);
for qq = 1:1:nMultiBars
    maxConnectedArea(qq)  = kernelSelection_Second_CalculateMaximunConnectedRegion(kernelSmoothZ(:,qq),'threshZ',threshZ,'plotFlag',plotFlag);
end

maxNoiseConnectedArea = zeros(nSampled,1);
for ii = 1:1:nSampled
   maxNoiseConnectedArea(ii) = kernelSelection_Second_CalculateMaximunConnectedRegion(noiseKernelSmoothZ(:,ii),'threshZ',threshZ );
end

end
