function CorrectDatabaseEntry(flyId, correctionStructure)
%CORRECTDATABASEENTRY correct a database entry caused by a bad genotype
%entered. This function is needed because correcting the genotype also
%changes the filepaths for the zstack as well as all the associated
%stimulusPresentations
% CORRECTDATABASEENTRY(FLYID, CORRECTIONSTRUCTURE)
%   FLYID is the id associated with the fly in the database. To get it,
%   first open the experimentLog.db file and find the fly table. In the fly
%   table, find the fly whose genotype you want to correct. There will be a
%   column called flyId--the entry for your fly under that column is FLYID.
%   CORRECTIONSTRUCTURE is a structure that contains correct entries for
%   the various columns of the fly row. It must AT LEAST contain a field
%   'genotype', which is where you put in the corrected genotype. Other
%   columns that can be changed are cellType, fluorescentProtein, surgeon,
%   and eye. If you want to change these as well, you can add them as
%   fields to CORRECTIONSTRUCTURE. If you DO NOT want to change genotype,
%   but do want to change the other columns, please do so in the database
%   viewer (the program SqliteBrowser is recommended). NOTE: this function
%   WILL ONLY WORK ON THE SCANIMAGE COMPUTER, as this is the only computer
%   whose changes get percolated throughout the system.


% We're going to use the MAC to check whether this is the scanimage computer
% (which is the only computer on which file system changes should occur)
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


% Check to make sure a fly with the flyId exists, and that the genotype is
% new for that fly
genotype = correctionStructure.genotype;
origFlyGenotype = fetch(databaseConnection, sprintf('select genotype from fly where flyId=%d', flyId));
if isempty(origFlyGenotype)
    error('You seem to have gotten the flyId incorrect. You input flyId=%d', flyId)
elseif strcmp(origFlyGenotype, genotype)
    disp('You didn''t give a different genotype so we''re exiting without doing anything.')
    return
end

% If they're adding a new genotype, make sure this is correct.
previousGenotypes = fetch(databaseConnection, 'select distinct genotype from fly');
if ~any(strcmp(previousGenotypes, genotype))
    strDists = StrDist(genotype, previousGenotypes);
    potentialCorrectGenotypes = previousGenotypes(strDists(:, 1)<3);
    [~, cancelled] = InputsDlg({[sprintf('Your correction will be a new genotype. Are you sure you meant to type %s?\n', genotype) 'Perhaps you meant one of these: | ' sprintf('%s | ', potentialCorrectGenotypes{:})]},...
        'Genotype Check',struct('type', 'text', 'labelloc', 'topleft'), [], struct('EditMePlease', true, 'ButtonNames', {{'Yes', 'No'}}, 'Interpreter', 'none'));
    if cancelled
        disp('Please rerun the function with the correct genotype. Exiting.');
        return;
    end
end

% One final check that the user does, in fact, want to make this change
[~, cancelled] = InputsDlg({[sprintf('Are you certain you want to switch flyId %d''s genotype from %s to %s?\n\nThis will also change the folder structure of all associated stimulus presentations acquisitions as well as the zstacks to reflect the change.\n\nIf you''re not sure you''re making the right move, please first consult the help file by running\n\nhelp CorrectDatabaseEntry\n\nAre you sure?\n\n', flyId, origFlyGenotype{1}, genotype)]},...
        'Final Check',struct('type', 'text', 'labelloc', 'topleft'), [], struct('EditMePlease', true, 'ButtonNames', {{'Yes', 'No'}}, 'Interpreter', 'none'));

if cancelled
    disp('You''re welcome back whenever you become sure!')
    return;
end

% Start by finding the z-stack path
relativePathZStack = fetch(databaseConnection, sprintf('select relativePath from fly where flyId=%d', flyId));
relativePathZStack = relativePathZStack{1};

if strcmp(relativePathZStack, 'null')
    warning('Apparently no z-stack was taken for this fly; we are only going to change relevant fly entries and the stimulusPresentation table paths.');
    moveZStack = false;
else
    moveZStack = true;
end

% Actually move the files and change the fly table to reflect where they've
% been moved
if moveZStack
    % Create the new z-stack path string
    origPath = relativePathZStack;
    origFullPath = fullfile(sysConfig.twoPhotonDataPathLocal, origPath);
    pathSplit = strsplit(origPath, origFlyGenotype{1});
    if length(pathSplit)~=2
        error('For some reason the fly''s original genotype occurs multiple times or not at all in the path to the fly z-stack. I don''t know how to shift around paths when this is the case.');
    end
    newPath = [pathSplit{1} genotype pathSplit{2}];
    
    newFullPath = fullfile(sysConfig.twoPhotonDataPathLocal, newPath);
    
    % Actually move the file
    [status,message,~] = movefile(origFullPath, newFullPath);
    if ~status
        error('Moving the z-stack failed. Matlab says:\n\n%s', message);
    else
        fprintf('Z-stack moved from\n\n%s\n\nto\n\n%s\n', origFullPath, newFullPath);
    end
    updateCommand = sprintf('update fly set relativePath="%s", genotype="%s" ', newPath, genotype);
else
    updateCommand = sprintf('update fly set genotype="%s" ', genotype);
end

% Update the database to reflect the move
updateFields = fieldnames(correctionStructure);
updatableFields = {'cellType', 'fluorescentProtein', 'surgeon', 'eye'};
fieldsToUpdate = updateFields(ismember(updateFields, updatableFields));

for field = 1:length(fieldsToUpdate)
    updateCommand = sprintf('%s, %s="%s" ', updateCommand, fieldsToUpdate{field}, correctionStructure.(fieldsToUpdate{field}));
end

updateCommand = sprintf('%s where flyId=%d', updateCommand, flyId);
returnStruc = exec(databaseConnection, updateCommand);
if ~isempty(returnStruc.message)
    warning('Looks like something went wrong when attempting to update the database. The message was\n\n%s\n\nPausing here to let you fix it.', returnStruc.message);
    keyboard;
end
if moveZStack
    fprintf('**Database updated to reflect move and any new column values given**\n');
else
    fprintf('**Database updated to reflect new column values given**\n');
end
    
% Move on to updating the associated stimulusPresentation relativeDataPath
% columns
stimPresForFly = fetch(databaseConnection, sprintf('select stimulusPresentationId from stimulusPresentation where fly=%d', flyId));
if isempty(stimPresForFly)
    disp('Looks like no stimuli were presented to the fly, and there''s nothing more to do! Goodbye.')
    return
end

stimPresForFly = [stimPresForFly{:}];

for stimPresNum = 1:length(stimPresForFly)
    % Create the new data path string
    relativePathToData = fetch(databaseConnection, sprintf('select relativeDataPath from stimulusPresentation where stimulusPresentationId=%d', stimPresForFly(stimPresNum)));
    origPath = relativePathToData{1};
    origFullPath = fullfile(sysConfig.twoPhotonDataPathLocal, origPath);
    pathSplit = strsplit(origPath, origFlyGenotype{1});
    if length(pathSplit)~=2
        warning('For some reason the fly''s original genotype occurs multiple times or not at all in the path to the fly z-stack. I don''t know how to shift around paths when this is the case.');
        keyboard
    end
    newPath = [pathSplit{1} genotype pathSplit{2}];
    
    newFullPath = fullfile(sysConfig.twoPhotonDataPathLocal, newPath);
    
    % Actually move the file
    [status,message,~] = movefile(origFullPath, newFullPath);
    if ~status
        warning('Moving the data failed. Matlab says:\n\n%s', message);
        keyboard
    else
        fprintf('Data moved from\n\n%s\n\nto\n\n%s\n', origFullPath, newFullPath);
    end
    
    % Update the database to reflect the move
    updateCommand = sprintf('update stimulusPresentation set relativeDataPath="%s" where stimulusPresentationId=%d', newPath, stimPresForFly(stimPresNum));
    returnStruc = exec(databaseConnection, updateCommand);
    if ~isempty(returnStruc.message)
        warning('Looks like something went wrong when attempting to update the database. The message was\n\n%s\n\nPausing here to let you fix it.', returnStruc.message);
        keyboard;
    end
    fprintf('**Database updated to reflect stimulus data move**\n');


end
