function loadPath = GetLoadPath(folder,file)
    sysConfig = GetSystemConfiguration();
    logPath = sysConfig.logPath;
    
    loadPath = fullfile(logPath,'savedData',folder,file);
end