function tifPath = ExpandDataPaths(inDataPaths)
    if ~iscell(inDataPaths)
        error('no files to analyze');
    end
    
    sysConfig = GetSystemConfiguration();

    numIn = length(inDataPaths);
    
    tifPath = cell(0,1);
    
    for nn = 1:numIn
        % check that each folder begins with a directory, otherwise append
        % data_folder to it
        if isempty(regexp(inDataPaths{nn}(1:3),'[A-z]\:\\','once'))
            inDataPaths{nn} = fullfile(sysConfig.dataPath,inDataPaths{nn});
        end
        
        tifInSubDir = DirRec(inDataPaths{nn},'*.tif')';
        tifPath = cat(1,tifPath,tifInSubDir);
    end
end