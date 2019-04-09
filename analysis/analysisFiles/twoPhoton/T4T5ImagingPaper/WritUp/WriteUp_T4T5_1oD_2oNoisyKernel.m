%% preprocessing. compute the 1o distance. compute

function WriteUp_T4T5_1oD_2oNoisyKernel(data_folder_name,roiMethod_forTwoPhotonMaster)
stimulusType = '5B';
% roiMethod = 'WriteUp_T4T5_NewRoiMask_ICA';
folder_kernel_raw  = ['\T4T5_Imaging_Paper\raw\',data_folder_name,'\',stimulusType,'\'];
folder_kernel_processed =  ['\T4T5_Imaging_Paper\processed\',data_folder_name,'\',stimulusType,'\'];


S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
twoPhotoPathLocal = S.twoPhotonDataPathLocal;
twoPhotoPathLocal(end) = [];

% if there is not folder_kernel_processed, create it.
folder_kernel_raw = [kernelFolder, folder_kernel_raw];
folder_kernel_processed = [kernelFolder, folder_kernel_processed];

if ~exist(folder_kernel_processed,'file')
    mkdir(folder_kernel_processed);
end

dataGetInfo = dir([folder_kernel_raw,'*.mat']);
nDataFile = length(dataGetInfo);
for ii = 33:1:33;
    try
        tic
        filename = dataGetInfo(ii).name;
        filefullpath = [folder_kernel_raw,filename];
        load(filefullpath); % what is the data?
        filepath  = roiData{1}.stimInfo.filepath; % change to relative path?
        filepath = [twoPhotoPathLocal,filepath];
        Z = twoPhotonMaster('filename',filepath,...
            'ROImethod',roiMethod_forTwoPhotonMaster,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
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
        
        % extract second order kernel.
        % you have first get the edge response.
        % and then second. background kernel is already there.
        % get the edge response and select the rois which you want to use.
        clear Z
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',true,...
            'ROImethod',roiMethod_forTwoPhotonMaster,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        Z = CullRoiTracesKernel(Z);
        [Z, roiSelected] = RoiSelectionPreliminary(Z,flyEye,[]); % use edges. and use the same information to select rois later on. but the Z structure would be changed.    %
        Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
            'ROImethod',roiMethod_forTwoPhotonMaster,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        Z = CullRoiTracesKernel(Z);
        Z = RoiSelectionPreliminary(Z,flyEye,roiSelected);
        
        nRoiDataZ = size(Z.filtered.roi_avg_intensity_filtered_normalized,2);
        nRoiDataStored = length(roiData);
        if nRoiDataZ == nRoiDataStored
            Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',0,'doNoiseKernel',1,'saveKernels',1,'saveFlick',0,'dx',1,'repCVFlag',false,...
                'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',false,'roiMethod',roiMethod_forTwoPhotonMaster);
            secondnoisepath = Z.noiseKernels.fullKernelPathName;
            secondnoisepathThisRoi = KernelPathManage_DeleteAbsolutePath(secondnoisepath,kernelFolder);
            for rr = 1:1:nRoiDataStored
                roiData{rr}.stimInfo.secondNoisePath  = secondnoisepathThisRoi;
            end
            roiData = roiAnalysis_OneFly_CalculateShuffleGliderResp(roiData);
            
            filefullpath = [folder_kernel_processed,filename];
            save(filefullpath,'roiData','-v7.3');
            toc
        else
            error('two data set is not matching');
        end
    catch err
        %         keyboard
    end
end
end
