function InitiateTwoPhotonAcquisition

    % Press 'Esc' to quit program (gracefully!)
    escKey = [27 41];
    endProgram = false;
%     global timeoutSkipped
%     timeoutSkipped = false;

    dbstop if error




    global gh state
    saveToDatabase = true;
    if ~isfield(gh, 'mainControls')
        error('You haven''t run scanimage again. Run it and then rerun InitiateTwoPhotonAcquisition');
    else
        % We're grabbing the handle to the grabOneButton so that we can set off
        % grabs without having to actually hit the button, i.e. from code. That
        % way we can make it automatically start on command from the projector
        % computer
        grabOneButton = gh.mainControls.grabOneButton;
        sysConfig = GetSystemConfiguration;
        databaseConnection = connectToDatabase(sysConfig.databasePathLocal);
        relativeTwoPhotonDataPath = sysConfig.twoPhotonDataPathLocal;
    end
    
    
    laserConnected = PrepareLaser();
    global serialConnectionToMaiTaiLaser
    runEndAcquisition = onCleanup(@() ShutdownLaser);

%     if isempty(state.files.savePath)
%         % Set the save path for acquisitions--usually done by hitting the 'dir'
%         % button in the scanimage GUI
%         setSavePath()
%     end
    
%     mainSavePath = state.files.savePath;
%     databaseFlyInput.relativePath = mainSavePath;
    

    
    [f, zStackButton] = PrepareHoldingPatternGUI(relativeTwoPhotonDataPath, databaseConnection);
   
    
    % We wait for the go signal from the projector computer
    connectionToProjector = [];
    command = '';
    holdingPattern = true;
    % The switch statement will take care of breaking out of this loop
    while true
        if ~isempty(connectionToProjector) && connectionToProjector.BytesAvailable
            holdingPattern = false;
            % Writing an empty string is equivalent to just waiting for a
            % response
            command = SendTCPIPMessage(connectionToProjector, '');
            % TCPIP reads end up as column vectors, hence the transposing
            command = char(command');
            switch command
                case 'stimulusParameterFilename'
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    parameterFilename = char(returnMessage');
                    databaseStimulusPresentationInput.stimulusFunction = parameterFilename;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    genotype = char(returnMessage');
                    databaseFlyInput.genotype = genotype;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    behaviorId = char(returnMessage');
                    databaseFlyInput.behaviorId = behaviorId;
                    
                    if strcmp(genotype, 'test')
                        saveToDatabase = false;
                    end
                    
                    if saveToDatabase
                        relativePath = fullfile(genotype, parameterFilename, datestr(now(), 'yyyy'), datestr(now(), 'mm_dd'), datestr(now(), 'HH_MM_SS'));
                        saveFolderPath = fullfile(relativeTwoPhotonDataPath, relativePath);
                        mkdir(saveFolderPath)
                        

                        
                        % Here's the fraction of a day that is 60 minutes
                        sixtyMins = 1/24;
                        
                        previousGenotypes = fetch(databaseConnection, 'select distinct genotype from fly');
                        if ~any(strcmp(previousGenotypes, genotype))
                            strDists = StrDist(genotype, previousGenotypes);
                            potentialCorrectGenotypes = previousGenotypes(strDists(:, 1)<3);
                            [~, cancelled] = InputsDlg({[sprintf('This is a new genotype. Are you sure you meant to type %s?\n\n', genotype) 'Perhaps you meant one of these: | ' sprintf('%s | ', potentialCorrectGenotypes{:}) sprintf('\n\nClick ''Yes'' if this was, in fact, the correct genotype.')]},...
                                'Genotype Check',struct('type', 'text', 'labelloc', 'topleft'), [], struct('EditMePlease', true, 'ButtonNames', {{'Yes', 'No'}}, 'Interpreter', 'none'));
                            if ~cancelled
                                databaseFlyInput.genotype = genotype;
                            elseif cancelled && ~mod(cancelled, 1)
                                databaseFlyInput.genotype = UiGetGenotypeCorrection;
                            end
                            genotype = databaseFlyInput.genotype;
                        end
                        behaviorIdTemp = fetch(databaseConnection, sprintf('select behaviorId, flyId from fly join stimulusPresentation as sP on sP.fly=fly.flyId where genotype="%s" order by date desc limit 1', genotype));
                        if ~isempty(behaviorIdTemp)
                            behaviorId = behaviorIdTemp{1};
                            earliestStimPresentation = fetch(databaseConnection, sprintf('select date from stimulusPresentation where fly=%d order by date asc limit 1', behaviorIdTemp{2}));
                            dateNumEarliestPres = datenum(earliestStimPresentation);
                            zStackPath = fetch(databaseConnection, sprintf('select relativePath from fly where flyId=%d', behaviorIdTemp{2}));
                            
                            timeDiff = now()-dateNumEarliestPres;
                            if timeDiff > sixtyMins || ~strcmp(zStackPath{1}, 'null')
                                % We're checking if the fly's been on the rig
                                % for more than 45 minutes (an implicit
                                % assumption is being made that the time
                                % between placement on the rig and first scan
                                % is relatively small
                                newFly = questdlg('Is this a new fly? Either it''s been over an hour since you started or you seem to have taken a z stack already', 'New fly check', 'Yes', 'No', 'Yes');
                                if strcmp(newFly, 'Yes')
                                    databaseFlyInput.newFly = true;
                                else
                                    databaseFlyInput.newFly = false;
                                    databaseFlyInput.behaviorId = behaviorId;
                                end
                            else
                                databaseFlyInput.newFly = false;
                                databaseFlyInput.behaviorId = behaviorId;
                            end
                        else
                            databaseFlyInput.newFly = true;
                        end
                        databaseFlyInput.relativePath = '';
                    end
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, behaviorId);
                    cellType = char(returnMessage');
                    databaseFlyInput.cellType = cellType;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    fluorescentProtein = char(returnMessage');
                    databaseFlyInput.fluorescentProtein = fluorescentProtein;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    expressionSystem = char(returnMessage');
                    databaseFlyESJoinInput.expressionSystem = strsplit(expressionSystem, '\n');
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    surgeon = char(returnMessage');
                    databaseFlyInput.surgeon = surgeon;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    condition = char(returnMessage');
                    databaseFlyInput.condition = condition;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    eye = char(returnMessage');
                    databaseFlyInput.eye = eye;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    comments = char(returnMessage');
                    if strcmp(comments, 'no comment')
                        comments = '';
                    end
                    databaseStimulusPresentationInput.comments = comments;
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    perfusion = char(returnMessage');
                    databaseStimulusPresentationInput.perfusion = str2double(perfusion);
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    cylinderRotation = char(returnMessage');
                    databaseStimulusPresentationInput.cylinderRotation = str2double(cylinderRotation);
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    flyHeight = char(returnMessage');
                    databaseStimulusPresentationInput.flyHeight = str2double(flyHeight);
                    
                    set(zStackButton, 'Callback', {@SetupZStack, relativeTwoPhotonDataPath, genotype, [], databaseConnection});
                    
                    if saveToDatabase
                        flyId = databaseWrite(databaseConnection, databaseFlyInput, 'fly');
                        databaseStimulusPresentationInput.fly = flyId;
                        databaseFlyESJoinInput.fly = flyId;
                        databaseWrite(databaseConnection, databaseFlyESJoinInput, 'expressionSystemFlyJoin');
                        
                        set(zStackButton, 'Callback', {@SetupZStack, relativeTwoPhotonDataPath, genotype, databaseStimulusPresentationInput.fly, databaseConnection});
                        
                        zPos = state.motor.relZPosition;
                        filename = [parameterFilename '_' num2str(zPos) 'down'];
                        % Dis guy changes the appropriate filename field
                        set(gh.mainControls.baseName, 'String', filename);
                        % And dis guy does some callback that updates all
                        % appropriate scanimage variables
                        genericCallback(gh.mainControls.baseName);
                        
                        % Make the destination directory and save!
                        destinationDir = saveFolderPath;
                        success = mkdir(destinationDir);
                        if success
                            databaseStimulusPresentationInput.relativeDataPath = relativePath;
                        end
                        
                        SetScanImageSavePath(destinationDir)
                    end
                    
%                     % Updating the savePath requires updating the
%                     % fullfilename;
%                     state.files.savePath = destinationDir;
%                     updateFullFileName(0);
                    fwrite(connectionToProjector, 'ack');
                case 'grab'
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    grabDuration = char(returnMessage');
                    grabDuration = str2double(char(grabDuration'));
                    
                    
                    % This is in my experience greater than the number of
                    % seconds (which is usually closer to 5 or so) between
                    % starting psychToolbox and the first stimulus
                    % presentation
                    psychToolboxInitializationTime = 15;
                    totalGrabDuration = grabDuration + psychToolboxInitializationTime;
                    fprintf('The grab will last %d seconds.\n', totalGrabDuration);
                    framesInGrab = ceil(totalGrabDuration*state.acq.frameRate);
                    set(gh.mainControls.framesTotal, 'String', framesInGrab);
                    % Both of these are called with the framesTotal
                    % callback function
                    genericCallback(gh.mainControls.framesTotal);
                    preallocateMemory();
                    
                    % Grab the laser power the acquisition is being
                    % acquired at
                    databaseStimulusPresentationInput.laserPower = GetLaserPowerReadout;
                    
                    % Grab stimulus presentation time
                    stimulusPresentationDatetime = datestr(now(), 'yyyy-mm-dd HH:MM:SS');
                    databaseStimulusPresentationInput.date = stimulusPresentationDatetime;
                    if saveToDatabase
                        connectionToRaspberryPi = OpenTCPIPRaspberryPi;
                        
                        pmtUsed = find(logical([state.acq.acquiringChannel1 state.acq.acquiringChannel2]));
                        pmtRefs = 'AB';
                        pmtRun = pmtRefs(pmtUsed);
                        
                        if ~isempty(connectionToRaspberryPi)
                            returnMessage = SendTCPIPMessage(connectionToRaspberryPi, stimulusPresentationDatetime, 0, 10);
                            if strcmp(char(returnMessage'), 'cameraRecorded')
                                channelAnalyzeOpts = 'LR';
                                
                                channelAnalyze = channelAnalyzeOpts(pmtUsed);
                                secondsToWaitForAnalysis = 6; %Should be enough for the worst ones, I think...
                                pmtVoltages = SendTCPIPMessage(connectionToRaspberryPi, channelAnalyze, 0, secondsToWaitForAnalysis);
                                pmtVoltages = char(pmtVoltages');
                                pmtVoltages = strsplit(pmtVoltages, sprintf('\n'));
                                
                                if length(pmtVoltages)>1
                                    % This might be a problem at some point,
                                    % but not yet. It'll happen if we're
                                    % reading from both PMT channels
                                    if length(pmtRun) == 2
                                        dialogQuestion = [sprintf('Are PMT %s and %s''s voltages %s and %s, respectively? ', pmtRun(1), pmtVoltages{1}, pmtRun(2), pmtVoltages(2)) '(Timeout will occur in 10s if not responded)'];
                                    else
                                        dialogQuestion = [sprintf('Is PMT %s''s voltage %s? ', pmtRun(1), pmtVoltages{1}) '(Timeout will occur in 10s if not responded)'];
                                    end
                                    keyboard
                                else
                                    dialogQuestion = [sprintf('Is PMT %s''s voltage %s? ', pmtRun, pmtVoltages{:}) '(Timeout will occur in 10s if not responded)'];
                                end
                                %                             pmtVoltageCheck = questdlg(sprintf('Is the PMT voltage %s? ', pmtVoltage{:}), 'PMT Voltage Check', 'Yes', 'No', 'Yes');
                                [~, cancelled] = InputsDlg({dialogQuestion},...
                                    'PMT Voltage Check',struct('type', 'text', 'labelloc', 'topleft'), [], struct('Timeout', 10, 'EditMePlease', true, 'ButtonNames', {{'Yes', 'No'}}));
                                if cancelled && ~mod(cancelled, 1)
                                    pmtVoltages = UiGetVoltageCorrection;
                                end
                                for i = 1:length(pmtRun)
                                    pmtVoltageField = ['pmt' pmtRun(i) 'Voltage'];
                                    if ~cancelled || (cancelled && ~mod(cancelled, 1))
                                        
                                        databaseStimulusPresentationInput.(pmtVoltageField) = str2double(pmtVoltages{i});
                                    elseif mod(cancelled, 1)
                                        % We put positive values into the database
                                        % when they haven't been confirmed by a
                                        % human
                                        databaseStimulusPresentationInput.(pmtVoltageField) = -1*(str2double(pmtVoltages{i}));
                                    end
                                end
                            else
                                pmtVoltages = UiGetVoltageCorrection;
                                
                                for i = 1:length(pmtRun)
                                    pmtVoltageField = ['pmt' pmtRun(i) 'Voltage'];
                                    databaseStimulusPresentationInput.(pmtVoltageField) = str2double(pmtVoltages{i});
                                end
                            end
                            fclose(connectionToRaspberryPi);
                        else
                            pmtVoltages = UiGetVoltageCorrection;
                            
                            for i = 1:length(pmtRun)
                                pmtVoltageField = ['pmt' pmtRun(i) 'Voltage'];
                                databaseStimulusPresentationInput.(pmtVoltageField) = str2double(pmtVoltages{i});
                            end
                        end
                    end
                    
                    fwrite(connectionToProjector, 'ack');
                    if saveToDatabase
                        executeGrabOneCallback(grabOneButton)
                    end
                    
                    % Add five minutes to the laser on time for wiggle room
                    % in case of errors
                    if laserConnected
                        laserOnTime = totalGrabDuration+300;
                        warning('Laser will remain on for %0.2f minutes EVEN IF THE COMPUTER TURNS OFF', laserOnTime/60)
                        ControlMaiTai(serialConnectionToMaiTaiLaser, 'TIMER:WATCHDOG', totalGrabDuration+300);
                    end
                    % Add 3 seconds to the pause for some additional wiggle
                    % time
                    pause(totalGrabDuration+3)
                    
                    if saveToDatabase
                        dataQuality = InputsDlg({'What was the quality of the stimulus data (1-5)? (Dialog will timeout in 60s with default NaN value.)'},...
                            'Stimulus data quality',struct('labelloc', 'topleft'), [], struct('Timeout', 60));
                        databaseStimulusPresentationInput.dataQuality = str2double(dataQuality{1});
                        databaseWrite(databaseConnection, databaseStimulusPresentationInput, 'stimulusPresentation');
                    end
                case 'transferData'
                    if saveToDatabase
                        destinationFolder = state.files.savePath;
                        cd(destinationFolder)
                    end
                    
                    returnMessage = SendTCPIPMessage(connectionToProjector, 'ack');
                    originBehaviorFolder = char(returnMessage');
                    if saveToDatabase
                        % We're running through Cygwin here, so we need to have
                        % Linux fileseps as well as the /cygwin/c/ syntax to
                        % direct the location
                        originBehaviorFolder(originBehaviorFolder == '\') = '/';
                        originBehaviorFolder = ['/cygdrive/c/' originBehaviorFolder(4:end)];
                        % Create the directory everything's gonna be dropped
                        % into
                        
                        % Make the batchfile that will transfer everything over
                        sftpBatchFilename = 'sftpTransferComands.batch';
                        sftpBatchFile = fopen(sftpBatchFilename, 'w');
                        % Grab the file from the behavior computer
                        fprintf(sftpBatchFile, 'get -r "%s" "%s"\n', originBehaviorFolder, destinationFolder);
                        % Quit the SFTP session
                        fprintf(sftpBatchFile, 'quit');
                        
                        fclose(sftpBatchFile);
                        
                        % Run these commands! The pause is because it fails
                        % without it...?
                        pause(0.01)
                        ipAddressProjComp = '172.29.53.143';
                        stimFileGrab = system(['C:\cygwin64\bin\bash --login -c ''sftp -b "' fullfile(pwd, sftpBatchFilename) '" clarkLab@' ipAddressProjComp]);
                        
                        
                        % Switch folder name to stimulusData
                        [~, behaviorFolderName1, behaviorFolderName2] = fileparts(originBehaviorFolder);
                        behaviorFolderName = [behaviorFolderName1 behaviorFolderName2];
                        [success,~,~] = movefile(behaviorFolderName, 'stimulusData');
                       if stimFileGrab
                            fprintf(['Warning! You didn''t manage to grab the stimulus data from the projector computer. Debugging:\n'...
                                'A) The Cygwin server on the projector computer might have not initiated appropriately.\n'...
                                ' - To resolve, start Cygwin on that computer using ''Run As Administrator'' and type in\n'...
                                '                   net start sshd\n'...
                                '   You will hopefully get the messages:\n'...
                                '                   The CYGWIN sshd service is starting.\n'...
                                '                   The CYGWIN sshd service was started successfully\n'...
                                '   Once this happens you can manually rerun the line above this message\n'...
                                '   in the code (the line starting with\n'...
                                '                   stimFileGrab = ...\n'...
                                'B) The IP addess for the projector computer might have changed\n'...
                                ' - To check and resolve, run Cygwin on the projector computer and type\n'...
                                '                   ipconfig\n'...
                                '   The line starting with\n'...
                                '                   IPv4 Address. . . .\n'...
                                '   should have the IP address\n'...
                                '                   %s\n'...
                                '   If it does not, change the variable\n'...
                                '                   ipAddressProjComp\n'...
                                '   above this error message in the code to the IP address listed\n'...
                                'C) If none of this works, in the eternal words of Gob, something''s gone wrong.\n'], ipAddressProjComp);
                                keyboard
                       elseif ~success
                           fprintf(['Warning! The stimulusData folder was''t renamed correctly. This is\n'...
                                'an annoying problem related to the size of file paths in Windows, and\n'...
                                'likely has to do with your long stimulus function name. Debugging:\n'...
                                'A) Manually rename the folder\n'...
                                '                   %s\n'...
                                '   (which should be in the file directory Matlab''s currently pointed to)\n'...
                                '   to have the name\n'...
                                '                   stimulusData\n'...
                                'If this doesn''t work... you''re going to have a long day.\n'], behaviorFolderName);
                            keyboard
                       end
                    end
                    
                    % change the savePath back to the mainSavePath so
                    % subsequent grabs don't keep embedding into folders
%                     state.files.savePath = mainSavePath;
%                     updateFullFileName(0);
                    
                    fwrite(connectionToProjector, 'done')
                case 'end'
%                     cd(mainSavePath);
                    fclose(connectionToProjector);
%                     delete(serverTCPIPobject);
                    holdingPattern = true;
%                     break
            end
            %         pause(0.01)
        elseif endProgram
            % Clear out the save path so the user's forced to select the
            % directory again (which will likely be a newly created
            % directory for a new fly) instead of having stuff saved to the
            % old directory
            state.files.savePath = '';
            close(databaseConnection)
            close(f)
            break;
        elseif holdingPattern
            disp('Press continue when you are ready to do so. Press continue + ESC simultaneously to exit out.');
            set(f, 'Visible', 'on');
%             while ~timeoutSkipped
%                 uiwait(f, 10);
%                 if laserConnected
%                     ControlMaiTai('READ:POWER?', [], false);
%                 end
%             end
%             timeoutSkipped = false;
            uiwait(f);
            set(f, 'Visible', 'off');
            
            % If escape is pressed, quit immediately
            [pressBOOL,dum,keyList]=KbCheck;
            if any(keyList(escKey))
                endProgram = true;
                % Reset the MaiTai to require a ping every second
%                 if laserConnected
%                     ControlMaiTai(serialConnectionToMaiTaiLaser, 'TIMER:WATCHDOG', 1);
%                     out = ControlMaiTai(serialConnectionToMaiTaiLaser, 'OFF');
%                     ControlMaiTai(serialConnectionToMaiTaiLaser, 'SHUTTER', '0');
%                 end
                break;
            end
            
            if isempty(connectionToProjector)
                connectionToProjector = OpenTCPIPConnectionToProjector;
            end
            try fopen(connectionToProjector);
                holdingPattern=false;
%                 setSavePath()
%                 mainSavePath = state.files.savePath;
%                 databaseFlyInput.relativePath = mainSavePath;
            catch err
                if ~strcmp(err.identifier, 'instrument:fopen:opfailed')
%                     if laserConnected
%                         ControlMaiTai(serialConnectionToMaiTaiLaser, 'TIMER:WATCHDOG', 1);
%                         out = ControlMaiTai(serialConnectionToMaiTaiLaser, 'OFF');
%                         ControlMaiTai(serialConnectionToMaiTaiLaser, 'SHUTTER', '0')
%                     end
                    rethrow(err)
                end
            end
            pause(1)
        end
    end
end



% This prepares the GUI with 'continue' and 'grab z-stack'
function [figureHandle, zStackButton] = PrepareHoldingPatternGUI(relativeTwoPhotonDataPath, databaseConnection)
    figureHandle = figure;
    set(figureHandle, 'ToolBar', 'none')
    set(figureHandle, 'MenuBar', 'none')
    set(figureHandle, 'Position', [500 500 300 80])
    set(figureHandle, 'Name', 'Press when ready')
    set(figureHandle, 'NumberTitle', 'off')
    zStackButton = uicontrol('Position',[0 0 300 40],'String','Grab Z Stack',...
        'BackgroundColor', 'red');
    h = uicontrol('Position',[0 40 300 40],'String','Continue',...
        'Callback',{@ResumeDataGrab}, 'BackgroundColor', 'green');
    set(figureHandle, 'Visible', 'off');
    
    % We setup the zstack button here in case the program exits out and we
    % need to still grab the zstack. It'll automagically generate a z-stack
    % for the last fly
    set(zStackButton, 'Callback', {@GrabFlyZStack, relativeTwoPhotonDataPath, databaseConnection});
end

% This is what happens when 'Continue' is pressed
function ResumeDataGrab(~, ~)
    uiresume(gcbf)
%     global timeoutSkipped
%     timeoutSkipped = true;
end

% Allows us to grab the z-stack at 
function GrabFlyZStack(hObject, callbackdata, relativeTwoPhotonDataPath, databaseConnection)

    dataReturn = fetch(databaseConnection, 'select relativePath, genotype, flyId from fly order by flyId desc limit 1');
    if ~strcmp(dataReturn{1}, 'null')
        warning('You''ve already grabbed a z stack for the latest fly!')
        return
    else
        genotype = dataReturn{2};
        flyId = dataReturn{3};

        SetupZStack(hObject, callbackdata, relativeTwoPhotonDataPath, genotype, flyId, databaseConnection)
    end

end
    
function SetupZStack(~, ~, relativeTwoPhotonDataPath, genotype, flyId, databaseConnection)

    relativeFolderPath = fullfile('zStacks', genotype, datestr(now(), 'yyyy'), datestr(now(), 'mm_dd'), datestr(now(), 'HH_MM_SS'));
    saveFolderPath = fullfile(relativeTwoPhotonDataPath, relativeFolderPath);

    global gh state
    f = figure;
    set(f, 'ToolBar', 'none')
    set(f, 'MenuBar', 'none')
    set(f, 'Position', [500 500 300 40])
    set(f, 'Name', 'Press when ready')
    set(f, 'NumberTitle', 'off')
    zStartEndButton = uicontrol('Position',[0 0 300 40],'String','Move the stage to the SHALLOWEST z position and click here',...
        'Callback','uiresume(gcbf)', 'BackgroundColor', 'yellow');
    uiwait(f)

    % Gotta read position to have it stored in state
    turnOffMotorButtons;
    motorGetPosition();
    turnOnMotorButtons;
    zHighPos = state.motor.relZPosition;

    set(zStartEndButton,'String','Move the stage to the DEEPEST z position and click here');
    uiwait(f)

    % Gotta read position to have it stored in state
    turnOffMotorButtons;
    motorGetPosition();
    turnOnMotorButtons;
    zLowPos = state.motor.relZPosition;
    close(f)

    zPos = state.motor.relZPosition;
    xPos = state.motor.relXPosition;
    yPos = state.motor.relYPosition;

    % Dis guy changes the appropriate filename field
    set(gh.mainControls.baseName, 'String', 'zStack');
    % And dis guy does some callback that updates all
    % appropriate scanimage variables
    genericCallback(gh.mainControls.baseName);
    preallocateMemory();


    success = mkdir(saveFolderPath);
    if success
        if ~isempty(flyId)
            update(databaseConnection, 'fly', {'relativePath'}, {relativeFolderPath}, sprintf('where flyId=%d', flyId));
        end
    else
        warning('Not grabbing z-stack :(, couldn''t make the directory %s', saveFolderPath );
    end

    % Move the motor to the top of the grab-->pause to make sure the motor has
    % time to actually move the scope!
    motorSetPositionRelative([xPos yPos zHighPos], 'verify')
    pause(1);

    % Set the save path
    SetScanImageSavePath(saveFolderPath)

    % Load up the z stack config
    fileFields = fieldnames(state.files);
    configFields = fileFields(cellfun(@(field) any(strfind(field, 'fastConfig')) && length(field)==11, fileFields));
    for i = 1:length(configFields)
        if any(strfind(state.files.(configFields{i}), 'zStack'))
            configNum = i;
            break
        end
    end
    loadFastConfig(configNum,false)

    % Update the total number of frames
    stepsPerSlice = str2num(get(gh.motorControls.etZStepPerSlice, 'String'));
    framesInGrab = ceil((zHighPos-zLowPos)/abs(stepsPerSlice));
    % This is the line that actually changes how many slices sccanimage grabs
    state.acq.numberOfZSlices = framesInGrab;
    set(gh.mainControls.slicesTotal, 'String', framesInGrab);
    % Both of these are called with the framesTotal
    % callback function
    genericCallback(gh.mainControls.framesTotal);
    preallocateMemory();

    % Initiate the grab
    grabOneButton = gh.mainControls.grabOneButton;
    executeGrabOneCallback(grabOneButton)

end

function ShutdownLaser
    global serialConnectionToMaiTaiLaser
    if isvalid(serialConnectionToMaiTaiLaser)
        ControlMaiTai(serialConnectionToMaiTaiLaser, 'TIMER:WATCHDOG', 180); % Allow three minutes for the user to realize they made a mistake
%         ControlMaiTai(serialConnectionToMaiTaiLaser, 'OFF');
        ControlMaiTai(serialConnectionToMaiTaiLaser, 'SHUTTER', '0');
        fclose(serialConnectionToMaiTaiLaser); % Free up the laser
        delete(serialConnectionToMaiTaiLaser);
    end
end
