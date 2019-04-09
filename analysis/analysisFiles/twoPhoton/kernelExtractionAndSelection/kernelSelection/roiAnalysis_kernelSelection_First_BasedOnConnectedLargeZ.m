function [firstKernelFlag, firstKernelBarSelected,maxConnectedAreaAll, maxNoiseConnectedAreaAll, kernelZAll, kernelSmoothZAll] ...
    = roiAnalysis_kernelSelection_First_BasedOnConnectedLargeZ(roiData)
% you know that the flies in this roi all come from same fly.
nSampled = 1000;
threshZ = 2;
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;

    
firstkernelpath = roiData{1}.stimInfo.firstKernelPath;
firstkernelpath = [kernelFolder,firstkernelpath];
firstnoisepath = roiData{1}.stimInfo.firstNoisePath;
firstnoisepath = [kernelFolder,firstnoisepath];
% before loading kernel, 
load(firstkernelpath);
kernelAll = saveKernels.kernels;
load(firstnoisepath);
noiseKernelsAll = saveKernels.kernels;

%%
[~,~,nMultiBars,nRoi] = size(noiseKernelsAll);

nRoiUse = length(roiData);
roiSelected = false(nRoi,1);
for rr = 1:1:nRoiUse
    roiNum = roiData{rr}.stimInfo.roiNum;
    roiSelected(roiNum) = true;
end

%%
kernelAll = kernelAll(:,:,roiSelected);
noiseKernelsAll = noiseKernelsAll(:,:,:,roiSelected);
[~,~,nMultiBars,nRoi] = size(noiseKernelsAll);
if nRoi ~= nRoiUse
 error('number of selected rois is not equal to the number of roiData')
end
%%
firstKernelFlag = false(nRoiUse,1);
firstKernelBarSelected = false(nMultiBars,nRoiUse);
maxConnectedAreaAll = zeros(nRoiUse,1);
maxNoiseConnectedAreaAll = zeros(nSampled,nRoiUse);
kernelZAll = zeros(size(kernelAll));
kernelSmoothZAll = zeros(size(kernelAll));

% deal with the fly one by one, not all of them....
% you should do it which way?? not sure....
for rr = 1:1:nRoiUse
    % before smooth, double the thing and smooth things.
    % do not use the first and second...
    kernel = kernelAll(:,:,rr);
    noiseKernel = permute(noiseKernelsAll(:,:,:,rr),[1,3,2]);
    [kernelZ,kernelSmoothZ,barSelected,maxConnectedArea,maxNoiseConnectedArea] = kernelSelection_First_OneKernelBasedOnConnectedLargeZ(kernel, noiseKernel,'threshZ',threshZ,'nSampled',nSampled);
    
    firstKernelBarSelected(:,rr) = barSelected;
    maxConnectedAreaAll(rr) = maxConnectedArea;
    maxNoiseConnectedAreaAll(:,rr) = maxNoiseConnectedArea;
    kernelZAll(:,:,rr) = kernelZ;
    kernelSmoothZAll(:,:,rr) = kernelSmoothZ;
end
for rr = 1:1:nRoiUse
    if maxConnectedAreaAll(rr) > max(maxNoiseConnectedAreaAll(:,rr))
        firstKernelFlag(rr) = true;
    end
end
end