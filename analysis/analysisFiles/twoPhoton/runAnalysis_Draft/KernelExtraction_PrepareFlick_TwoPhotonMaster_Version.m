function flickSave = KernelExtraction_PrepareFlick_TwoPhotonMaster_Version(filepath, roiMethod_forBackground, RoiIdentificationMethod, kernel_special_name)
curfolder = pwd;
% first of all, calculate the kernel for the background.
kernel_special_name = [];
interpolateRespFlag = false;
% extract filters for all of them? or after some selection.
% change the filepath there.
% write a if statement, and change the filepath...
filepath_parts = strsplit(filepath, '/'); filepath_parts(end) = [];
filepath_for_eye = strjoin(filepath_parts,'/');
flyEye = GetEyeFromDatabase(filepath_for_eye);
Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
    'ROImethod',roiMethod_forBackground,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
% here, pretend you are using the filter
Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',1,'maxTau',60,'doKernel',1,'doNoiseKernel',0,'saveKernels',0,'saveFlick',0,'repCVFlag',false,...
    'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',false,'interpolateRespFlag',interpolateRespFlag,...
    'roiMethod',roiMethod_forBackground, 'kernel_special_name',kernel_special_name);
filterRoiTraces_Utils_SaveBackgroundKernel(Z);
clear Z
% get the edge response and select the rois which you want to use.
Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',true,...
    'ROImethod',RoiIdentificationMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
Z = CullRoiTracesKernel(Z);
[Z, roiSelected] = RoiSelectionPreliminary(Z,flyEye,[]); % use edges. and use the same information to select rois later on. but the Z structure would be changed.

% third, calculate the first and second order kernel,
Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',false,...
    'ROImethod',RoiIdentificationMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
Z = CullRoiTracesKernel(Z);
Z = RoiSelectionPreliminary(Z,flyEye,roiSelected);


%% flick 
% save things outside. only compute here.
Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',1,'maxTau',60,'doKernel',0,'doNoiseKernel',0,'saveKernels',0,'saveFlick',0,'repCVFlag',false,...
    'filterTracesFlag',false,'subtractBackgroundSeparately',false,'subtractBleedThroughFlag',true,'interpolateRespFlag',interpolateRespFlag,...
    'roiMethod',RoiIdentificationMethod, 'kernel_special_name',kernel_special_name);
flickSave= Z.flick.flickSave;
cd(curfolder)
end