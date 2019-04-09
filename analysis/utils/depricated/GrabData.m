function [D] = GrabData(folders,blacklist)
    %set up structure D which will hold all the variables pertaining to the
    %data and data analysis
    
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    data_folder = C{1}{1};
    log_folder = C{1}{2};
    
    if nargin<1
        blacklist = [];
        
        paths.folders = uipickfiles('FilterSpec',data_folder,'Prompt','Choose folders containing the files to be analyzed');
        D.folders = paths.folders;
    else
        if iscell(folders)
            paths.folders = folders;
        else
            paths.folders = {folders};
        end
    end
    
    if nargin<2
        blackList = [];
    end
    
    paths.resp = cell(0,1);
    paths.stim = cell(0,1);
    paths.xtp = cell(0,1);
    
    if ~iscell(paths.folders)
        error('no files to analyze');
    end
    
    %go through each folder selected and grab the path to every resp and
    %stimData file
    for ii = 1:size(paths.folders,2)
        % check that each folder begins with a directory, otherwise append
        % data_folder to it
        if isempty(regexp(paths.folders{ii}(1:3),'[A-z]\:\\','once'))
            paths.folders{ii} = fullfile(data_folder,paths.folders{ii});
        end
        
        respInSubDir = dirrec(paths.folders{ii},'respdata*')';
        paths.resp = cat(1,paths.resp,respInSubDir);
        stimInSubDir = dirrec(paths.folders{ii},'stimdata*')';
        paths.stim = cat(1,paths.stim,stimInSubDir);
        xtpInSubDir = dirrec(paths.folders{ii},'.xtp')';
        paths.xtp = cat(1,paths.xtp,xtpInSubDir);
    end

    %grab the first param file, they have to all be the same
    paths.param = dirrec(paths.folders{1},'chosenparams*');
    
    if strcmp(paths.folders{1}(end-3:end),'.mat')
        paths = load(paths.folders{1});
        if ~exist('paths.xtp')           
            paths.xtp = [];
        end
    end
    
    if ~isempty(blacklist)
        blacklist = load(blacklist);
        for bb = 1:length(blacklist.resp);
            for pp = length(paths.resp):-1:1;
                if strcmp(paths.resp{pp},blacklist.resp{bb})
                    paths.resp(pp) = [];
                    paths.stim(pp) = [];
                    paths.param(pp) = [];
                end
            end
        end
    end
    
    D.paths = paths;
    
    %load parameter file
    D.data = load(D.paths.param{1});
    %initialize figure array even if its unused
    D.figures = cell(0,1);

    %true if all reads are off by 1 - normally true
    D.data.readDelayed = 1;

    
    %% check if any files are not .mat and are still in .txt format
    % convert to .mat
    for ii = 1:length(D.paths.resp)
        if strcmp(D.paths.resp{ii}(end-2:end),'csv')
            respSaveTo = fullfile([fileparts(D.paths.resp{ii}) '\respdata.mat']);
            
            if exist(D.paths.resp{ii},'file')
                respData = csvread(D.paths.resp{ii});
                respNameChange = fullfile([fileparts(D.paths.resp{ii}) '\textRespData.csv']);
                save(respSaveTo,'respData');
                movefile(D.paths.resp{ii},respNameChange)
            end
            
            D.paths.resp{ii} = respSaveTo;
        end
        
        if strcmp(D.paths.stim{ii}(end-2:end),'csv')
            stimSaveTo = fullfile([fileparts(D.paths.stim{ii}) '\stimdata.mat']);
            
            if exist(D.paths.stim{ii},'file')
                stimData = csvread(D.paths.stim{ii});
                stimNameChange = fullfile([fileparts(D.paths.resp{ii}) '\textStimData.csv']);
                save(stimSaveTo,'stimData');
                movefile(D.paths.stim{ii},stimNameChange)
            end
            
            D.paths.stim{ii} = stimSaveTo;
        end
    end
    
    %% read in data
    
    respSize = whos('-file',D.paths.resp{end});
    respSize = respSize.size;
    sizeRespTime = respSize(1);
    sizeRespMeasures = respSize(2);
    sizeRespNumFiles = size(D.paths.resp,1);
    
    stimSize = whos('-file',D.paths.stim{end});
    stimSize = stimSize.size;
    sizeStimTime = stimSize(1);
    sizeStimMeasures = stimSize(2);
    sizeStimNumFiles = size(D.paths.stim,1);
    
    D.data.resp = zeros(sizeRespTime,sizeRespMeasures,sizeRespNumFiles);
    D.data.stim = zeros(sizeStimTime,sizeStimMeasures,sizeStimNumFiles);
    
    if ~isempty(D.paths.xtp)
        xtSize = size(csvread(D.paths.xtp{1}));
        D.data.xtp = zeros(xtSize(1),xtSize(2),size(D.paths.stim,1));
    end
    
    %read in the data from the filepaths
    for ii = 1:size(D.data.resp,3)
        respTemp = load(D.paths.resp{ii});
        respTemp = respTemp.respData;
        D.data.resp(:,1:size(respTemp,2),ii) = respTemp;
        stimTemp = load(D.paths.stim{ii});
        stimTemp = stimTemp.stimData;
        
        if size(stimTemp,2) < sizeStimMeasures
            D.data.stim(:,1:3,ii) = stimTemp(:,1:3);
            D.data.stim(:,4 + sizeStimMeasures - size(stimTemp,2):end,ii) = stimTemp(:,4:end);
        else
            D.data.stim(:,:,ii) = stimTemp;
        end
        
        if ~isempty(D.paths.xtp)
            D.data.xtp(:,:,ii) = csvread(D.paths.xtp{ii});
        end
    end

    %if the read is delayed shift all data up one time point and delete the
    %last one
    if D.data.readDelayed
        D.data.resp(1:end-1,3:end,:) = D.data.resp(2:end,3:end,:);
        D.data.stim(1:end-1,4:end,:) = D.data.stim(2:end,4:end,:);

        D.data.resp(end,:,:) = [];
        D.data.stim(end,:,:) = [];
    end
end