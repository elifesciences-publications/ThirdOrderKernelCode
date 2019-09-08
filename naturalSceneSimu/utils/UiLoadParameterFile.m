function [p,fullpath] = UiLoadParameterFile(filePath)

%% DAC 130502 -- function reads in parameter files, using format from my 
%% old parameter file structures. 

currdir = pwd;
homedir = pwd; % for now, change this to match later

% first, dialog box to acquire the file
cd(homedir);
[filename,path]=uigetfile([filePath '/*.txt'],'Select parameter file...');

if ~ischar(filename)
    p = [];
    fullpath = [];
    return
end

fullpath = [path filename]; % note, this will depend on OS

cd(path);

f = fopen(filename);
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
    epochNamesCell = L3cell;
    headerLines = 3;
    Nparams = Nparams-1;
else
    epochNamesCell = [];
    headerLines = 2;
end

f = fclose(f);

searchstr = ['%s' repmat('\t%f',[1 Nepochs])];

f = fopen(filename);
bigcell = textscan(f,searchstr,'Headerlines', headerLines);
f = fclose(f);

if ((size(bigcell,2) ~= Nepochs + 1) || (size(bigcell{1},1) ~= Nparams))
    disp('PARAMS or EPOCHS don''t match; try again.');
    p=[];
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
        p(jj) = Stimulus;
    else
        p(jj) = Punish;
    end
end

cd(currdir);



