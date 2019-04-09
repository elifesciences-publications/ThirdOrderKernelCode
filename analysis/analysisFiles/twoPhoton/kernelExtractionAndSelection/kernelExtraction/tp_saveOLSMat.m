function fullOLSMatPathName = tp_saveOLSMat(filename,OLSMatSave,kernelTypeStr,specialName)
% Takes the aligned output and flickerSelectAndAlign and saves, along with
% identifying information.
        
    if nargin < 3
        specialName = [];
    end
  %% 1. Select Path
    % Create folder path for kernel - master folder specified by
    % dataPath.csv, subfolder reflecting date of extraction.
    S = GetSystemConfiguration;
    OLSFolder = S.kernelSavePath;

    OLSMatFolderPath = sprintf('%s/twoPhoton/%s/%s',OLSFolder,filename,datestr(now,'dd_mm_yy'));         
    if ~isdir(OLSMatFolderPath)
        mkdir(OLSMatFolderPath);              
    end         
    %% 2. Organize parts of Z to save  
    OLSMatName = sprintf('OLSMat_%s_%s',kernelTypeStr,datestr(now,'HH_MM'));
    fullOLSMatPathName = sprintf('%s/%s', OLSMatFolderPath, OLSMatName);
    save(fullOLSMatPathName,'OLSMatSave','-v7.3');   
    fprintf('The flick has saved.\n',OLSMatName);
       
end
