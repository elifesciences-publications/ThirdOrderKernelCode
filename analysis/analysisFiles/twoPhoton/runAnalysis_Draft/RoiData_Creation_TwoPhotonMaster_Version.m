function  roi_data = RoiData_Creation_TwoPhotonMaster_Version(filepath, RoiIdentificationMethod)
curfolder = pwd;
barWidth = 5;
% you should read this from parameter
analysis_method_identifier.ROI_indenfication_method = RoiIdentificationMethod;
filepath_parts = strsplit(filepath, '/'); filepath_parts(end) = [];
filepath_for_eye = strjoin(filepath_parts,'/');
fly_eye = GetEyeFromDatabase(filepath_for_eye );
fly_ID = GetFlyBehaviorIdFromDatabase({filepath_for_eye});

% get the edge response and select the rois which you want to use.
Z = twoPhotonMaster('filename',filepath, 'subtractBackgroundSeparately',false,'filterTracesFlag',true,...
    'ROImethod',RoiIdentificationMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
Z = CullRoiTracesKernel(Z);
[Z, ~] = RoiSelectionPreliminary(Z,fly_eye,[]); % use edges. and use the same information to select rois later on. but the Z structure would be changed.
[cfRoi,roiTrace] = RoiClassification(Z,fly_eye);
roi_data = RoiOrganizeOneFly_Edge(Z,filepath,fly_eye,fly_ID,barWidth,cfRoi,roiTrace, analysis_method_identifier);
cd(curfolder);
end