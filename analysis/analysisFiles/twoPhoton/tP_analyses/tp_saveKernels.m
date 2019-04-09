function file_name_full = tp_saveKernels(filename,kernel,kernelTypeStr,specialName, data_source)
%% take in kernel structure and flick structure.
%%
if nargin < 4
    specialName = [];
end

%% create a folder.
S = GetSystemConfiguration;
switch data_source
    case 'twoPhoton'
        kernelFolder = S.kernelSavePath_twoPhoton;
    case 'behavior'
        kernelFolder = S.kernelSavePath_behavior;
end

% should get rid of the time here...
kernelFolderPath = fullfile(kernelFolder,filename);
if ~isdir(kernelFolderPath)
    mkdir(kernelFolderPath);
end
%% 2. Organize parts of Z to save
% Save the entire kernels output of Z,datestr(now,'dd_mm_yy')
kernelName = sprintf('%s_%s_%s',kernelTypeStr,specialName,datestr(now,'yy_mm_dd_HH_MM'));
file_name_full = sprintf('%s/%s',kernelFolderPath,kernelName);

% if it is kernel

if isstruct(kernel)
    if isfield(kernel,'respData');
        flickSave = kernel;% could be flick or ols, which includes ks and kr.
        % if it is a struct, it is probablily a flick structure.
        save(file_name_full ,'flickSave','-v7.3');
    end
    
    if isfield(kernel, 'kr')
        arma_ols_first = kernel;% could be flick or ols, which includes ks and kr.
        % if it is a struct, it is probablily a flick structure.
        save(file_name_full ,'arma_ols_first','-v7.3');
        
    end
    
elseif (iscell(kernel) && isfield(kernel{1}, 'stimInfo'))
    roiData = kernel;
    save(file_name_full ,'roiData','-v7.3');
else
    saveKernels.kernels = kernel; % kernel.
    save(file_name_full ,'saveKernels','-v7.3');
    fprintf('The kernels for %s have extracted and saved.\n',kernelName);
end
% if it is flick.




end