function SavePsychoData(folder,file,varargin)
    dataNames = cell(length(varargin),1);
    
    for ii = 1:length(varargin)
        eval([inputname(ii+2) '= varargin{' num2str(ii) '};']);
        
        dataNames{ii} = inputname(ii+2);
    end

    sysConfig = GetSystemConfiguration();
    logPath = sysConfig.logPath;
    
    savePath = fullfile(logPath,'savedData',folder,file);
    
    save(savePath,dataNames{:});
end