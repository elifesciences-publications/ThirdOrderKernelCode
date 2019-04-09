% analyze new muiltibar flicker data.

clear
clc

Q.emailAddress = '2032988098@txt.att.net';
Q.sendEmail = true;


stimulusType = '5B';
barWidth = 5;
roiMethod = 'HHCA';
interpolateRespFlag = false;
filterRoiTraces = false;
% you also want to do the rep thing...
filepathAll = GetPathsFromDatabase('T4T5', 'multiBarFlicker_20_repBlock_60hz', 'GC6f', '','','date', '>', '2016-06-26');
nfile = length(filepathAll);
flyIDAll = GetFlyBehaviorIdFromDatabase(filepathAll);
flyEyeAll = cell(nfile,1);
for ff = 1:1:nfile
    flyEyeAll{ff} = GetEyeFromDatabase(filepathAll{ff});
end

% you have a function to get flyID before,
% first, get the ICA mask from the runanalysis.

prefNullCombo = 'bothPos';
switch prefNullCombo
    case 'bothPos'
        labelXNum = ([0:6 12 14])/60*1000;
        roundLabel = round(labelXNum(1:end-1), 1);
        labelXCell = [strsplit(num2str(roundLabel)), '\infty'];
    case 'prefPosNullNeg'
        labelXNum = ([-12 -6:6 12 14])/60*1000;
        roundLabel = round(labelXNum(1:end-1), 1);
        labelXCell = [strsplit(num2str(roundLabel)), '\infty'];
end
errorFile = [];
stimulusResponseAlignment = true;

plotNameAppend = ' plot higher thresh';
esiThreshCell = {0.3, 0.3, 0.4, 0.4};
epochsForSelection = {'~Left Light Edge', 'Left Dark Edge', 'Right Light Edge', 'Right Dark Edge';'~Right Light Edge', 'Right Dark Edge', 'Left Light Edge', 'Left Dark Edge';'~Left Dark Edge', 'Left Light Edge', 'Right Dark Edge', 'Right Light Edge';'~Right Dark Edge', 'Right Light Edge', 'Left Dark Edge', 'Left Light Edge'};
epochsForIdentification =  {'Square Left', 'Square Right', 'Square Up', 'Square Down', 'Left Light Edge', 'Left Dark Edge','Right Light Edge', 'Right Dark Edge'};
% epochsForSelection = {'~Right Light Edge', 'Right Dark Edge', 'Left Light Edge', 'Left Dark Edge'};

multibarAnalysis = RunAnalysis('dataPath', filepathAll, 'analysisFile', 'PlotTimeTraces', 'calcDFOverFByRoi', true, 'progRegSplit', true, 'prefNullCombo', prefNullCombo, 'esiThresh', esiThreshCell, 'roiExtractionFile','IcaRoiExtraction','epochsForIdentification',epochsForIdentification,'epochsForSelectivity',  epochsForSelection, 'forceRois', false, 'roiSelectionFile', '', 'filterMovie', false, 'stimulusResponseAlignment', false);
%%
for ff = 1:1:1
    try
        filepath = filepathAll{ff};
        flyEye = flyEyeAll{ff};
        flyID = flyIDAll(ff);
        % first of all, calculate the kernel for the background.
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
            'ROImethod','RoiIsBackGround','edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        % here, pretend you are using the filter
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',1,'maxTau',60,'doKernel',1,'doNoiseKernel',0,'saveKernels',0,'saveFlick',0,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',false,'interpolateRespFlag',interpolateRespFlag);
        filterRoiTraces_Utils_SaveBackgroundKernel(Z);
        
        % get the edge response and select the rois which you want to use.
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',true,...
            'ROImethod',roiMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',true);
        Z = CullRoiTracesKernel(Z);
        [Z, roiSelected] = RoiSelectionPreliminary(Z,flyEye,[]); % use edges. and use the same information to select rois later on. but the Z structure would be changed.
        [cfRoi,roiTrace] = RoiClassification(Z,flyEye);

        % third, calculate the first and second order kernel,
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
            'ROImethod',roiMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        Z = CullRoiTracesKernel(Z);
        Z = RoiSelectionPreliminary(Z,flyEye,roiSelected);
        
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',1,'maxTau',60,'doKernel',1,'doNoiseKernel',1,'saveKernels',1,'saveFlick',1,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',interpolateRespFlag);
        flickpath = Z.flick.fullFlickPathName;
        firstkernelpath = Z.kernels.fullKernelPathName;
        firstnoisepath = Z.noiseKernels.fullKernelPathName;
        
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',1,'doNoiseKernel',0,'saveKernels',1,'saveFlick',0,'dx',1,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',interpolateRespFlag);
        secondkernelpathNearest = Z.kernels.fullKernelPathName;
        secondnoisepath = '';
        
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',1,'doNoiseKernel',0,'saveKernels',1,'saveFlick',0,'dx',2,'repCVFlag',false,...
            'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',interpolateRespFlag);
        secondkernelpathNextNearest = Z.kernels.fullKernelPathName;
        
        
        roiData = RoiOrganizeOneFly(Z,flyEye,flyID,cfRoi,roiTrace,...
            filepath,flickpath,firstkernelpath,secondkernelpathNearest,secondkernelpathNextNearest,firstnoisepath,secondnoisepath,barWidth);
        
        S = GetSystemConfiguration;
        kernelPath = S.kernelSavePath;
        flickpath = KernelPathManage_DeleteAbsolutePath(flickpath,kernelPath);
        firstkernelpath = KernelPathManage_DeleteAbsolutePath(firstkernelpath,kernelPath);
        firstnoisepath = KernelPathManage_DeleteAbsolutePath(firstnoisepath,kernelPath);
        secondkernelpathNearest = KernelPathManage_DeleteAbsolutePath(secondkernelpathNearest,kernelPath);
        secondnoisepath = KernelPathManage_DeleteAbsolutePath(secondnoisepath,kernelPath);
        secondkernelpathNextNearest = KernelPathManage_DeleteAbsolutePath(secondkernelpathNextNearest,kernelPath);
        
        
        path.flickpath = flickpath;
        path.firstkernelpath= firstkernelpath;
        path.firstnoisepath = firstnoisepath;
        path.secondkernelpathNearest = secondkernelpathNearest;
        path.secondnoisepath = secondnoisepath;
        path.secondkernelpathNextNearest = secondkernelpathNextNearest;
        
        AutoLogKernelPath(Z.params.name,'ICA_DFOVERF_WithBT_EdgeCorrected',path);
        
        disp('organize all the data for this fly');
        size(roiData)
        
        dataStorePath = ['D:\JuyueLog\2016_10_04\raw\HHCA_T4T5_BT_EdgeCorrected'];
        cd(dataStorePath);
        save(['Data',stimulusType,roiMethod,'_',num2str(1)],'roiData','-v7.3');
        
        clear Z
        Q.messageToSend = ['Done! How about them apples?','ff = ', num2str(71)];
        SendNotification(Q);
    catch err
        Q.messageToSend = ['We''ve errored, boss :( on fly', num2str(ff)] ;
        SendNotification(Q);
        errorFile = [errorFile,ff];
    end
end
%% preprocessing. compute the 1o distance. compute 
clc
clear

Q.emailAddress = '2032988098@txt.att.net';
Q.sendEmail = true;

stimulusType = '5B';
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
twoPhotoPathLocal = S.twoPhotonDataPathLocal;
twoPhotoPathLocal(end) = [];

dataGetPath = ['D:\JuyueLog\2016_10_04\raw\HHCA_T4T5_BT_EdgeCorrected\'];
dataStorePath = ['D:\JuyueLog\2016_10_04\processed\','HHCA_T4T5_BT_EdgeCorrected\'];
dataStorePath2 = ['D:\JuyueLog\2016_10_04\processed\','HHCA_T4T5_BT_EdgeCorrected_1oD_NoFirstFrame\'];

dataGetInfo = dir([dataGetPath,'*.mat']);
nDataFile = length(dataGetInfo);
fileUse = [1];
for ii = 1:1:1;
    try
          tic
        filename = dataGetInfo(ii).name;
        filefullpath = [dataGetPath,filename];
        load(filefullpath); % what is the data?
        filepath  = roiData{1}.stimInfo.filepath; % change to relative path?
        filepath = [twoPhotoPathLocal,filepath];
        Z = twoPhotonMaster('filename',filepath,...
            'ROImethod','HHCA','edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        flyEye = roiData{1}.flyInfo.flyEye;
        
        % get the still traces...
        Z = CullRoiTracesKernel(Z);
        Z = RoiSelectionPreliminary(Z,flyEye);
        trace = GetTheStillTraces(Z);
        % there might be more
        % check whether the number of nroi is matching...
        nRoiRoiData = length(roiData);
        nRoiTrace = size(trace,3);
        if isequal(nRoiTrace,nRoiRoiData)
            for rr = 1:1:nRoiRoiData
                roiData{rr}.typeInfo.stillTrace = trace(:,:,rr);
            end
        else
            error('two data set is not matching');
        end
        
        % get the firstOrderKernelSelected.
        for rr = 1:1:length(roiData)
            roiData{rr}.filterInfo.kernelType = 3;
        end
        roiData = roiAnalysis_OneFly_KernelSelectoin_MultiD_1o(roiData,'plotFlag',false,'getRidOfFirstFrameFlag',false);
        filefullpath = [dataStorePath,filename];
        save(filefullpath,'roiData','-v7.3');
        toc
        disp([num2str(ii), 'is finished']);
        
        roiData = roiAnalysis_OneFly_KernelSelectoin_MultiD_1o(roiData,'plotFlag',false,'getRidOfFirstFrameFlag',true);
        filefullpath = [dataStorePath2,filename];
        save(filefullpath,'roiData','-v7.3');
        toc
        disp([num2str(ii), 'is finished']);
        
    catch err
%         keyboard
        Q.messageToSend = ['Done! Non RepFile','ff = ', num2str(ii)];
        SendNotification(Q);
    end
end

%% Do the second order noisy kernel

clc
clear

Q.emailAddress = '2032988098@txt.att.net';
Q.sendEmail = true;

stimulusType = '5B';
roiMethod = 'ICA_DFOVERF';
S = GetSystemConfiguration;
twoPhotonDataPath = S.twoPhotonDataPathLocal;
twoPhotonDataPath(twoPhotonDataPath == '/') = '\';
twoPhotonDataPath(end) = [];
kernelFolder = S.kernelSavePath;

dataGetPath = ['C:\Users\Clark Lab\Documents\Juyue_log\2016_10_04\processed\','ICA_DFOVERF_T4T5_BT_EdgeCorrected','\'];
dataStorePath = ['C:\Users\Clark Lab\Documents\Juyue_log\2016_10_04\processed\','ICA_DFOVERF_T4T5_BT_EdgeCorrected_with2oNoisy','\'];

dataGetInfo = dir([dataGetPath,'*.mat']);
nDataFile = length(dataGetInfo);
for ii = 1:1:nDataFile;
    try
        tic
        filename = dataGetInfo(ii).name;
        filefullpath = [dataGetPath,filename];
        load(filefullpath);
        
        % extract second order kernel.
        % you have first get the edge response.
        % and then second. background kernel is already there.
        filepath = [twoPhotonDataPath,roiData{1}.stimInfo.filepath];
        flyEye = roiData{1}.flyInfo.flyEye;
        % get the edge response and select the rois which you want to use.
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',true,...
            'ROImethod',roiMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        Z = CullRoiTracesKernel(Z);
        [Z, roiSelected] = RoiSelectionPreliminary(Z,flyEye,[]); % use edges. and use the same information to select rois later on. but the Z structure would be changed.
        [cfRoi,roiTrace] = RoiClassification(Z,flyEye);
        
        % third, calculate the first and second order kernel,
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
            'ROImethod',roiMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        Z = CullRoiTracesKernel(Z);
        Z = RoiSelectionPreliminary(Z,flyEye,roiSelected);
        
        nRoiDataZ = size(Z.filtered.roi_avg_intensity_filtered_normalized,2);
        nRoiDataStored = length(roiData);
        if nRoiDataZ == nRoiDataStored
            Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',0,'doNoiseKernel',1,'saveKernels',1,'saveFlick',0,'dx',1,'repCVFlag',false,...
                'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',false);
            secondnoisepath = Z.noiseKernels.fullKernelPathName;
            secondnoisepathThisRoi = KernelPathManage_DeleteAbsolutePath(secondnoisepath,kernelFolder);
            for rr = 1:1:nRoiDataStored
                roiData{rr}.stimInfo.secondNoisePath  = secondnoisepathThisRoi;
            end
            roiData = roiAnalysis_OneFly_CalculateShuffleGliderResp(roiData);
            
            filefullpath = [dataStorePath,filename];
            save(filefullpath,'roiData','-v7.3');
            toc
            disp([num2str(ii), 'is finished']);
            Q.messageToSend = ['Done! Non RepFile','ff = ', num2str(ii)];
            SendNotification(Q);
            
        else
            error('Rois numbers are not matching');
        end
    catch err
        keyboard
        Q.messageToSend = ['Error! Non RepFile','ff = ', num2str(ii)];
        SendNotification(Q);
    end
end