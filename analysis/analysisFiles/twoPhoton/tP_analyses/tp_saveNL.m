function fullNlPathName = tp_saveNL( Z )
% Takes the nls in Z and saved them, along with some necessary
% information about how they were extracted, in the nls folder
% specified in dataPath.csv
    
    %% 1. Select Path
    % Create folder path for nl - master folder specified by
    % dataPath.csv, subfolder reflecting date of extraction.
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    nlFolder = C{1}{3};
    nlFolderPath = sprintf('%s/twoPhoton/%s/%s',nlFolder,Z.params.name,datestr(now,'dd_mm_yy'));         
    if ~isdir(nlFolderPath)
        mkdir(nlFolderPath);              
    end         
    
    %% 2. Organize parts of Z to save  
    nlName = sprintf('NL_%s',datestr(now,'HH_MM'));
    fullNlPathName = sprintf('%s/%s',nlFolderPath,nlName);
    saveNL = Z.NL;
    save(fullNlPathName,'saveNL');   
    fprintf('The nls for %s have extracted and saved.\n',nlName);
    
end

