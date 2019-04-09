function WriteUp_T4T5_Paper_KernelExtraction(filepathAll,data_folder_name,roiMethod_forTwoPhotonMaster,roiMethod_forBackground, force_new_roi)
% flyNumOffSet = 2; % did not check who it is.

S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
twoPhotoPathLocal = S.twoPhotonDataPathLocal;
twoPhotoPathLocal(end) = [];


stimulusType = '5B'; 
barWidth = 5;
% roiMethod = 'WriteUp_T4T5_NewRoiMask_ICA';
% filterRoiTraces = false;
interpolateRespFlag = false;
folder_kernel_raw = ['\T4T5_Imaging_Paper\raw\',data_folder_name,'\',stimulusType,'\'];
folder_kernel_raw = [kernelFolder, folder_kernel_raw];

if ~exist(folder_kernel_raw,'file')
    mkdir(folder_kernel_raw);
end

%% Kernel Extraction. using 
nfile = length(filepathAll);
flyIDAll = GetFlyBehaviorIdFromDatabase(filepathAll);
flyEyeAll = cell(nfile,1);
for ff = 1:1:nfile
    flyEyeAll{ff} = GetEyeFromDatabase(filepathAll{ff});
end

errorFile = [];
startingFile = 1;
endingFile = nfile;
for ff = startingFile:1:endingFile
    try
        filepath = filepathAll{ff};
        flyEye = flyEyeAll{ff};
        flyID = flyIDAll(ff);
        % first of all, calculate the kernel for the background.
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
            'ROImethod',roiMethod_forBackground,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',force_new_roi);
        % here, pretend you are using the filter
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',1,'maxTau',60,'doKernel',1,'doNoiseKernel',0,'saveKernels',0,'saveFlick',0,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',false,'interpolateRespFlag',interpolateRespFlag,'roiMethod',roiMethod_forTwoPhotonMaster);
        filterRoiTraces_Utils_SaveBackgroundKernel(Z);
        
        % get the edge response and select the rois which you want to use.
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',true,...
            'ROImethod',roiMethod_forTwoPhotonMaster,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',force_new_roi);
        Z = CullRoiTracesKernel(Z);
        [Z, roiSelected] = RoiSelectionPreliminary(Z,flyEye,[]); % use edges. and use the same information to select rois later on. but the Z structure would be changed.
        [cfRoi,roiTrace] = RoiClassification(Z,flyEye);

        % third, calculate the first and second order kernel,
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
            'ROImethod',roiMethod_forTwoPhotonMaster,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        Z = CullRoiTracesKernel(Z);
        Z = RoiSelectionPreliminary(Z,flyEye,roiSelected);
        
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',1,'maxTau',60,'doKernel',1,'doNoiseKernel',1,'saveKernels',1,'saveFlick',1,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',interpolateRespFlag, 'roiMethod',roiMethod_forTwoPhotonMaster);
        flickpath = Z.flick.fullFlickPathName;
        firstkernelpath = Z.kernels.fullKernelPathName;
        firstnoisepath = Z.noiseKernels.fullKernelPathName;
        
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',1,'doNoiseKernel',0,'saveKernels',1,'saveFlick',0,'dx',1,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',interpolateRespFlag, 'roiMethod',roiMethod_forTwoPhotonMaster);
        secondkernelpathNearest = Z.kernels.fullKernelPathName;
        secondnoisepath = '';
        
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',1,'doNoiseKernel',0,'saveKernels',1,'saveFlick',0,'dx',2,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',interpolateRespFlag, 'roiMethod',roiMethod_forTwoPhotonMaster);
        secondkernelpathNextNearest = Z.kernels.fullKernelPathName;
        
        
        roiData = RoiOrganizeOneFly(Z,flyEye,flyID,cfRoi,roiTrace,...
            filepath,flickpath,firstkernelpath,secondkernelpathNearest,secondkernelpathNextNearest,firstnoisepath,secondnoisepath,barWidth);
       
      
        dataStorePath = [folder_kernel_raw];
        cd(dataStorePath);
        save(['Data',stimulusType,roiMethod_forTwoPhotonMaster,'_',num2str(1)],'roiData','-v7.3');
        
        clear Z
    catch err
        errorFile = [errorFile,ff];
    end
end

%% continue on the post processing.
end
%% Super fly for the expression

%% Signal to noise estimation using repeated segments.