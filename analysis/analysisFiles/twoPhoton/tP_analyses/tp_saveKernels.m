function fullKernelPathName = tp_saveKernels(filename,kernel,kernelTypeStr,specialName )
% Takes the kernels in Z and saved them, along with some necessary
% information about how they were extracted, in the kernels folder
% specified in dataPath.csv
    
    if nargin < 2
        specialName = [];
    end
    
    %% 1. Select Path
    % Create folder path for kernel - master folder specified by
    % dataPath.csv, subfolder reflecting date of extraction.
%     HPathIn = fopen('dataPath.csv');
%     C = textscan(HPathIn,'%s');
%     kernelFolder = C{1}{3};
%     
    S = GetSystemConfiguration;
    kernelFolder = S.kernelSavePath;
%     kernelFolder = 'C:\Users\labuser\Documents\kernels';
    kernelFolderPath = sprintf('%s/twoPhoton/%s/%s',kernelFolder,filename,datestr(now,'dd_mm_yy'));         
    if ~isdir(kernelFolderPath)
        mkdir(kernelFolderPath);              
    end         
    
    %% 2. Organize parts of Z to save    
    % Save the entire kernels output of Z
    kernelName = sprintf('%s%s_%s',kernelTypeStr,specialName,datestr(now,'HH_MM'));
    saveKernels.kernels = kernel; % kernel. 
    fullKernelPathName = sprintf('%s/%s',kernelFolderPath,kernelName);
    save(fullKernelPathName,'saveKernels','-v7.3');   
    fprintf('The kernels for %s have extracted and saved.\n',kernelName);
    
end

