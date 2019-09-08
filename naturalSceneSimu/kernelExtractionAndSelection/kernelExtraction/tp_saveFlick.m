function fullflickPathName = tp_saveFlick(filename,flickSave,kernelTypeStr,specialName)
% Takes the aligned output and flickerSelectAndAlign and saves, along with
% identifying information.
        
    if nargin < 3
        specialName = [];
    end
  %% 1. Select Path
    % Create folder path for kernel - master folder specified by
    % dataPath.csv, subfolder reflecting date of extraction.
    S = GetSystemConfiguration;
    folder = S.kernelSavePath;

    folderPath = sprintf('%s/twoPhoton/%s/%s',folder,filename,datestr(now,'dd_mm_yy'));         
    if ~isdir(folderPath)
        mkdir(folderPath);              
    end         
    %% 2. Organize parts of Z to save  
    fileName = sprintf('flick_%s_%s',kernelTypeStr,datestr(now,'HH_MM'));
    fullflickPathName = sprintf('%s/%s', folderPath, fileName);
    save(fullflickPathName,'flickSave','-v7.3');   
    fprintf('The flick has saved.\n',fileName);
       
end
