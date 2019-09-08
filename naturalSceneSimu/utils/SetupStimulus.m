function Q=SetupStimulus(sysConfig,runNumber,useDLPs,genotype,condstr,params,paramPaths,paramDuration,incubationTime,flyId)
    % find the folder RunStimulus is located in so we can perform local
    % directory searches
    rootFolder = fileparts(which('RunStimulus'));

    %% generate frustrum
    % check if flyHeadAngle and flyHeight are specified
    if ~isfield(sysConfig,'flyHeadAngle')
        flyHeadAngle = 0;
    else
        % angle of the fly's head in radians from looking straight ahead
        % This will be used to tilt the cylinder the same ammount
        flyHeadAngle = sysConfig.flyHeadAngle*pi/180;
    end

    if ~isfield(sysConfig,'flyHeight')
        flyHeight = 0;
    else
        % fly height releative to the real world middle of the screens
        % the middle of the screen would be 0, the top of the screen would be
        % 20
        flyHeight = sysConfig.flyHeight;
    end

    Q.cylinder = CalculateFrustrum(flyHeadAngle,flyHeight);

    Q.readMouse = sysConfig.readMouse;
    
    Q.usePhotoDiode = sysConfig.usePhotoDiode;
    
    Q.photoDiodeSync = sysConfig.photoDiodeSync;

    Q.dataPath = sysConfig.dataPath;
    
    Q.automateRecording = sysConfig.automateRecording;
    
    Q.showStatusGui = sysConfig.showStatusGui;
    
    Q.flyId = flyId;
    
    if isfield(sysConfig,'sendEmail')
        Q.sendEmail = sysConfig.sendEmail;
        Q.emailAddress = sysConfig.emailAddress;
    else
        Q.sendEmail = 0;
        Q.emailAddress = '';
    end

    %% deal with error messages
    % reduce the amount of error messages shown when running on main screen
    % because we don't care if the sync tests work when not on the DLPs
    if useDLPs
        Screen('Preference', 'Verbosity', 2); %Reduce text on screen
    else
        Screen('Preference', 'Verbosity', 0);
    end

    % Run sync tests if on DLPs, otherwise dont bother
    Screen('Preference', 'SkipSyncTests', 2*(~useDLPs));
    Screen('Preference','VisualDebugLevel', 0);

    %% save inputs
    % flipToMouseDelay is the delay between when the program flips and when
    % the mouse reads behavior that occured during this flip. In principle,
    % the delay should be two frames. The stimulus is presented on the
    % frame after the flip, and the mouse reads the behavior from the frame
    % before it. I did some timing between the flip and the reading of the
    % mice and found there to be an extra frame of delay, so I have set the
    % delay to 3 frames. Increase the total time by delay - 1 to capture
    % these reads, and shift the data appropriately during analysis.
    
    stimParams = [];
    probeParams = [];
    if iscell(paramPaths)
        % this is a bit of a hack, but I allowed param paths to get passed
        % in as a cell, where the first cell is a string of the path to the
        % parameter file and the second cell is the path to the probe file.
        % This will allow me to save .mat files of the probe and stimulus
        % files
        stimParams = GetParamsFromPaths(paramPaths{1});
        probeParams = GetParamsFromPaths(paramPaths{2});
        
        paramPaths = paramPaths{1};
    end
    
    Q.flipToMouseDelay = sysConfig.flipToMouseDelay;
    Q.stims.duration = paramDuration+Q.flipToMouseDelay;
    [~, paramFilename, ~] = fileparts(paramPaths);
    Q.genotype = genotype;
    Q.condstr = condstr;
    Q.runNumber = num2str(runNumber);
    Q.paramFilename = paramFilename;
    Q.usePD = sysConfig.usePhotoDiode;
    Q.rigName = sysConfig.rigName;
    rigName = Q.rigName;
    
    %% initialize default variables
    % get current date for naming folders
    yr = datestr(now,'yyyy');
    mmdd = datestr(now, 'mm_dd');
    hhmmss = datestr(now, 'HH_MM_SS');
    Q.currTime = fullfile(yr, mmdd, hhmmss);
    
    % initialize psychtoolbox opengl for screen commands
    InitializeMatlabOpenGL(0,0);

    Q.stims.currStimNum = 1; % first epoch should always be 1
    Q.stims.stimData.mat = zeros(20,1); % memory for stim functions
    Q.stims.stimData.cl = zeros(10,1); % closed loop variables for controlling feedback

    Q.stims.params = params;
    Q.stims.currParam = params(1); % always start with 1

    %% set DLP parameters
    if isfield(Q.stims.currParam,'LEDCurrent')
        Q.stims.LEDCurrent = Q.stims.currParam.LEDCurrent;
    else
        Q.stims.LEDCurrent = 1;
    end

    if ~isfield(Q.stims.currParam,'framesPerUp')
        Q.stims.currParam.framesPerUp = 3;
        for i = 1:length(Q.stims.params) % set for all epochs
            Q.stims.params(i).framesPerUp = 3;
        end
    end

    switch Q.stims.currParam.framesPerUp
        case 3
            Q.stims.bitDepth = 7;
        case 6
            Q.stims.bitDepth = 4;
        case 12
            Q.stims.bitDepth = 2;
        case 24
            Q.stims.bitDepth = 1;
    end

    if isfield(sysConfig,'dlpList')  % convert the dlpList field from a string to an array
        eval(['Q.dlpList = [' num2str(sysConfig.dlpList) '];']);
    else
        Q.dlpList = 1:5;
    end

    if isfield(Q.stims.currParam,'lightcrafterColor')
        panoColor = Q.stims.currParam.lightcrafterColor;
    else
        panoColor = 3;
    end

    Q.useDLPs = useDLPs;
    if useDLPs
        try
            InitDLP('bitDepth',Q.stims.bitDepth,'current',Q.stims.LEDCurrent,'color',panoColor,'list',Q.dlpList);
        catch err 
            warning('COULD NOT COMMUNICATE WITH DLPS, continuing but be aware the DLPs might not be connected to the computer');
            warning('Connection error was: %s', err.message);
        end
    end
    
    if sysConfig.lightCrafter4500 && Q.useDLPs && isfield(Q.stims.currParam,'flatstimtype')
        if isfield(Q.stims.currParam,'lightcrafter4500Color') 
            patternColor = Q.stims.currParam.lightcrafter4500Color;
        else
            patternColor = 'full';
        end
        
        if isfield(Q.stims.currParam,'flatFramesPerUp')
            numFrames = [2,3,4,6,8,12,24];
            bitDepth =  [8,7,6,4,3,2 ,1 ];
            getBitDepth = containers.Map(numFrames,bitDepth);
            fpu = Q.stims.currParam.flatFramesPerUp;
            patternBitDepth = getBitDepth(fpu);
        else
            patternBitDepth = 2;
        end
        Q.lightCrafter4500 = Lcr4500();
        Q.lightCrafter4500.connect();
        Q.lightCrafter4500.wakeup();
        Q.lightCrafter4500.setMode(LcrMode.PATTERN);
        Q.lightCrafter4500.setPatternAttributes(patternBitDepth, patternColor);
    end

    %% check genotype for reserved genotypes
    switch genotype
        case 'xtplot'
            if Q.stims.currParam.ordertype == 0
                for pp = 1:length(Q.stims.params)
                    Q.stims.params(pp).ordertype = 1;
                end
            end
            
            Q.stims.xtPlot = 1;
            Q.stims.movie = 0;
            Q.stims.test = 0;
            Q.stims.align = 0;
            if isfield(Q.stims.currParam, 'ordertype')
                if Q.stims.currParam.ordertype == 3
                    Q.stims.duration = (sum(Q.stims.params(1).duration+[Q.stims.params(2:end).duration]));
                elseif Q.stims.currParam.ordertype == 4
                    Q.stims.duration = (sum(Q.stims.params(1).duration+[Q.stims.params(2:end).duration]));
                    for stimInd = 1:length(Q.stims.params)
                        Q.stims.params(stimInd).ordertype = 3;
                    end
                    Q.stims.currParam.ordertype = 3;
%                     Q.stims.duration = (sum([Q.stims.params(1).duration+[Q.stims.params(2:end).duration]].*[Q.stims.params(2:end).repeats]));
                else
                    Q.stims.duration = sum([Q.stims.params.duration]);
                end
            else
                %             Q.stims.duration = sum([Q.stims.params.duration]);
                Q.stims.duration = 1*60;
            end
        case 'movie'
            if Q.stims.currParam.ordertype == 0
                for pp = 1:length(Q.stims.params)
                    Q.stims.params(pp).ordertype = 1;
                end
            end
            
            Q.stims.xtPlot = 0;
            Q.stims.movie = 1;
            Q.stims.test = 0;
            if isfield(Q.stims.currParam, 'ordertype')
                if Q.stims.currParam.ordertype == 3
                    Q.stims.duration = (sum(Q.stims.params(1).duration+[Q.stims.params(2:end).duration]));
                elseif Q.stims.currParam.ordertype == 4
                    Q.stims.duration = (sum(Q.stims.params(1).duration+[Q.stims.params(2:end).duration]));
                    for stimInd = 1:length(Q.stims.params)
                        Q.stims.params(stimInd).ordertype = 3;
                    end
                    Q.stims.currParam.ordertype = 3;
%                     Q.stims.duration = (sum([Q.stims.params(1).duration+[Q.stims.params(2:end).duration]].*[Q.stims.params(2:end).repeats]));
                else
                    Q.stims.duration = sum([Q.stims.params.duration]);
                end
            else
                %             Q.stims.duration = sum([Q.stims.params.duration]);
                Q.stims.duration = 6*60;
            end
        case 'test'
            Q.stims.xtPlot = 0;
            Q.stims.movie = 0;
            Q.stims.test = 1;
            Q.stims.align = 0;
            Q.automateRecording = 0;
        case 'align'
            Q.stims.xtPlot = 0;
            Q.stims.movie = 0;
            Q.stims.test = 0;
            Q.stims.align = 1;
            Q.automateRecording = 0;
        otherwise
            Q.stims.xtPlot = 0;
            Q.stims.movie = 0;
            Q.stims.test = 0;
            Q.stims.align = 0;
    end

    %% choose box temperature

    rigTemperature = sysConfig.rigTemperature;
    if rigTemperature ~= 0
        if useDLPs
            if ~Q.stims.test && ~Q.stims.xtPlot && ~Q.stims.movie
                WaitUntilTemperature(rigTemperature,sysConfig.pidPort);
            end
        end
    end
    Q.stims.boxTemp = rigTemperature;
    
    if ~Q.stims.test && ~Q.stims.xtPlot && ~Q.stims.movie
        if runNumber == 1
            for time = 1:incubationTime
                WaitSecs(1);
                if mod(time,60)==0
                    disp([num2str(floor(time/60)) ' out of ' num2str(incubationTime/60) ' minutes of incubation completed']);
                end
            end
        end
    end
    
    %% set up paths to folders
    paths.home = rootFolder;
    paths.utils = fullfile(rootFolder, 'utils');
    paths.paramfiles = fullfile(rootFolder, 'paramfiles');

    paths.data = fullfile(sysConfig.dataPath, genotype, paramFilename, Q.currTime);
    paths.autoLog = fullfile(sysConfig.logPath, ['autoLog_' Q.rigName '.m']);
    paths.allLog = fullfile(sysConfig.logPath, ['allLog_' Q.rigName '.m']);
    paths.clampexData = sysConfig.clampexDataPath;
    paths.stimfunctions = fullfile(rootFolder, 'stimfunctions');
    paths.viewlocsfile = fullfile(rootFolder, 'paramfiles', 'view_locs.txt');
    paths.stimlookupfile = fullfile(rootFolder, 'paramfiles', 'stimulus_lookup.txt');

    Q.paths = paths;

    Q.paths.chosenparameterfile = paramPaths;

    [Q.stims.stimlookup,Q.stims.numList] = ReadStimLookup(Q.paths.stimlookupfile);
    %create data file -MSC
    mkdir(Q.paths.data); 

    %% Create files for xtPlot and movie outputs

    if Q.stims.xtPlot
        [handles.xtPlot, message] = fopen(fullfile(paths.data,'xtPlot.xtp'),'w');
        assert(isempty(message),message);
    end

    if Q.stims.movie
        handles.movie = VideoWriter(fullfile(paths.data,'movie.mp4'),'MPEG-4');
        handles.movie.FrameRate = 60;
        open(handles.movie);
    end

    %% save seedstate
    seedState = rng;
    save(fullfile(Q.paths.data,'seedState.mat'),'-struct','seedState');

    %% open files for read/write.
    % the assert command ensures that the fopen was successful and stops the
    % program if it was not.

    % opens metadata.txt for info about the run
    [handles.metadata, message] = fopen(fullfile(Q.paths.data,'metadata.txt'),'w');
    assert(isempty(message),message);

    % opens stimdata.csv for info about the stimulus
    [handles.stimdata, message] = fopen(fullfile(Q.paths.data,'stimdata.csv'),'w');
    assert(isempty(message),message);

    % opens respdata.csv for info about fly response
    [handles.respdata, message] = fopen(fullfile(Q.paths.data,'respdata.csv'),'w');
    assert(isempty(message),message);

    %% if not a test / xtplot / movie write log files
    if ~Q.stims.test && ~Q.stims.xtPlot && ~Q.stims.movie
        % autolog to list files that have recently run and need to be filed
        [handles.autoLog, message] = fopen(Q.paths.autoLog,'a');
        assert(isempty(message),message);

        % autolog that never gets deleted
        [handles.allLog, message] = fopen(Q.paths.allLog,'a');
        assert(isempty(message),message);
    end

    t_start = GetSecs;

    viewLocs = dlmread(Q.paths.viewlocsfile);

    %% Control clampex if necessary
    % This has to go before starting up the screens because the screens do
    % weird things to window focus.
    if Q.automateRecording
        h = actxserver('WScript.Shell');
        if ~h.AppActivate('clampex') % Clampex not yet running
            h.Run('"C:\Program Files (x86)\Molecular Devices\pCLAMP10.4\Clampex.exe"');
            success = 0;
            for i = 1:50 % Wait for program to start up
                pause(0.1);
                success = h.AppActivate('clampex');
                if success
                    break
                end
            end
            pause(1);
            if ~success
                msgbox('Could not open Clampex.\nPlease start Clampex and then press OK', 'Error','error');
                h.AppActivate('clampex');
            end
        end
        % Start recording
        h.SendKeys('{F2}');
    end
    
    %% deal with screens

    % Set up sizes and locations
    if useDLPs

        if isfield(sysConfig,'panoScreenID')
            panoScreenID = sysConfig.panoScreenID;
            panoRect = []; % fullscreen
        end

        if isfield(sysConfig,'flatScreenID')
            flatScreenID = sysConfig.flatScreenID;
            flatRect = []; % fullscreen
        end 
    else % use main screen
        panoScreenID = sysConfig.mainScreenID;
        flatScreenID = sysConfig.mainScreenID;

        % Determine correct sizes to display
        if isfield(sysConfig,'panoScreenID') && sysConfig.panoScreenID>=0
            panoRect = Screen('Rect', sysConfig.panoScreenID);
        elseif isfield(sysConfig, 'panoScreenWidth') && isfield(sysConfig, 'panoScreenHeight')
            panoRect = [0 0 sysConfig.panoScreenWidth sysConfig.panoScreenHeight];
        else
            panoRect = [0 0 648 680];
        end

        if isfield(sysConfig,'flatScreenID') && sysConfig.flatScreenID>=0
            flatRect = Screen('Rect', sysConfig.flatScreenID);
        elseif isfield(sysConfig, 'flatScreenWidth') && isfield(sysConfig, 'flatScreenHeight')
            flatRect = [0 0 sysConfig.flatScreenWidth sysConfig.flatScreenHeight];
        else
            flatRect = [0 0 648 680];
        end

        % Dual display
        if (isfield(Q.stims.currParam,'stimtype') && isfield(Q.stims.currParam,'flatstimtype'))
            flatOffset = 10 + panoRect(3);
            flatRect = flatRect + [flatOffset, 0, flatOffset, 0];
        end
    end

    if isfield(Q.stims.currParam,'stimtype')
        panoWindowID = PsychImaging('OpenWindow',panoScreenID,[0 0 0],panoRect);
        activeWindowID = panoWindowID;
        Q.windowIDs.pano = panoWindowID;
        Screen('Fillrect',panoWindowID,[0;0;0]);
    end

    if isfield(Q.stims.currParam,'flatstimtype')
        flatWindowID = Screen('OpenWindow',flatScreenID,[0 0 0],flatRect);
        activeWindowID = flatWindowID;
        Q.windowIDs.flat = flatWindowID;
        Screen('Fillrect',flatWindowID,[0;0;0]);
        Q.flatRect = Screen('Rect', Q.windowIDs.flat);
        Screen('BlendFunction',Q.windowIDs.flat,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
    end

    Q.windowIDs.active = activeWindowID;
    Priority(MaxPriority(activeWindowID));% Ensure we are at the max priority for any operating system.
    Screen('Flip',activeWindowID,[],[],[],1); % multiflip set to 1: all windows will flip at their vblank
%     pause(1); % pauses for 1 second on gray... could make this longer or shorter

    %% set up closed loop structure for monitoring fly response in realtime
    Q.OGL.viewLocs=viewLocs;

    % for storing derivative and integrated fly data
    %mdX stands for mouse dX which is proportional to theta -MSC
    flyloc.mdX = zeros(1,5);
    flyloc.mdY = zeros(1,5);
    flyloc.mqv = zeros(1,5);
    flyloc.x = zeros(1,5);
    flyloc.y = zeros(1,5);
    flyloc.t = zeros(1,5);
    flyloc.nr = 0;
    flyloc.dx = zeros(1,5);
    flyloc.dy = zeros(1,5);
    flyloc.dt = zeros(1,5);
    flyloc.xscale = ones(1,5); % should these be in a file? read from a file?
    flyloc.yscale = ones(1,5);
    flyloc.tscale = ones(1,5);
    Q.flyloc = flyloc;

    Q.flyTimeline = FlyTimeline(t_start,GetSecs(),Q.stims.duration);

    %% write out meta data
    save(fullfile(Q.paths.data, 'chosenparams.mat'),'params'); % save these into data folder

    % emilio concatinates the stimulus and probe parameters. save them
    % separately here if there is a probe
    if ~isempty(probeParams)
        save(fullfile(Q.paths.data, 'stimParams.mat'),'stimParams');
        save(fullfile(Q.paths.data, 'probeParams.mat'),'probeParams');
    end
    
    WriteStringsToFile(handles.metadata,Q.currTime,... % first line is date and time
        Q.paths.chosenparameterfile,...
        Q.paths.stimlookupfile,...
        Q.paths.viewlocsfile,...
        ['xscales = ' num2str(flyloc.xscale)],...
        ['yscales = ' num2str(flyloc.yscale)],...
        ['tscales = ' num2str(flyloc.tscale)],...
        ['useDLP = ' num2str(useDLPs)],... % then useDLP status
        ['genotype = ' genotype],...
        ['conditions = ' condstr],...
        ['box temperature = ' num2str(Q.stims.boxTemp)],...
        ['rig name = ' Q.rigName],...
        ['run number = ' num2str(Q.runNumber)],...
        ['COMMENTS BY HAND: ' ]);
    
    save(fullfile(Q.paths.data,'runDetails.mat'),'rigName','runNumber','genotype','rigTemperature','flyId');
    
    %% open serial port for mouse communication and begin recording
    if Q.readMouse
        try
            [handles.arduino,~] = IOPort('OpenSerialPort',sysConfig.mousePort,['BaudRate=115200','ReceiveTimeout=1','PollLatency=.001']);
        catch err %#ok<NASGU>
            warning('Could not talk to mouse in preliminary_setup ignoring and cont');
            Q.readMouse = 0;
        end
        
        if Q.readMouse
            % make sure the arduino isn't already sending data
            IOPort('Write',handles.arduino,'b');
            % wait 5 ms to make sure arduino loop has finished and then clear the port
            WaitSecs(1/60);
            IOPort('Purge',handles.arduino);

            IOPort('Write',handles.arduino,'a');
            IOPort('Flush', handles.arduino); % Wait until sent
        end
    end

    Q.handles = handles;
end
