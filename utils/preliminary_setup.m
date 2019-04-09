function Q=preliminary_setup(init, varargin)
% Q comes out of this with some basic sub structures:
% paths, stims, handles, timing, flyloc, ARD, OGL, texStr
% these contain the various parts related to writing data, timing, keeping
% up with the fly locations, dealing with the arduino, and OGL useful stuff

multipleFiles = false;

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

cputime;

useDLP = init.useDLP;
SCREENCHOOSE = init.SCREENCHOOSE;
genostr = init.genostr;
condstr = init.condstr;
params = init.params;
paramsfullpath = init.paramsfullpath;
probePath = init.probePath;

% some user inputs, first
Q.OGL.useDLP = useDLP;
Q.stims.currStimNum = 1; % always start on 1; this gets updated frequently
Q.punish.currPunishNum = 1;
Q.stims.stimData.mat = zeros(20,1); % to be decided later (initialize as zeros? -MSC)
Q.stims.stimData.cl = zeros(10,1);
yr = datestr(now,'yyyy');
mmdd = datestr(now, 'mm_dd');
hhmmss = datestr(now, 'HH_MM_SS');
Q.currTime = fullfile(yr, mmdd, hhmmss);
Q.isClosedLoop = 1;

Priority(2);
% InitializeMatlabOpenGL(0,2);
InitializeMatlabOpenGL(0,0);
%% NOTE: IT MIGHT BE FAR FASTER TO PASS THESE SUCKERS AS PARAMETERS THAN DECLARE GLOBAL VARIABLES EACH LOOP
%% COULD TRY THAT OUT INSTEAD
% Q.OGL.GL = GL;
% Q.OGL.AGL = AGL;
% Q.OGL.GLU = GLU;
global GL AGL GLU;

% be careful with this. get rid of it if possible.
%Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SkipSyncTests', double(~useDLP));
%Screen('Preference', 'VBLTimestampingMode', 1)
Q.abort = 0;

settings.flyHeadAngle = '45';
settings.flyHeight = '20';
Q.cylinder = CalculateFrustrum(settings);

% moved this up here so that i can include param fileName in data folder
% for easy scanning -MSC, praise him
%choose parameter file here
root_folder = fileparts(which('master_stimulus'));
%[params,paramsfullpath] = ui_load_parameter_file(fullfile(root_folder, 'paramfiles'));
%if multipleFiles
%    while ~isempty(params)
%        [paramsHere,paramsfullpath] = ui_load_parameter_file(fullfile(root_folder, 'paramfiles'));
%        params = [params paramsHere];
%    end
%end

Q.stims.params = params;
Q.stims.currParam = params(1); % always start with 1
Q.stims.xtPlot = 0;
duration_minutes = 60;
%Q.stims.duration = duration_minutes*60*60;
Q.stims.movie = 0;

if isfield(Q.stims.currParam,'totalTime');
    Q.stims.duration = Q.stims.currParam.totalTime;
else
    Q.stims.duration = duration_minutes*60*60;
end
boxTemperature = 36;

if isfield(Q.stims.currParam,'LEDCurrent')
    Q.stims.LEDCurrent = Q.stims.currParam.LEDCurrent;
else
    Q.stims.LEDCurrent = 1;
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

if useDLP
    try
        initDLP('bitDepth',Q.stims.bitDepth,'current',Q.stims.LEDCurrent);
    catch err
        disp('COULD NOT COMMUNICATE WITH DLPS, continuing but be aware the DLPs might not be connected to the computer');
    end
end
    

[~, paramFilename, ~] = fileparts(paramsfullpath);
Q.paramFilename = paramFilename;

Q.toPunish = 1;
%TODO--there should really be a gitignored settings file to tell us which
%computer is being used...
Q.readMouse = 1;
try
    s=serial('COM7');fopen(s);fclose(s);
catch
    Q.toPunish = 0;
    Q.isClosedLoop = 0;
end

if(Q.toPunish)
    Q.stims.duration = 50*60*60;
    [punishParams, punishParamsFullPath] = ui_load_parameter_file(fullfile(root_folder, 'punishparamfiles'));
    Q.punish.params = punishParams;
    Q.punish.currParam = punishParams(1);
    
    [~, punishParamFilename, ~] = fileparts(punishParamsfullpath);
    boxTemperature = Q.punish.currParam.boxTemperature;
else
    punishParamFilename = '';
end

% if ~strcmp(genostr,'test') && ~strcmp(genostr,'xtplot')
%     waitUntilTemperature(boxTemperature);
% end

Q.stims.boxTemp = boxTemperature;

% preliminary book keeping -- set up paths and handles -- these will change
% with move to windows machine

paths.home = root_folder;
paths.utils = fullfile(root_folder, 'utils');
paths.paramfiles = fullfile(root_folder, 'paramfiles');
paths.punishparamfiles = fullfile(root_folder, 'punishparamfiles');

%write data outside of psycho5 to avoid it getting backed up by GitHub
HPathIn = fopen('dataPath.csv');
C = textscan(HPathIn,'%s');
data_folder = C{1}{1};
log_folder = C{1}{2};

switch genostr
    case 'test'
        if Q.toPunish
            paths.data = fullfile(data_folder, 'test', [paramFilename '__' punishParamFilename], [Q.currTime '_' genostr]);
        else
            paths.data = fullfile(data_folder, 'test', paramFilename, [Q.currTime '_' genostr]);
        end
%         if isfield(Q.stims.currParam, 'ordertype')
%             if Q.stims.currParam.ordertype == 3
%                 Q.stims.duration = (sum(Q.stims.params(1).duration+[Q.stims.params(2:end).duration]));
%             elseif Q.stims.currParam.ordertype == 4
%                 Q.stims.duration = (sum([Q.stims.params(1).duration+[Q.stims.params(2:end).duration]].*[Q.stims.params(2:end).repeats]));
%             else
%                 Q.stims.duration = sum([Q.stims.params.duration]);
%             end
%         else
%             Q.stims.duration = sum([Q.stims.params.duration]);
%         end
%         Q.stims.duration = 20*60*60;
    case 'xtplot'
        Q.stims.xtPlot = 1;
        if Q.toPunish
            paths.data = fullfile(data_folder, 'xtplot', [paramFilename '__' punishParamFilename], [Q.currTime '_' genostr]);
        else
            paths.data = fullfile(data_folder, 'xtplot', paramFilename, [Q.currTime '_' genostr]);
        end
        if isfield(Q.stims.currParam, 'ordertype')
            if Q.stims.currParam.ordertype == 3
                Q.stims.duration = (sum(Q.stims.params(1).duration+[Q.stims.params(2:end).duration]));
            elseif Q.stims.currParam.ordertype == 4
                Q.stims.duration = (sum([Q.stims.params(1).duration+[Q.stims.params(2:end).duration]].*[Q.stims.params(2:end).repeats]));
            else
                Q.stims.duration = sum([Q.stims.params.duration]);
            end
        else
%             Q.stims.duration = sum([Q.stims.params.duration]);
            Q.stims.duration = 100*10*60;
        end
    case 'movie'
        Q.stims.movie = 1;
        Q.stims.duration = 6*60;
        
        if Q.toPunish
            paths.data = fullfile(data_folder,'zMovie',[paramFilename '__' punishParamFilename], [Q.currTime '_' genostr]);
        else
            paths.data = fullfile(data_folder,'zMovie',paramFilename,[Q.currTime '_' genostr]);
        end
    otherwise
        if Q.toPunish
            paths.data = fullfile(data_folder, [paramFilename '__' punishParamFilename], [Q.currTime '_' genostr]);
        else
            paths.data = fullfile(data_folder, paramFilename, [Q.currTime '_' genostr]);
        end
end
    
paths.log = fullfile(log_folder, Q.currTime(1:end-8));
paths.autoLog = fullfile(log_folder, 'topic', 'autoLog.m');
paths.allLog = fullfile(log_folder, 'topic', 'allLog.m');
paths.stimfunctions = fullfile(root_folder, 'stimfunctions');
paths.punishfunctions = fullfile(root_folder, 'punishfunctions');
paths.viewlocsfile = fullfile(root_folder, 'paramfiles', 'view_locs.txt');
paths.stimlookupfile = fullfile(root_folder, 'paramfiles', 'stimulus_lookup.txt');
paths.punishlookupfile = fullfile(root_folder, 'punishparamfiles', 'punish_lookup.txt');

Q.paths = paths;

Q.paths.chosenparameterfile = paramsfullpath;
Q.paths.probePath = probePath;
if(Q.toPunish)
    Q.paths.chosenpunishparameterfile = punishParamsFullPath;
end

[Q.stims.stimlookup,Q.stims.numList] = read_stimlookup(Q.paths.stimlookupfile);
if (Q.toPunish)
    Q.punish.punishlookup = read_stimlookup(Q.paths.punishlookupfile);
end
%create data file -MSC
mkdir(Q.paths.data); 

%% comment this back in prevent over-writing of data -no longer necessary with the new file system -MSC
%"yay Matt's the best"
%           -Matt
% if exist(paths.data,'dir')
%     disp('ERROR: data folder already exists -- aborting.');
%     return;
% else
%     mkdir(paths.data);
% end
% save the seed and current state so you can reproduce stimuli
seedState = rng('shuffle');
save(fullfile(Q.paths.data, 'seedState.mat'),'-struct','seedState');

if Q.stims.xtPlot
    handles.xtPlot = fopen(fullfile(paths.data,'xtPlot.xtp'),'w');
end

if Q.stims.movie
    handles.movie = VideoWriter([paths.data '\movie.avi']);
    %handles.movie = VideoWriter(fullfile(paths.data,'movie.mp4'),'MPEG-4');
    handles.movie.FrameRate = params(1).framesPerUp*60;
    open(handles.movie);
end

% set up handles for the various files to read and write to...
handles.metadata = fopen(fullfile(Q.paths.data, 'metadata.txt'),'w');
handles.stimdata = fopen(fullfile(Q.paths.data, 'stimdata.csv'),'w');
handles.respdata = fopen(fullfile(Q.paths.data, 'respdata.csv'),'w');
if Q.toPunish
    handles.laserStateData = fopen(fullfile(Q.paths.data, 'laserdata.csv'),'w');
    handles.flyStateData = fopen(fullfile(Q.paths.data, 'flydata.csv'),'w');
end

if ~strcmp(genostr,'test') && ~strcmp(genostr,'xtplot') && ~strcmp(genostr,'movie')
    mkdir(Q.paths.log);
    handles.log = fopen(fullfile(Q.paths.log,[Q.currTime(12:end) '_' paramFilename '_' genostr '.txt']),'w');
    handles.autoLog = fopen(Q.paths.autoLog,'a');
    if handles.autoLog == -1
        [pathstr, ~, ~] = fileparts(Q.paths.autoLog);
        mkdir(pathstr);
        handles.autoLog = fopen(Q.paths.autoLog,'a');
    end
    handles.allLog = fopen(Q.paths.allLog,'a');
end

%initMouse takes in a boolean input. If true, the mouse will return the dx
%and dy from the frame before the current stimulus. If 0 it will return the
%dx and dy from the current stimulus but it is 10x slower (5 +- 3ms). -MSC
%[handles.arduino,t_start] = initMouse(Q.mouse.delayRead);
%if Q.toPunish
%    handles.laserPort = initLaser();
%end
%%% fixed so that now summation occurs in the buffer and the mouse just
%%% reads off the buffer. takes ~3 - 5ms asynch
%[handles.arduino,t_start] = initMouse(Q.mouse.delayRead);
try
    [handles.arduino,~] = IOPort('OpenSerialPort','Com3',['BaudRate=115200','ReceiveTimeout=1','PollLatency=.001']);
catch err
    disp('could not talk to mouse in preliminary_setup ignoring and cont');
    Q.readMouse = 0;
    t = 0;
end

if Q.readMouse
    % make sure the arduino isn't already sending data
    IOPort('Write',handles.arduino,'b');
    % wait 5 ms to make sure arduino loop has finished and then clear the port
    WaitSecs(1/60);
    IOPort('Purge',handles.arduino);
end

t_start = GetSecs;

%if Q.toPunish
%    handles.laserPort = initLaser();
%end

Q.handles = handles;

if ~Q.OGL.useDLP
    DX = 0;
end
viewLocs = dlmread(Q.paths.viewlocsfile);


%First check if there is only one monitor for those situations where that's
%the case
availableMonitors = Screen('Screens');
multipleMonitors = length(availableMonitors)>1;

if multipleMonitors
    % make the primary drawing window, and save its handle to Q
    if SCREENCHOOSE == 2;
        windowID = Screen('OpenWindow',availableMonitors(end));
    else
        windowID = Screen('OpenWindow',SCREENCHOOSE,[],[0,0,608,684]);
    end
else
    % Let the user know there were no external monitors found and the main
    % screen will be used
    msg = msgbox('Your system has no external monitors--window will be opened on the main screen.', ...
        'Warning: no external monitors',...
        'modal');
    uiwait(msg);
    windowID = Screen('OpenWindow',0,[],[0,0,608,684]);
end
Screen('Fillrect',windowID,[0;0;0]);
Screen('Flip',windowID);
pause(1); % pauses for 10 seconds on gray... could make this longer or shorter

Q.OGL.windowID = windowID;
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
if Q.readMouse
    [mdx,mdy,mqv,t] = readMouse(handles.arduino);
end
Q.flyTimeline = flyTimeline(t_start,t);
Q.laserTimeline = laserTimeline(0,t);

% do some initial file writing to save stuff
save(fullfile(Q.paths.data, 'chosenparams.mat'),'params'); % save these into data folder
if(Q.toPunish)
    save(fullfile(Q.paths.data, 'chosenparams.mat'),'punishParams');
end

if(Q.toPunish)
    chosenPunishParameterFile = Q.paths.chosenpunishparameterfile;
else
    chosenPunishParameterFile = '';
end

write_strings_to_file(Q.handles.metadata,Q.currTime,... % first line is date and time
    chosenPunishParameterFile, ...
    Q.paths.chosenparameterfile,...
    Q.paths.stimlookupfile,...
    Q.paths.viewlocsfile,...
    ['xscales = ' num2str(flyloc.xscale)],...
    ['yscales = ' num2str(flyloc.yscale)],...
    ['tscales = ' num2str(flyloc.tscale)],...
    ['useDLP = ' num2str(useDLP)],... % then useDLP status
    ['genotype = ' genostr],...
    ['conditions = ' condstr],...
    ['box temperature = ' Q.stims.boxTemp],...
    ['COMMENTS BY HAND: ']);

%if not a test, repeat this for logbook but with better name -MSC
if ~strcmp(genostr,'test') && ~strcmp(genostr,'xtplot') && ~strcmp(genostr,'movie')
    write_strings_to_file(Q.handles.log,...
        Q.currTime,... % first line is date and time
        chosenPunishParameterFile, ...
        Q.paths.chosenparameterfile,...
        Q.paths.stimlookupfile,...
        Q.paths.viewlocsfile,...
        ['xscales = ' num2str(flyloc.xscale)],...
        ['yscales = ' num2str(flyloc.yscale)],...
        ['tscales = ' num2str(flyloc.tscale)],...
        ['useDLP = ' num2str(useDLP)],... % then useDLP status
        ['genotype = ' genostr],...
        ['conditions = ' condstr],...
        ['COMMENTS BY HAND: ']);
end

%% TO ADD: connect to arduino using ARD structure to store ports, etc. DO FIRST READS HERE, all required to set up
Q.ARD.h = 1;

%% start timing stuff
timing.t0 = GetSecs; % beginning timing
timing.framelastchange = 1; % for begin of each epoch
Q.timing = timing; % these will be updated frequently...

Q.genostr = genostr;

end
