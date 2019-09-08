function [p,filePaths,probePath] = UiLoadMultiFiles(fileLoc)

%% DAC 130502 -- function reads in parameter files, using format from my 
%% old parameter file structures. 

currdir = pwd;
homedir = pwd; % for now, change this to match later

% first, dialog box to acquire the file
cd(homedir);
filePaths = UiPickFiles('FilterSpec',fileLoc,'Prompt','Select parameter files to run');

promptResponse = questdlg('Do you want a probe stimulus to precede these stimuli?', 'Probe Stimulus', 'Yes', 'No', 'Yes');
switch promptResponse
    case 'Yes'
        probe = true;
    case 'No'
        probe = false;
end

if probe
    [probeParams,paramsFullPath] = UiLoadParameterFile(fileLoc);
    [~, stimulusFilename, ~] = fileparts(paramsFullPath);
    if ~isfield(probeParams, 'totalTime')
        answer = inputdlg({'For how many seconds do you want to present the probe?'},...
            stimulusFilename,[1 80]);
        probeParams(1).totalTime = str2double(answer{1})*60; %60 converts seconds to frames
        probeDuration = str2double(answer{1});
    else
        probeDuration = probeParams(1).totalTime/60; %60 here converts frames to seconds
    end
    probePath = paramsFullPath;
    
else
    probeDuration = 0;
    probePath = '';
end

for ff = 1:length(filePaths);
    f = fopen(filePaths{ff});
    L1 = fgets(f);
    L2 = fgets(f);
    L1cell = textscan(L1,'%s\t%f');
    L2cell = textscan(L2,'%s\t%f');
    Nparams = L1cell{2};
    Nepochs = L2cell{2};
    L3 = fgets(f);
    L3cell = textscan(L3, ['%s' repmat('%s',[1 Nepochs])], 1, 'Delimiter', '\t');
    stimProp = L3cell{1};
    if ~isempty(findstr(stimProp{1}, 'epochName'));
        searchstr = repmat('%s',[1 Nepochs]);
        epochNamesCell = L3cell;
        headerLines = 3;
        Nparams = Nparams-1;
    else
        epochNamesCell = [];
        headerLines = 2;
    end

    f = fclose(f);

    searchstr = ['%s' repmat('\t%f',[1 Nepochs])];

    f = fopen(filePaths{ff});
    bigcell = textscan(f,searchstr,'Headerlines',headerLines);
    f = fclose(f);

    if ((size(bigcell,2) ~= Nepochs + 1) + (size(bigcell{1},1) ~= Nparams))
        disp('PARAMS or EPOCHS don''t match; try again.');
        p{ff}=[];
        return;
    end
    

    
    
    for jj=1:Nepochs
        if ~isempty(epochNamesCell)
            eval([epochNamesCell{1}{1} '= epochNamesCell{1+jj}{1};']);
        end
        for ii=1:Nparams
            eval([bigcell{1}{ii} '= bigcell{1+jj}(ii);']); % this will name everything either Stimulus or Punish, promise
        end
        if (exist('Stimulus'))
            p{ff}(jj) = Stimulus;
        else
            p{ff}(jj) = Punish;
        end
    end
    
    if ~isfield(p{ff}, 'totalTime')
        [~, stimulusFilename, ~] = fileparts(filePaths{ff});
        answer = inputdlg({'For how many seconds do you want to present the stimulus?'},...
                stimulusFilename,[1 80]);
            
        % Multiply by 60 for 60 frames/second that the projector
        % outputs--check out master_stimulus to see how this works
        stimDuration = str2double(answer{1})*60;
        p{ff}(1).totalTime = stimDuration;
    end
    
    if probe
        probeFields = fields(probeParams);
        stimFields = fields(p{ff});
        % Note that totalTime should be in p{ff} no matter what according
        % to the totalTime if statement above
        probeDuration = probeParams(1).totalTime;
        stimDuration = p{ff}(1).totalTime;
        
        for probeField = probeFields'
            if ~any(strcmp(stimFields, probeField))
                p{ff}(1).(probeField{1}) = '';
            end
        end
        
        for stimField = stimFields'
            if ~any(strcmp(probeFields, stimField))
                probeParams(1).(stimField{1}) = '';
            end
        end
        
        p{ff} = [probeParams p{ff}];
        p{ff}(1).totalTime = probeDuration + stimDuration;
        p{ff}(end).nextEpoch = length(probeParams)+1;
    end

    cd(currdir);
    
end

end

