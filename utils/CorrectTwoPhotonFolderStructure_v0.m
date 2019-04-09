function CorrectTwoPhotonFolderStructure
%CORRECTFOLDERSTRUCTURE corrects the structure of data in the two photon
%rig--it should affect only older data (before circa September 2015)
% CORRECTFOLDERSTRUCTURE
%   This function should only get run once (it won't do anything if you run
%   it more than once) and it will adjust things on the server. Data disks
%   that had been backed up before this change won't get changed
%   (obviously, since they're disconnected), but they will have their own
%   database files that will allow data to be retrieved from them anyway.


% We're going to use the MAC to check whether this is the scanimage
% computer (the server will be the one getting changed, but for good
% measure let's run datapath changing functions just on the scanimage
% computer)
[sysError, ipConfiguration] = system('ipconfig /all');
if ~sysError
    ipCell = regexp(ipConfiguration, 'Ethernet adapter Local Area Connection.*Physical Address[^\n\r\f]*: ([A-Z0-9]+\-[A-Z0-9]+\-[A-Z0-9]+\-[A-Z0-9]+\-[A-Z0-9]+\-[A-Z0-9]+)[\r\f\n]', 'tokens');
    try 
        ip = ipCell{1}{1};
    catch err
        if strcmp(err.identifier, 'MATLAB:nonExistentCellElement')
            error(sprintf(['Can''t identify your computers MAC address for some reason.\n' ...
                'The program couldn''t correctly parse the ipconfig /all command\n'...
                'to find this computer''s MAC address. You''re on your own to figure\n'...
                'this one out. Good luck.']));
        else
            rethrow(err)
        end
    end
else
    error('The system call to ipconfig failed');
end

twoPhotonMACAddress = 'B8-CA-3A-9C-F6-28';

if ~strcmp(ip, twoPhotonMACAddress)
     error(sprintf(['Looks like this isn''t the scanimage computer. If you believe\n'...
         'that it is, there''s a vanishingly small chance the scanimage computer''s\n'...
         'MAC address has changed (no there isn''t). If you''re 100%% certain you\n'...
         'want to continue down this path you''ve set yourself, go into\n'...
         'CorrectDatabaseEntry.m and change the variable twoPhotonMACAddress to the new\n'...
         'MAC address for the two photon acquisition computer. If you do this and\n'...
         'you''re not on the acquisition computer, DO NOT COMMIT THE CHANGE TO GIT.']));
end

sysConfig = GetSystemConfiguration;
databaseConnection = connectToDatabase(sysConfig.databasePathLocal);


% One final check that the user does, in fact, want to make this change
[~, cancelled] = InputsDlg(sprintf('Are you certain you want to switch the folder structure?!\n\nThis should only have to be done once, and it''ll affect the server.\n\nOne last chance to go back...'),...
        'Final Check',struct('type', 'text', 'labelloc', 'topleft'), [], struct('EditMePlease', true, 'ButtonNames', {{'Yes', 'No'}}, 'Interpreter', 'none'));

if cancelled
    disp('You''re welcome back whenever you become certain!')
    return;
end

% Go through each flyId and move the z-stack to the correct place (if a
% z-stack exists!)
uniqueFlyIds = fetch(databaseConnection, sprintf('select distinct flyId from fly' ));
for fly = 1:length(uniqueFlyIds)
    % Start by finding the z-stack path
    flyId = uniqueFlyIds{fly};
%     if flyId<length(uniqueFlyIds)
%         continue
%     end
    flyInfo = fetch(databaseConnection, sprintf('select relativePath, genotype from fly where flyId=%d', flyId));
    relativePathZStack = flyInfo{1};
    genotype = flyInfo{2};
    if strcmp(relativePathZStack, 'null')
%         warning('Apparently no z-stack was taken for this fly (or it wasn''t recorded in the database); we are only going to change stimulusPresentation table paths.');
        continue
    end
    
    % Create the new z-stack path string
    origPath = relativePathZStack;
    origCheckPath = fullfile(sysConfig.twoPhotonDataPathServer, origPath);
%     cd(origCheckPath)
    zStackCheck = dir(fullfile(origCheckPath, '*zStack*.tif'));
    
    
    % We create a new path based on dates and the like. First we check
    % whether this fly is already in the correct format
    newPathStart = fullfile('zStacks', genotype);
    % We don't need to move anything if it was saved correctly already
    if strfind(origPath, newPathStart) == 1
        continue
    end
    
    % We'll use the dir calls date for the file as the zStack time. The
    % moveAll parameter exists for the few occasions where multiple
    % z-stacks were taken
    moveAll = false;
    if isempty(zStackCheck)
%         warning('Apparently no z-stack was taken for this fly (or its name didn''t include /zStack*); we are only going to change stimulusPresentation table paths.');
        continue
    elseif length(zStackCheck) > 1
        warning('Looks like there might have been more than one associated z-stack with this fly. Not sure what to do. Waiting...');
        moveAll = true;
        assumedZStackDateTime = zStackCheck(end).date;
        keyboard
    else
        assumedZStackDateTime = zStackCheck(end).date;
    end
    
    if moveAll
        origFullPath = fullfile(origCheckPath, '*zStack*.tif');
    else
        origFullPath = fullfile(origCheckPath, zStackCheck.name);
    end
    
    % Actually move the files and change the fly table to reflect where
    % they've been moved.
    newPath = fullfile(newPathStart, datestr(assumedZStackDateTime, 'YYYY'), datestr(assumedZStackDateTime, 'mm_dd'), datestr(assumedZStackDateTime, 'hh_MM_ss'));
    if isequal(newPath, origPath)
        continue
    end
    newFullPath = fullfile(sysConfig.twoPhotonDataPathServer, newPath);
    
    % Actually move the file
    [success, message] = mkdir(newFullPath);
    if ~success
        error('Couldn''t create the new z-stack directory. Matlab says:\n\n%s', message);
    end
    [status,message,~] = movefile(origFullPath, newFullPath);
    if ~status
        error('Moving the z-stack failed. Matlab says:\n\n%s', message);
    else
        fprintf('Z-stack moved from\n\n%s\n\nto\n\n%s\n', origFullPath, newFullPath);
    end
    
    % Update the database to reflect the move
    updateCommand = sprintf('update fly set relativePath="%s" where flyId=%d', newPath, flyId);
    
    returnStruc = exec(databaseConnection, updateCommand);
    if ~isempty(returnStruc.message)
        warning('Looks like something went wrong when attempting to update the database. The message was\n\n%s\n\nPausing here to let you fix it.', returnStruc.message);
        keyboard;
    end
    fprintf('**Database updated to reflect move**\n');
    
   
end


% Move on to updating the associated stimulusPresentation relativeDataPath
% columns

% The structure of the folders will be based around the genotype, the
% time acquired, and the stimulusFunction so grab those bits of information.
stimPresInfo = fetch(databaseConnection, sprintf('select flyId, relativeDataPath, stimulusPresentationId, genotype, date, stimulusFunction from fly join stimulusPresentation on stimulusPresentation.fly=fly.flyId'));

for stimPresNum = 1:length(stimPresInfo)
    fprintf('%%%% Stim Pres %d %%%%\n', stimPresNum);
    % Grab info for this stimulus presentation
    stimulusPresentationId = stimPresInfo{stimPresNum, 3};
    genotype = stimPresInfo{stimPresNum, 4};
    dateAcquired = stimPresInfo{stimPresNum, 5};
    stimulusFunction = stimPresInfo{stimPresNum, 6};
    origPath = stimPresInfo{stimPresNum, 2};
    [pth, ~, ext] = fileparts(origPath);
    if ~isempty(ext)
        if isequal(ext, '.tif')
            origPath = pth;
        end
    end
    origFullPath = fullfile(sysConfig.twoPhotonDataPathServer, origPath);
    
    % Create new path string
    newPathStart = fullfile(genotype, stimulusFunction);
    % We don't need to move anything if it was saved correctly already
    if strfind(origPath, newPathStart) == 1
        continue
    end
    
    lastSeg = '';
    if ~isempty(strfind(lower(origPath), 'down')) || ~isempty(strfind(lower(origPath), 'below'))
        origPathTemp = origPath;
        while isempty(strfind(lower(lastSeg), 'down')) && isempty(strfind(lower(lastSeg), 'below'))
            [origPathTemp, lastSeg, ext] = fileparts(origPathTemp);
            lastSeg = [lastSeg ext];
        end
    end
    
    newPath = fullfile(newPathStart, datestr(dateAcquired, 'YYYY'), datestr(dateAcquired, 'mm_dd'), datestr(dateAcquired, 'hh_MM_ss'), lastSeg);
    newFullPath = fullfile(sysConfig.twoPhotonDataPathServer, newPath);
    
    % Actually move the file
    [success,message,~] = movefile(origFullPath, newFullPath);
    if ~success
        warning('Moving the data using movefile failed. Matlab says:\n\n%s\n\nTrying cygwin.', message);
        
        [statusCyg, messageCyg] = system(sprintf('"C:/cygwin64/bin/bash" -c "C:/cygwin64/bin/mv ''%s'' ''%s''"', origFullPath, newFullPath));
        if statusCyg
            error('Moving the data with cygwin failed. Cygwin says:\n\n%s', messageCyg);
        else
            fprintf('Data moved from\n\n%s\n\nto\n\n%s\n', origFullPath, newFullPath);
        end
    else
        fprintf('Data moved from\n\n%s\n\nto\n\n%s\n', origFullPath, newFullPath);
    end
    
    % Update the database to reflect the move
    updateCommand = sprintf('update stimulusPresentation set relativeDataPath="%s" where stimulusPresentationId=%d', newPath, stimulusPresentationId);
    returnStruc = exec(databaseConnection, updateCommand);
    if ~isempty(returnStruc.message)
        warning('Looks like something went wrong when attempting to update the database. The message was\n\n%s\n\nPausing here to let you fix it.', returnStruc.message);
        keyboard;
    end
    fprintf('**Database updated to reflect stimulus data move**\n');


end
