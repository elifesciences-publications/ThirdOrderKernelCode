function [roi_data_path_return, exist_a_file_flag] = runAnalysis_utils_GetRoiDataStructurePath(filepath, data_subfolder, RoiIdentificationMethod, stash_name, varargin)
return_folder_name = false;
retrun_latest_file = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% you always get full path here.
S = GetSystemConfiguration;
twoPhotonDataPathLocal = S.twoPhotonDataPathLocal;
filename_relativepath = filepath(length(twoPhotonDataPathLocal)+1:end);
filename_save_roidata = filename_relativepath;

S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;

roi_data_store_path = sprintf('%s/T4T5_roi_data/%s/%s/', kernelPath,filename_save_roidata, data_subfolder);
roi_data_store_file_name = [RoiIdentificationMethod,'_',stash_name]; % first, look at the first order kernel, if it is really good, proceed to do covariance matrix.
roi_data_store_path_search = [roi_data_store_path, roi_data_store_file_name,'*.mat'];
roi_data_store_path_search(roi_data_store_path_search == '/') = '\';
datafile = dir(roi_data_store_path_search);

if ~isempty(datafile)
    exist_a_file_flag = true;
else
    exist_a_file_flag = false;
end
if return_folder_name
    roi_data_path_return = roi_data_store_path;
else
    if retrun_latest_file
        [~,newestInd] = max(arrayfun(@(file)datenum(file.name(regexp(file.name, '\d+_\d+_\d+_\d+_\d+','start'): regexp(file.name, '\d+_\d+_\d+_\d+_\d+','end')),'yy_mm_dd_HH_MM'),datafile));
        roi_data_store_path_full = {[roi_data_store_path,datafile(newestInd).name]};
    else
        roi_data_store_path_full = arrayfun(@(file) [roi_data_store_path,file.name],datafile,'UniformOutput',false);
    end
    roi_data_path_return = roi_data_store_path_full;
end