function MakeDirList(folders,savePath)
    
    sysConfig = GetSystemConfiguration();
    dataPath = sysConfig.dataPath;

    if nargin < 1
        folders = [];
        savePath = 0;
    end
    
    if nargin < 2
        savePath = 0;
    end
    
    if ~iscell(folders)
        folders = {folders};
    end
    
    paths.folders = folders;

    %makes and saves a list of folders in a structure. This structure can
    %then be loaded into an analysis function for analysis
    paths.resp = cell(0,1);
    paths.stim = cell(0,1);
    
    if isempty(paths.folders{1})
        paths.folders = UiPickFiles('FilterSpec',dataPath,'Prompt','Choose folders containing the files to be analyzed');
    end
    
    %go through each folder selected and grab the path to every resp and
    %stimData file

    for ii = 1:size(paths.folders,2)
        respInSubDir = DirRec(paths.folders{ii},'respdata*')';
        paths.resp = cat(1,paths.resp,respInSubDir);
        stimInSubDir = DirRec(paths.folders{ii},'stimdata*')';
        paths.stim = cat(1,paths.stim,stimInSubDir);
    end
    
    removeDataPath = fullfile(dataPath,'\');
    for rr = 1:length(paths.resp)
        paths.resp{rr} = strrep(paths.resp{rr},removeDataPath,'');
    end
    
    %grab the first param file, they have to all be the same
    paths.param = DirRec(paths.folders{1},'chosenparams*')';
    
    
    if ~savePath
        savePath = fullfile(dataPath,'dataPath/',datestr(now,'yyyy/mm_dd/HH_MM_SS/'));
    end
    
    mkdir(savePath);
    fullPath = fullfile(savePath,['path' num2str(size(paths.resp,1)*5) 'flies.mat']);
    save(fullPath,'-struct','paths');
    clipboard('copy',fullPath);
end