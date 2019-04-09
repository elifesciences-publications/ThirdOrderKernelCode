function [secondKernelFlag, secondBarSelected,maxConnectedAreaAll, maxNoiseConnectedAreaAll, kernelZAll, kernelSmoothZAll] ....
    = roiAnalysis_kernelSelection_Second_BasedOnConnectedLargeZ(roiData,varargin)
dx = 1;
threshP = 0.998; % might be changed in the future. could also be computed...% one is maximum
threshZ = 2.5;
order = 2;
selectionMethod = 'fullKernel'; % selectionMethod   = 'onlyDirectionSelective'
for ii = 1:2:length(varargin)
    str = [ varargin{ii} ' = varargin {' num2str(ii+1) '};'];
    eval(str);
end


S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
switch dx
    case 1
        secondkernelpath = roiData{1}.stimInfo.secondKernelPathNearest;
    case 2
        secondkernelpath = roiData{1}.stimInfo.secondKernelPathNextNearest;
end
secondkernelpath = [kernelFolder,secondkernelpath];
load(secondkernelpath);
kernelAll = saveKernels.kernels;

secondnoisepath = roiData{1}.stimInfo.secondNoisePath;
if isempty(secondnoisepath)
    nRoi = length(roiData);
    nSampled = 2000;
    [~,nMultiBars,nRoi] = size(kernelAll);
    secondKernelFlag = false(nRoi,1);
    secondBarSelected = false(nMultiBars,nRoi);
    maxConnectedAreaAll = zeros(nMultiBars,nRoi,1);
    maxNoiseConnectedAreaAll = zeros(nSampled,nRoi);
    kernelZAll = zeros(size(kernelAll));
    kernelSmoothZAll = zeros(size(kernelAll));
 
else
    secondnoisepath = [kernelFolder,secondnoisepath];
    load(secondnoisepath);
    noiseKernelsAll = saveKernels.kernels;
    
    
    
    [~,~,~,nRoi] = size(noiseKernelsAll);
    nRoiUse = length(roiData);
    roiSelected = false(nRoi,1);
    for rr = 1:1:nRoiUse
        roiNum = roiData{rr}.stimInfo.roiNum;
        roiSelected(roiNum) = true;
    end
    
    %%
    kernelAll = kernelAll(:,:,roiSelected);
    noiseKernelsAll = noiseKernelsAll(:,:,:,roiSelected);
    
    [nEle,nBoot,nMultiBars,nRoi] = size(noiseKernelsAll);
    
    if nRoi ~= nRoiUse
        error('number of selected rois is not equal to the number of roiData')
    end
    
    nSampled = nBoot * nMultiBars;
    %% prepare the value to be returned.
    secondKernelFlag = false(nRoi,1);
    secondBarSelected = false(nMultiBars,nRoi);
    maxConnectedAreaAll = zeros(nMultiBars,nRoi,1);
    maxNoiseConnectedAreaAll = zeros(nSampled,nRoi);
    kernelZAll = zeros(size(kernelAll));
    kernelSmoothZAll = zeros(size(kernelAll));
    %%
    tic
    for rr = 1:1:nRoi
        
        % prepare for kernel and noise kernel for this roi...
        kernel = kernelAll(:,:,rr);
        noiseKernel = permute(noiseKernelsAll(:,:,:,rr),[1,3,2]);
        switch selectionMethod
            case 'fullKernel'
                [kernelZ,kernelSmoothZ,maxConnectedArea,maxNoiseConnectedArea] = kernelSelection_Second_OneKernelBasedOnConnectedLargeZ(kernel,noiseKernel,'threshZ',threshZ);
            case 'onlyDirectionSelective'
                [kernelZ,maxConnectedArea,maxNoiseConnectedArea] = kernelSelection_Second_OneKernelBasedOnConnectedLargeZAndUnsym(kernel,noiseKernel,'threshZ',threshZ);
                kernelSmoothZ = zeros(size(kernel));
        end
        % actually, if you are not satisfield about the threshold inside, you could
        % do that again outside. do you want to do that? sure!
        maxConnectedAreaAll(:,rr) = maxConnectedArea;
        maxNoiseConnectedAreaAll(:,rr) = maxNoiseConnectedArea;
        kernelZAll(:,:,rr) = kernelZ;
        kernelSmoothZAll(:,:,rr) = kernelSmoothZ;
        % keep the kernelZ and kernelSmoothZ. you might have to plot them
    end
    toc
    
    for rr = 1:1:nRoi
        
        maxNoiseConnectedArea = maxNoiseConnectedAreaAll(:,rr);
        maxConnectedArea = maxConnectedAreaAll(:,rr);
        threshMaxConnecterArea = percentileThresh(maxNoiseConnectedArea,threshP);
        barSelected = maxConnectedArea >  threshMaxConnecterArea;
        secondBarSelected(:,rr) = barSelected;
    end
    
    secondKernelFlag = sum(secondBarSelected) > 0;
end
end
% seems okay... just use it... do not want to change anymore...
% kernelShow = [];
% for rr = 1:1:nRoi
%     barSelected = secondKernelBarSelected(:,rr);
%     kernelShow = [kernelShow,kernelZAll(:,barSelected,rr)];
% end
% quickViewKernelsSecond(kernelShow);