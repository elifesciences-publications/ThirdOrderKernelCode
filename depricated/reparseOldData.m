function potentialTifFiles = reparseOldData(firstDate)

rootFolder = fileparts(which('master_stimulus'));
dataPathsHandle = fopen(fullfile(rootFolder, 'dataPath.csv'), 'r');
fgets(dataPathsHandle);fgets(dataPathsHandle); %Read in behavior data and logbook pathway entries
twoPhotonDataPath = fgetl(dataPathsHandle);
fclose(dataPathsHandle);

firstDateNum = datenum(firstDate, 'yyyy_mm_dd');

potentialTifFiles = subdir(fullfile(twoPhotonDataPath, '*.tif'));

allDateNums = cellfun(@(x) datenum(fileparts(x(length(twoPhotonDataPath)+2:end)), 'yyyy_mm_dd'), {potentialTifFiles.name});

potentialTifFiles = potentialTifFiles(allDateNums>firstDateNum);

nonAlignedFiles = cellfun('isempty', strfind({potentialTifFiles.name}, 'disinterleaved'));
alignedTifFiles = potentialTifFiles(~nonAlignedFiles);
potentialTifFiles = potentialTifFiles(nonAlignedFiles);

nonZStackFiles = cellfun('isempty', strfind(lower({potentialTifFiles.name}), 'zstack'));
potentialTifFiles = potentialTifFiles(nonZStackFiles);

nonTCPIPFiles = cellfun('isempty', strfind({potentialTifFiles.name}, 'TCPIP'));
potentialTifFiles = potentialTifFiles(nonTCPIPFiles);

nonProbeTestFiles = cellfun('isempty', strfind({potentialTifFiles.name}, 'probeTest'));
potentialTifFiles = potentialTifFiles(nonProbeTestFiles);

nonPDTestFiles = cellfun('isempty', strfind(lower({potentialTifFiles.name}), 'pd_test'));
nonPDTestGaussianFiles = cellfun('isempty', strfind({potentialTifFiles.name}, 'PD_test_Gaussian'));
potentialTifFiles = potentialTifFiles(nonPDTestFiles | ~nonPDTestGaussianFiles);

nonXPosFiles = cellfun('isempty', strfind(lower({potentialTifFiles.name}), 'xpos'));
potentialTifFiles = potentialTifFiles(nonXPosFiles);

nonTestGrabFiles = cellfun('isempty', strfind(lower({potentialTifFiles.name}), 'testgrab'));
nonTesterFiles = cellfun('isempty',  strfind(lower({potentialTifFiles.name}), 'tester'));
potentialTifFiles = potentialTifFiles(nonTestGrabFiles & nonTesterFiles);

nonComboStackFiles = cellfun(@(fullTifPath) all(cellfun('isempty', strfind({potentialTifFiles.name}, [fullTifPath(find(fullTifPath==filesep, 1, 'last')+1:end-4) '_1' fullTifPath(end-3:end)]))), {potentialTifFiles.name});
potentialTifFiles = potentialTifFiles(nonComboStackFiles);

dateDir = cellfun(@(fullTifPath) fullTifPath(length(twoPhotonDataPath)+2:length(twoPhotonDataPath)+11), {potentialTifFiles.name}, 'UniformOutput', false);
allDirPastDate = cellfun(@(fullTifPath) fullTifPath(length(twoPhotonDataPath)+12:end), {potentialTifFiles.name}, 'UniformOutput', false);
flyDir = cellfun(@(dirPastDate) dirPastDate(1:find(dirPastDate(2:end)==filesep, 1)), allDirPastDate, 'UniformOutput', false);
dateAndFly = cellfun(@(experimentDate, fly) [experimentDate fly], dateDir, flyDir, 'UniformOutput', false);

fliesRunPath = unique(dateAndFly);

conn = connectToDatabase;

for i = 1:length(fliesRunPath)
    curs = exec(conn, sprintf('select relativePath from fly where relativePath=''%s''', fliesRunPath{i}));
    curs = fetch(curs);
    % In case we stop the reparse midway, we don't want to write two of the
    % same flies!
    if ~strcmp(curs.Data, 'No Data')
        close(curs)
        continue
    end
    close(curs)
    dos(['explorer "' twoPhotonDataPath filesep fliesRunPath{i} '"']);
    prompts = {'Genotype','Fluorescent UAS','Cell type','Eye (left or right)', 'Condition','Surgeon'};
    dialogTitle = sprintf('Database input for fly %s', fliesRunPath{i});
    numLines = [1 80; 1 80; 1 80; 1 80; 1 80; 1 80];
    default = {'', '', '', '', '', ''};
    comments = inputdlg(prompts,dialogTitle,numLines,default,struct('WindowStyle', 'normal'));
    
    if isempty(comments) || all(cellfun('isempty',comments))
        warning('No comments about the data were written, so information about this run is being discarded');
        continue
    elseif any(cellfun('isempty',comments))
        % In case we accidentally pressed 'enter' >.>
        keyboard
    end
    
    flyGenotype = comments{1};
    fluorescentGenotype = comments{2};
    cellType = comments{3};
    eye = comments{4};
    flyCondition = comments{5};
    surgeon = comments{6};
    
    try
        datainsert(conn,'fly',{'relativePath', 'genotype', 'cellType', 'fluorescentProtein', 'eye', 'condition', 'surgeon'},{fliesRunPath{i}, flyGenotype, cellType, fluorescentGenotype, eye, flyCondition, surgeon})
    catch err
        if strcmp(err.identifier, 'MATLAB:Java:GenericException')
            keyboard
        else
            rethrow(err)
        end
    end

end

%Tacky, but the only way I can think of doing this sort of specificity
tifPathBlacklist = {'D:\2p_microscope_data\2014_10_29\Fly_1\T4T5_GC5m_60down007\',...
                    'D:\2p_microscope_data\2014_10_29\Fly_1\T4T5_GC5m_70down007\',...
                    'D:\2p_microscope_data\2014_10_29\Fly_1\T4T5_GC5m_70down008\'};
count = 0;
preparedDataPaths = {};
for i = 1:length(potentialTifFiles)
    fullTifPath = potentialTifFiles(i).name;
    if ~all(cellfun('isempty', strfind(tifPathBlacklist, fileparts(fullTifPath))))
        continue
    end
    experimentDate = fullTifPath(length(twoPhotonDataPath)+2:length(twoPhotonDataPath)+11);
    dirPastDate = fullTifPath(length(twoPhotonDataPath)+12:end);
    fly = dirPastDate(1:find(dirPastDate(2:end)==filesep, 1));
    
    curs = exec(conn, sprintf('select relativeDataPath from stimulusPresentation where relativeDataPath=''%s''', [experimentDate, dirPastDate]));
    curs = fetch(curs);
    % In case we stop the reparse midway, we don't want to write two of the
    % same flies!
    if ~strcmp(curs.Data, 'No Data')
        close(curs)
        continue
    end
    close(curs)
    
    if strcmp(fileparts(dirPastDate), fly)
        parentDir = fullfile(twoPhotonDataPath,experimentDate,dirPastDate(1:find(dirPastDate==filesep, 1, 'last')));
        if any(strcmp(parentDir, preparedDataPaths))
            [path, fn, ext] = fileparts(potentialTifFiles(i).name);
            potentialTifFiles(i) = dir(fullfile(path, fn, [fn '.tif']));
            potentialTifFiles(i).name = fullfile(path, fn, [fn '.tif']);
            fullTifPath = potentialTifFiles(i).name;
            % Only dirPastDate should change from above, but I'm paranoid?
            experimentDate = fullTifPath(length(twoPhotonDataPath)+2:length(twoPhotonDataPath)+11);
            dirPastDate = fullTifPath(length(twoPhotonDataPath)+12:end);
            fly = dirPastDate(1:find(dirPastDate(2:end)==filesep, 1));
        else
            dos(['explorer ' parentDir]);
            %         fprintf('Hint: run twoPhotonBulkDataPreparer on the parent\n');
            %         fprintf('directory, and then switch the appropriate indexes in\n');
            %         fprintf('potentialTifFiles (i.e. the indexes for all the files\n');
            %         fprintf('you''re twoPhotonBulkDataPreparer-ing) to be the values\n');
            %         fprintf('for the newly moved tif files! Here''s the parent folder:\n\n');
            %         disp(parentDir)
            %         fprintf('\nHere''s a sample call, remember to fill in the right variables!\n\n');
            %         fprintf('twoPhotonBulkDataPreparer(<fill_in_truefalse_linescan>, <fill_in_vector_of_channels>, ''directory'', ''%s'', ''recursive'', false)\n', parentDir);
            runPreparer = questdlg('Do you want to run non-recursive twoPhotonBulkDataPreparer on this folder?', '', 'Yes', 'No', 'Yes');
            if strcmp(runPreparer, 'Yes')
                prompts = {'linescan (1 for true, 0 for false)', 'channels (make it a vector if you want more than one [with brackets and everything!])'};
                dialogTitle = sprintf('twoPhotonBulkDataPreparer options for %s', parentDir);
                numLines = [1 80; 1 80];
                default = {'0', '1'};
                comments = inputdlg(prompts,dialogTitle,numLines,default,struct('WindowStyle', 'normal'));
                
                if isempty(comments) || all(cellfun('isempty',comments))
                    warning('No comments about the data were written, so information about this run is being ignored...');
                    keyboard
                elseif any(cellfun('isempty',comments))
                    % In case we accidentally pressed 'enter' >.>
                    keyboard
                end
                
                linescan = logical(str2num(comments{1}));
                channels = str2num(comments{2});
                twoPhotonBulkDataPreparer(linescan, channels, 'directory', parentDir, 'recursive', false)
                preparedDataPaths = [preparedDataPaths parentDir];
                
                % Prepare the current dataset now that it's been moved so that it can be analyzed! 
                [path, fn, ext] = fileparts(potentialTifFiles(i).name);
                potentialTifFiles(i) = dir(fullfile(path, fn, [fn '.tif']));
                potentialTifFiles(i).name = fullfile(path, fn, [fn '.tif']);
                fullTifPath = potentialTifFiles(i).name;
                % Only dirPastDate should change from above, but I'm paranoid?
                experimentDate = fullTifPath(length(twoPhotonDataPath)+2:length(twoPhotonDataPath)+11);
                dirPastDate = fullTifPath(length(twoPhotonDataPath)+12:end);
                fly = dirPastDate(1:find(dirPastDate(2:end)==filesep, 1));
            else
                continue
            end
        end
    end
    
    dos(['explorer "' fullfile(twoPhotonDataPath,experimentDate,dirPastDate(1:find(dirPastDate==filesep, 1, 'last')-1)) '"']);
    
    flyRunPath = [experimentDate fly];
    flyIdSQL = sprintf('select flyId,condition from fly where relativePath=''%s''', flyRunPath);
    curs = exec(conn, flyIdSQL);
    curs = fetch(curs);
    
    if size(curs.data, 1)>1
        keyboard
    end
    flyId = curs.data{1};
    relativeDataPath = [experimentDate, dirPastDate];
    acqDate = datestr(potentialTifFiles(i).date,'yyyy-mm-dd HH:MM:SS');
    
    prompts = {sprintf('The other entries are\n\nflyId: %d\nrelativeDataPath: %s\nDate: %s\nStimulus function', flyId, relativeDataPath, acqDate), 'Data quality', 'Tags (separate multiple by commas)'};
    dialogTitle = sprintf('Stimulus run information for %s', fullTifPath);
    numLines = [1 80; 1 80; 1 80];
    % If the fly condition was bad, default the data quality to bad
    if curs.data{2} == 1
        dataQualityDefault = '1';
    else
        dataQualityDefault = '';
    end
    
    close(curs);
    
    [~, stimFunctionDefault, ~] = fileparts(potentialTifFiles(i).name);
    default = {stimFunctionDefault, dataQualityDefault, ''};
    comments = inputdlg(prompts,dialogTitle,numLines,default,struct('WindowStyle', 'normal'));
    
    if any(cellfun('isempty',comments(1:end-1)))
        % In case we accidentally pressed 'enter' >.> But don't worry about
        % empty tags
        keyboard
        continue
    elseif isempty(comments)
        warning('No comments about the data were written, so information about this run is being ignored...');
        continue
    end
    
    stimFunction = comments{1};
    dataQuality = str2num(comments{2});
    tags = comments{3};
    
    try
        datainsert(conn,'stimulusPresentation',{'fly', 'relativeDataPath', 'stimulusFunction', 'dataQuality', 'date', 'tags'}, {flyId, relativeDataPath, stimFunction, dataQuality, acqDate, tags})
    catch err
        if strcmp(err.identifier, 'MATLAB:Java:GenericException')
            keyboard
        else
            rethrow(err)
        end
    end
    
end

% close(conn)

% Now we want to grab only those files for which an analysis run has been
% performed.
alignedTifFilePaths = unique(cellfun(@(fullTifPath) fileparts(fullTifPath), {alignedTifFiles.name}, 'UniformOutput', false));
filesThatHaveBeenAligned = cellfun(@(fullTifPath) any(strcmp(fileparts(fullTifPath), alignedTifFilePaths)), {potentialTifFiles.name});
potentialTifFiles = potentialTifFiles(filesThatHaveBeenAligned);

filesWithAnalysisRuns = cellfun(@(fullTifPath) isdir(fullfile(fileparts(fullTifPath), 'analysisRuns')), {potentialTifFiles.name});
potentialTifFiles = potentialTifFiles(filesWithAnalysisRuns);
% 
% for i = 1:length(potentialTifFiles)
% end
count=0;
for i = 1:length(potentialTifFiles)
    tifFile = potentialTifFiles(i).name;
    tifFilePath = fileparts(tifFile);
    analysisRunComments = dir(fullfile(tifFilePath, 'analysisRuns', '*.m'));
    if ~isempty(analysisRunComments)
        commentsFilePath = fullfile(tifFilePath, 'analysisRuns', analysisRunComments.name);
        commentsInfo = dir(commentsFilePath);
        if commentsInfo.bytes<10
            disp(fullfile(tifFilePath, 'analysisRuns', analysisRunComments.name));
        else
            commentsAll = fileread(commentsFilePath);
            % At least two new lines between each run
            commentsSplit = strsplit(commentsAll, [char(10) char(10) char(10)]);
            commentsSplit = commentsSplit(~cellfun('isempty', commentsSplit));
            commentsAnalysisRuns = commentsSplit(2:end);
            
            analysisMethodKey = 'Analysis method: ';
            commentsKey = 'Comments:';
            functionCallKey = 'Function call:';
            runInfoVariableKey = 'Run info variable:';
            for comInd = 1:length(commentsAnalysisRuns)
                commentAnalysisRun = commentsAnalysisRuns{comInd};
                
                analysisDateIndStart = 3;
                analysisDateIndEnd = find(commentAnalysisRun == char(10), 1)-1;
                analysisDate = commentAnalysisRun(analysisDateIndStart:analysisDateIndEnd); 
                
                curs = exec(conn, sprintf('select runDate from analysisRun where runDate=''%s''', analysisDate));
                curs = fetch(curs);
                % In case we stop the reparse midway, we don't want to write two of the
                % same flies!
                if ~strcmp(curs.Data, 'No Data')
                    close(curs)
                    continue
                end
                close(curs)
                
                flyIdSQL = sprintf('select stimulusPresentationId,dataQuality from stimulusPresentation where relativeDataPath=''%s''', tifFile(length(twoPhotonDataPath)+2:end));
                curs = exec(conn, flyIdSQL);
                curs = fetch(curs);
                
                stimulusPresentationId = curs.data{1};
                
                analysisMethodInd = strfind(commentAnalysisRun, analysisMethodKey);
                analysisMethodIndEnd = find(commentAnalysisRun(analysisMethodInd+1:end) == char(10), 1);
                analysisMethod = commentAnalysisRun(analysisMethodInd+length(analysisMethodKey):analysisMethodInd+analysisMethodIndEnd-1);
                
                analysisCommentsInd = strfind(commentAnalysisRun, commentsKey);
                analysisCommentsIndStart = find(commentAnalysisRun(analysisCommentsInd+1:end)=='%', 1) + analysisCommentsInd;
                analysisCommentsIndEnd = strfind(commentAnalysisRun(analysisCommentsIndStart+1:end), [char(10) char(10)]) + analysisCommentsIndStart-1;
                analysisComments = commentAnalysisRun(analysisCommentsIndStart:analysisCommentsIndEnd);
                
                functionCallInd = strfind(commentAnalysisRun, functionCallKey);
                functionCallIndStart = strfind(commentAnalysisRun(functionCallInd+1:end), char(10)) + functionCallInd;
                functionCallIndEnd = strfind(commentAnalysisRun(functionCallIndStart+1:end), char(10)) + functionCallIndStart-1;
                if ~isempty(functionCallIndEnd)
                    functionCall = commentAnalysisRun(functionCallIndStart(1):functionCallIndEnd(1));
                    
                    %Turns out I added the run info variable later on, so
                    %some of these analyses don't have one
                    runInfoVariableInd = strfind(commentAnalysisRun, runInfoVariableKey);
                    runInfoVariable = commentAnalysisRun(runInfoVariableInd+length(runInfoVariableKey):end);
                else
                    functionCall = commentAnalysisRun(functionCallIndStart(1):end);
                    runInfoVariable = '';
                end
                
                prompts = {sprintf('The other entries are\n\nStimulus: %d\nDate: %s\nMethod: %s\nFunction call: %s\nRun info variable: %s\nComments:\n%s\n\nAnalysis run quality', ...
                    stimulusPresentationId, analysisDate, analysisMethod, functionCall, runInfoVariable, analysisComments)};
                dialogTitle = sprintf('Analysis run information for %s', tifFile);
                numLines = [1 80];
                % If the fly condition was bad, default the data quality to bad
                if curs.data{2} == 1
                    analysisQualityDefault = '1';
                else
                    analysisQualityDefault = '';
                end
                
                close(curs);
                
                default = {analysisQualityDefault};
                comments = inputdlg(prompts,dialogTitle,numLines,default,struct('WindowStyle', 'normal'));
                
                if isempty(comments)
                    warning('No comments about the data were written, so information about this run is being ignored...');
                    continue
                else
                    analysisQuality = str2num(comments{1});
                end
                
                databaseInput = {analysisDate, stimulusPresentationId, analysisComments, functionCall, analysisMethod, runInfoVariable, analysisQuality};
                if  any(cellfun('isempty',databaseInput))
                    warning('Some data about this run is missing, so information about this run is being ignored...');
                    keyboard
                    continue
                end
            
                try
                    databaseInput = {analysisDate, stimulusPresentationId, analysisComments, functionCall, analysisMethod, runInfoVariable, analysisQuality};
                    datainsert(conn,'analysisRun',{'runDate', 'stimulus', 'comments', 'functionCall', 'analysisMethod', 'runInfoVariable', 'analysisQuality'}, ...
                        databaseInput)
                catch err
                    if strcmp(err.identifier, 'MATLAB:Java:GenericException') || strcmp(err.identifier, 'database:database:insertExecuteError')
                        keyboard
                    else
                        rethrow(err)
                    end
                end
            end
            
        end
    else
        disp('halp');
        count=count+1;
    end
end
disp(count)
close(conn)