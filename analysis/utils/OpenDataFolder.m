function OpenDataFolder(dataFolder)
    sysConfig = GetSystemConfiguration();
    dataPath = sysConfig.dataPath;
    
    if isempty(regexp(dataFolder(1:3),'[A-z]\:\\','once'))
        dataFolder = fullfile(dataPath,dataFolder);
    end
    
    dos(['explorer ' dataFolder]);
end