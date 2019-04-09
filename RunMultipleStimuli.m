function runDetails = RunMultipleStimuli(varargin)
% Run one or more parameter files. Options are:
% 'useDLPs' (boolean)
% 'genotype' (string)
% 'condstr' (string) Any special conditions to log about the run
% 'paramFile' (string or cell array of strings) The path(s) to the parameter files
%                                                you want to run. Either absolute or
%                                                relative to the paramFiles folder.
% 'stimDuration' (numeric or cell array of numeric) Duration(s) of the parameter
%													file(s) in frames
% 'probeDuration' (numeric or cell array of numeric) Duration(s) of the probe
%													 stimuli in frames

% SetComputerSleep('off');

%%
IgorFolder = []; % This should be changed in the future. Setup a GUI here. for

useDlps = [];
genotype = '';
condstr = '';
paramFile = cell(0,1);
probeFile = cell(0,1);
incubationTime = 0;
databaseInfo = [];
sameFly = 0;

probeParameters = cell(0,1);

stimDuration = cell(0,1);
probeDuration = cell(0,1);
runDetails = [];

rootFolder = fileparts(which('RunStimulus'));
paramPath = fullfile(rootFolder, 'paramfiles');

% load default values and allow the values in sysConfig to overwrite
% them
sysConfig = GetSystemConfiguration();

%% input varargin with the form ('variableName',variableValue,...)
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% randomize seed
seedState = rng('shuffle');

if isempty(runDetails)
    %% use the DLPs?
    if isempty(useDlps)
        useDlps = UiChooseScreen;
    end
    
    %% assign flyId
    flyId = AssignFlyId(sameFly);
    
    %% get genotype and any pre comments
    if isempty(genotype)
        switch sysConfig.genoEnter
            case 0
                [genotype,condstr,sameFly] = UiGetPreComments;
            case 1
                if ~isempty(databaseInfo)
                    databaseInfo = rmfield(databaseInfo, {'cylinderRotation', 'flyHeight'});
                end
                [databaseInfo] = UiGetPreCommentsSurgery(databaseInfo);
                genotype = databaseInfo.genotype;
                condstr = databaseInfo.comments;
                databaseInfo.cylinderRotation = sysConfig.flyHeadAngle;
                databaseInfo.flyHeight = sysConfig.flyHeight;
                databaseInfo.flyId = flyId;
                sameFly = databaseInfo.sameFly;
        end
    end
    
    %% Check for laser
    % We only want to run all the twoPhoton connection parameters if we're
    % not doing a test run of the stimulus. The 'tester' genotype choice
    % that'll allow testing of the connection without gathering data.
    sysConfig.twoPhoton = logical(sysConfig.twoPhoton);
    if any(strcmp(genotype, {'test', 'xtplot', 'align'}))
        sysConfig.twoPhoton = false;
        sysConfig.useProbe = 0;
        sysConfig.repeatProbe = 0;
    elseif strcmp(genotype, 'tester') && sysConfig.twoPhoton
        % We switch it back to test here so it doesn't interfere with
        genotype = 'test';
        databaseInfo.genotype = genotype;
        databaseInfo.cellType = 'test';
        databaseInfo.fluorescentProtein = 'test';
        databaseInfo.surgeon = 'test';
        databaseInfo.condition = 'test';
        databaseInfo.eye = 'test';
        databaseInfo.comments = 'test';
        databaseInfo.perfusion = true;
        databaseInfo.cylinderRotation = 'test';
        databaseInfo.flyHeight = 'test';
        databaseInfo.flyId = 'test';
        databaseInfo.expressionSystem = 'test';
    end
    
    %% get the parameter files
    if isempty(paramFile);
        paramFile = UiPickFiles('filterSpec',paramPath,'Prompt','Select parameter files to run');
    else
        if ~iscell(paramFile)
            paramFile = {paramFile};
        end
        
        for pa = 1:length(paramFile)
            if isempty(regexp(paramFile{pa}(1:3),'[A-z]\:\\','once'))
                paramFile{pa} = fullfile(paramPath,paramFile{pa});
            end
        end
    end
    
    stimulusParameters = GetParamsFromPaths(paramFile);
    
    %% ask for duration of the stimulus
    if isempty(stimDuration)
        for pa = 1:length(stimulusParameters)
            stimDuration{pa} = sysConfig.stimDuration; % default stim duration
            
            if isfield(stimulusParameters{pa},'totalTime');
                stimDuration{pa} = stimulusParameters{pa}.totalTime;
            else
                if sysConfig.forceDuration==1
                    [~,probeName] = fileparts(paramFile{pa});
                    answer = inputdlg(['For how many seconds do you want to present ' probeName '?'],probeName,[1 80]);
                    
                    % Multiply by 60 for 60 frames/second that the projector
                    % outputs--check out RunStimulus to see how this works
                    stimDuration{pa} = str2double(answer{1})*60;
                    stimulusParameters{pa}(1).totalTime = stimDuration{pa};
                end
            end
        end
    end
    
    %% get probe parameter file
    if sysConfig.useProbe
        if isempty(probeFile);
            probeFile = UiPickFiles('filterSpec',paramPath,'Prompt','Select probe parameter files to run');
            % Allows you to pick just one probe file to apply to all
            % stimulus files
            if length(probeFile) == 1
                probeFile = repmat(probeFile, 1, length(paramFile));
            end
        else
            if ~iscell(probeFile)
                probeFile = repmat({probeFile}, 1, length(paramFile));
            end
            
            for pa = 1:length(probeFile)
                if isempty(regexp(probeFile{pa}(1:3),'[A-z]\:\\','once'))
                    probeFile{pa} = fullfile(paramPath,probeFile{pa});
                end
            end
        end
        
        probeParameters = GetParamsFromPaths(probeFile);
        
        if isempty(probeDuration)
            % ask for duration of the probe
            for pa = 1:length(probeParameters)
                probeDuration{pa} = sysConfig.probeDuration; % default stim duration
                
                if isfield(probeParameters{pa},'totalTime');
                    probeDuration{pa} = probeParameters{pa}.totalTime;
                else
                    if sysConfig.forceDuration
                        [~,probeName] = fileparts(probeFile{pa});
                        answer = inputdlg(['For how many seconds do you want to present ' probeName '?'],probeName,[1 80]);
                        
                        % Multiply by 60 for 60 frames/second that the projector
                        % outputs--check out master_stimulus to see how this works
                        probeDuration{pa} = str2double(answer{1})*60;
                    end
                end
            end
        end
    end
    
    %% set up output
    runDetails.sysConfig = sysConfig;
    
    runDetails.useDLPs = useDlps;
    runDetails.genotype = genotype;
    runDetails.condstr = condstr;
    
    runDetails.stimulusParameters = stimulusParameters;
    runDetails.paramFiles = paramFile;
    runDetails.stimDuration = stimDuration;
    
    runDetails.probeParameters = probeParameters;
    runDetails.probeFiles = probeFile;
    runDetails.probeDuration = probeDuration;
    
    if sysConfig.twoPhoton
        runDetails.databaseInfo = databaseInfo;
    end
else
    sysConfig = runDetails.sysConfig;
    
    useDlps = runDetails.useDLPs;
    genotype = runDetails.genotype;
    condstr = runDetails.condstr;
    
    stimulusParameters = runDetails.stimulusParameters;
    paramFile = runDetails.paramFiles;
    stimDuration = runDetails.stimDuration;
    
    probeParameters = runDetails.probeParameters;
    probeFile = runDetails.probeFiles;
    probeDuration = runDetails.probeDuration;
end
if sysConfig.showStatusGui
    statusHandles = makeStatusGui();
    statusHandles.progressBarMulti.setMaximum(length(paramFile)*2);
    closeFigure = onCleanup(@() close(statusHandles.statusGui));
end
%% run the stimulus
if sysConfig.twoPhoton
    connectionToTwoPhoton = OpenTCPIPConnectionToTwoPhoton;
end

for pp = 1:length(paramFile)
    if sysConfig.showStatusGui
        statusHandles.progressBarMulti.setValue(2*(pp-1)+1);
        progressString = ['Running parameter file ' num2str(pp) ' of ' num2str(length(paramFile))];
        statusHandles.progressBarMulti.setString(progressString);
    end
    if length(probeParameters)==1
        ppProbe = 1;
    else
        ppProbe = pp;
    end
    if sysConfig.useProbe
        if sysConfig.twoPhoton
            probeParameters{ppProbe}(1).totalTime = probeDuration{ppProbe};
            stimulusParameters{pp}(1).totalTime = stimDuration{pp};
            stimulusParameters{pp} = MergeParameterFiles(probeParameters{ppProbe}, stimulusParameters{pp});
            
            stimDuration{pp} = stimulusParameters{pp}(1).totalTime;
        else
            Q=SetupStimulus(sysConfig,pp,useDlps,genotype,condstr,probeParameters{ppProbe},probeFile{ppProbe},probeDuration{ppProbe},incubationTime,flyId);
            if sysConfig.showStatusGui
                Q.statusHandles = statusHandles;
            end
            PrintMultiStatus(pp,length(paramFile));
            RunStimulus(Q);
        end
    end
    
    if sysConfig.useProbe && sysConfig.repeatProbe
        if sysConfig.twoPhoton
            repeatParameters = probeParameters;
            [repeatParameters{ppProbe}(:).repeats] = deal(0);
            epochNameRepeats = strcat({repeatParameters{ppProbe}(:).epochName}, ' Repeat');
            [repeatParameters{ppProbe}(:).epochName] = deal(epochNameRepeats{:});
            % We're assuming a nice parameter file here with repeats
            % telling you how many times to multiply each duration, so
            % as to find the total time
            totalRepeatTime = sum(([repeatParameters{ppProbe}.repeats]+1).*[repeatParameters{ppProbe}.duration]);
            stimulusParameters{pp}(1).totalTime = stimDuration{pp} + totalRepeatTime;
            
            stimDuration{pp} = stimulusParameters{pp}(1).totalTime;
            
            stimulusParameters{pp}(1).repeatProbeDuration = totalRepeatTime;
            [stimulusParameters{pp}(1:length(repeatParameters{ppProbe})).repeatProbeRepeats] = deal(0);
        end
    end
    
    if sysConfig.twoPhoton
        flyId = SaveDatabaseValues(connectionToTwoPhoton, paramFile{pp}, databaseInfo);
    end
    
    Q=SetupStimulus(sysConfig,pp,useDlps,genotype,condstr,stimulusParameters{pp},paramFile{pp},stimDuration{pp},incubationTime,flyId);
    runDetails.filePath{pp} = Q.paths.data;
    
    if sysConfig.twoPhoton
        if sysConfig.useProbe
            Q.paths.probePath = probeFile{ppProbe};
        else
            Q.paths.probePath = '';
        end
        SendAcquisitionInitiationMessage(connectionToTwoPhoton, Q);
    end
    if sysConfig.showStatusGui
        Q.statusHandles = statusHandles;
    end
    PrintMultiStatus(pp,length(paramFile));
    RunStimulus(Q);
    if sysConfig.twoPhoton
        TransferBehaviorData(connectionToTwoPhoton, Q);
    end
    
    if sysConfig.useProbe && sysConfig.repeatProbe
        if ~sysConfig.twoPhoton
            repeatParameters = probeParameters;
            [repeatParameters{ppProbe}(:).nextEpoch] = deal(nextEpochs{:});
            [repeatParameters{ppProbe}(:).repeats] = deal(0);
            Q=SetupStimulus(sysConfig,pp,useDlps,genotype,condstr,repeatParameters{ppProbe},probeFile{ppProbe},probeDuration{ppProbe},incubationTime,flyId);
            if sysConfig.showStatusGui
                Q.statusHandles = statusHandles;
            end
            PrintMultiStatus(pp,length(paramFile));
            RunStimulus(Q);
        end
    end
    
    if sysConfig.ephys_rudy
        % ask whether is the ephys's folder for every stimulus.
        if isempty(IgorFolder)
            IgorFolder = uigetdir(sysConfig.igor_start_path);
        end
        paramFilename = Q.paramFilename;
        genotype = Q.genotype;
        currTime = Q.currTime;
        data_to_this_path = fullfile(sysConfig.dataPath, genotype, paramFilename, currTime);
        
        CopyDataFromIgorFileToDataFile(data_to_this_path, IgorFolder);
    end
    
end

if sysConfig.twoPhoton
    CloseTCPIPConnectionToTwoPhoton(connectionToTwoPhoton);
end

%% organize data from Igor to datafile.

SendNotification(Q);
end