function dataAligned = alignData(alignOnly, daysBackOrDataPath)
%%%%%% PARAM LOADING %%%%%

    a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
    disp(a);
    fprintf(a, 'Start\n');
    fprintf(a, '%s\n', pwd);
    fclose(a);
    try
        sysConfig = GetSystemConfiguration;
        twoPhotonBase = sysConfig.twoPhotonDataPathAlign;
        % twoPhotonBase = '/Volumes/TOSHIBA EXT/2p_microscope_data/';
        connDb = connectToDatabase(sysConfig.databasePathAlign);
        % dbstop if error
        if nargin<1
            daysBackOrDataPath = 1;
            alignOnly = false; % With automatic background selection, this should now work! Woo!
            force_new_ROIs = false;
        elseif nargin < 2
            daysBackOrDataPath = 1;
            force_new_ROIs = false;
        else
            force_new_ROIs = false;
        end
        
        if isnumeric(daysBackOrDataPath)
            dataReturn = fetch(connDb, sprintf('select relativeDataPath from  stimulusPresentation where date>"%s"', datestr(today-daysBackOrDataPath, 'yyyy-mm-dd')));
        elseif iscell(daysBackOrDataPath)
            dataReturn = daysBackOrDataPath;
        elseif ischar(daysBackOrDataPath)
            dataReturn = {daysBackOrDataPath};
        end
    catch err
        a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
        fprintf(a, '%s\n', err.message);
        fclose(a);
    end
% dataReturn = fetch(connDb, sprintf('select relativeDataPath from stimulusPresentation where stimulusFunction="GM_dtSweep_10dbars_10Hz"'));
try
tIn = tic;
if ~isempty(dataReturn)
    relativeDataPaths = dataReturn(:, 1);
    
    startI=0;
    for i = 1:length(relativeDataPaths)
        try
            % Existence of this file means that another process might be
            % aligning data
            cd(fullfile(twoPhotonBase, relativeDataPaths{i}))
            checkForTempF = dir('aligningDataPlaceholder.txt');
            if ~isempty(checkForTempF)
                % So we check to see if this is the case by trying to move the
                % file--if a process is still aligning data it will have
                % control of the file and not allow it to be moved, at that
                % point we kill this process because another process is running
                [success,~,~] = movefile('aligningDataPlaceholder.txt', 'checker.txt');
                if ~success
                    return
                    %                 return
                else
                    delete('checker.txt');
                    break
                end
            end
            checkForAlignment = dir('alignedImageData.mat');
            if isempty(checkForAlignment) && startI == 0
                startI = i;
            end
        catch err
            a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
            fprintf(a, '%s\n', err.message);
            warning('%s\n', err.message);
            fprintf(a, '%s\n%s\n\n', err.identifier, err.message);
            warning('%s\n%s\n\n', err.identifier, err.message);
            for stackInd = 1:length(err.stack)
                fprintf(a, 'File: %s\nFunction name: %s\nLine: %d\n', err.stack(stackInd).file, err.stack(stackInd).name, err.stack(stackInd).line);
                warning('File: %s\nFunction name: %s\nLine: %d\n', err.stack(stackInd).file, err.stack(stackInd).name, err.stack(stackInd).line);
            end
            fclose(a);
        end
    end
    if startI==0
        startI = 1;
    end
    for i = startI:length(relativeDataPaths)
        try
        a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
        fprintf(a, 'Aligning file:\n');
        fprintf(a, '%s\n', fullfile(twoPhotonBase, relativeDataPaths{i}));
        fclose(a);
        cd(fullfile(twoPhotonBase, relativeDataPaths{i}))
        % Create this file to secure this process's spot as the sole one
        % that will be aligning data
        a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
        fprintf(a, '\tIn this folder:\n');
        fprintf(a, '\t%s\n', pwd);
        fclose(a);
        tempF = fopen('aligningDataPlaceholder.txt', 'w');
        a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
        fprintf(a, '\tHandle:\n');
        fprintf(a, '\t%d\n', tempF);
        fclose(a);
        
        tifFiles = dir('*.tif');
        tifFileNames = {tifFiles.name};
        pat = 'ch\d_dis';
        tifFileName = tifFileNames{cellfun('isempty', regexp(tifFileNames, pat))};
        tOrig = [tifFileName(1:end-4) '_orig.tif'];
        if exist(tOrig, 'file')
            t = Tiff(tOrig);
            
            stateVar = t.getTag('ImageDescription');
            stateCell = strsplit(stateVar, sprintf('\r'));
            stateTerminated = strcat(stateCell, ';');
            stateString = strjoin(stateTerminated, sprintf('\r'));
            eval(stateString);
            
            Z.params.fn2 = tOrig;
        else
            t = Tiff(tifFileName);
            
            stateVar = t.getTag('ImageDescription');
            stateCell = strsplit(stateVar, sprintf('\r'));
            stateTerminated = strcat(stateCell, ';');
            stateString = strjoin(stateTerminated, sprintf('\r'));
            eval(stateString);
        end
        if state.acq.scanAngleMultiplierSlow==0
            linescan = true;
        else
            linescan =false;
        end
        channelsDesired = '12';
        channelsDesired = channelsDesired(logical([state.acq.savingChannel1 state.acq.savingChannel2]));
        clear state;
        
        close(t)
        
        try
            for channelAcq = 1:length(channelsDesired)
%                 if force_new_ROIs
                    Z.params.linescan = linescan;
                    Z.params.pathName = [fullfile(twoPhotonBase, relativeDataPaths{i}) '\'];
                    Z.params.fn = tifFileName;
                    [~, Z.params.name, ~] = fileparts(tifFileName);
                    Z.params.runPDAnalysis = 'Yes';
                    Z.params.channelDesired = channelsDesired(channelAcq);
                    Z.params.alignOnly = alignOnly;
                    twoPhotonImageParser(Z);
%                     Z = twoPhotonMaster('filename', fullfile(twoPhotonBase, relativeDataPaths{i}, tifFileName), 'linescan', linescan, 'channelDesired', channelsDesired(channelAcq), 'force_new_ROIs', false, 'alignOnly', alignOnly, 'filterRoiTraces', false, 'saveROIData', false);
%                     if ~isfield(Z, 'ROI')
%                         clear Z
%                         twoPhotonMaster('filename', fullfile(twoPhotonBase, relativeDataPaths{i}, tifFileName), 'linescan', linescan, 'channelDesired', channelsDesired(channelAcq), 'force_new_ROIs', force_new_ROIs, 'alignOnly', alignOnly);
%                     end
                    clear Z
%                 else
%                     twoPhotonMaster('filename', fullfile(twoPhotonBase, relativeDataPaths{i}, tifFileName), 'linescan', linescan, 'channelDesired', channelsDesired(channelAcq), 'force_new_ROIs', force_new_ROIs, 'alignOnly', alignOnly);
%                 end
                clear ans
                % In case an error has ever prevented this from running,
                % we're going to delete the file written here
                allFiles = dir;
                if any(strcmp({allFiles.name}, 'automatedDataPreprocessingErrors.txt'))
                    delete('automatedDataPreprocessingErrors.txt');
                end
            end
        catch err
            errorFileHandle = fopen('automatedDataPreprocessingErrors.txt', 'w');
            fprintf(errorFileHandle, '%s\n%s\n\n', err.identifier, err.message);
            for stackInd = 1:length(err.stack)
                fprintf(errorFileHandle, 'File: %s\nFunction name: %s\nLine: %d\n', err.stack(stackInd).file, err.stack(stackInd).name, err.stack(stackInd).line);
            end
            fclose(errorFileHandle);
        end
        
        % Delete the file to allow a new process to grab this one; honestly
        % there will be a double check to make sure that if the file is
        % still there, the process is actually still alive--i.e. by
        % checking that tempF is still not closed; one could suggest there
        % might be a race condition where tempF gets closed b
        % aligningDataPlacehold.txt doesn't get deleted yet when the other
        % process checks for this... but I'd be really unlucky if that
        % happened
        fclose(tempF);
        delete('aligningDataPlaceholder.txt');
        catch err
            a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
            fprintf(a, '%s\n', err.message);
            warning('%s\n', err.message);
            fprintf(a, '%s\n%s\n\n', err.identifier, err.message);
            warning('%s\n%s\n\n', err.identifier, err.message);
            for stackInd = 1:length(err.stack)
                fprintf(a, 'File: %s\nFunction name: %s\nLine: %d\n', err.stack(stackInd).file, err.stack(stackInd).name, err.stack(stackInd).line);
                warning('File: %s\nFunction name: %s\nLine: %d\n', err.stack(stackInd).file, err.stack(stackInd).name, err.stack(stackInd).line);
            end
            fclose(a);
        end
    end
end
catch err
    a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
    fprintf(a, '%s\n', err.message);
    warning('%s\n', err.message);
    fprintf(a, '%s\n%s\n\n', err.identifier, err.message);
    warning('%s\n%s\n\n', err.identifier, err.message);
    for stackInd = 1:length(err.stack)
        fprintf(a, 'File: %s\nFunction name: %s\nLine: %d\n', err.stack(stackInd).file, err.stack(stackInd).name, err.stack(stackInd).line);
        warning('File: %s\nFunction name: %s\nLine: %d\n', err.stack(stackInd).file, err.stack(stackInd).name, err.stack(stackInd).line);
    end
    fclose(a);
end
a = fopen('C:\Users\Clark Lab\mtlbLog.out', 'a');
fprintf(a, 'Finished aligning\n');
fclose(a);
tOut = toc(tIn);
dataAligned = tOut > 60;

close(connDb)

if dataAligned
    % Change them to the new format
    AssignFlyIdsImaging(relativeDataPaths);
else
    dataAligned = alignData(alignOnly, daysBackOrDataPath);
end