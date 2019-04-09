function RunStimulus(Q)
    % function executes a psych toolbox stimulus for the flies on the rigs

    %press 'Esc' to quit program (gracefully!)
    escKey = [27 41];
    premature_end = false;
    align = logical(Q.stims.align);

    %% set up screens, paths, and handles for writing
    %% initializes serial ports, labjack, reads mice once, etc.
    %% collect various bits of user input
    %% Q contains all the relevant information for future stuff
    showDX = 0;
    showDY = 0;
   
    Nframes = Q.stims.duration;
     %Nframes = 30*60;

    stimT = zeros(Nframes,1);
    flipT = zeros(Nframes,1);
    totalT = zeros(Nframes,1);
    numReads = zeros(Nframes,1);
    
    timing.t0 = 0; % Offset from which timing information is recorded
    timing.framelastchange = 1; % for begin of each epoch
    timing.flipt = 0; % relative time of most recent flip
    timing.framenumber = 1;
    Q.timing = timing; % these will be updated frequently...
    
    % functions to run when the run finishes
    runShutdownStimulous = onCleanup(@() ShutdownStimulus(Q));
    runBackUpFiles = onCleanup(@() BackupTextMFiles(Q));
    
    if Q.photoDiodeSync
        t0 = photoDiodeSyncSignal(Q);
    else
        t0 = GetSecs();
    end
    Q.timing.t0 = t0;
    Q.timing.flipt = t0;
    
    % There should be 20 commas for the 20 data columns
    fprintf(Q.handles.stimdata,'Time,FrameNumber,Epoch,ClosedLoopStimulusData,,,,,,,,,,StimulusData,,,,,,,,,,,,,,,,,,,,Flash\n');
    
    firstDisp = 1;
    %% giant for loop for every frame -- 20 minutes at 60 Hz
    for frameNum = 1:Nframes
        frameStart = GetSecs();
        % for optimally short time between a mouse read and a flip, a delay
        % should occur here. If the stimulus generation time is constant this
        % will cause 3/4 of the flip time wait to occur here rather than before
        % flipping.
%         if frameNum > 11
%             WaitSecs(1/2*(1/60 - max(stimT(frameNum-11:frameNum-1))));
%         end

        stimStart = GetSecs();
        %% state-machine decides on which parameter set comes next
        Q.timing.framenumber = frameNum; % it increments no matter what

        [Q.stims.currStimNum,stimChanged,Q.stims.params] = StateMachine(Q.stims.params,Q.stims.currStimNum,Q.timing.framenumber - Q.timing.framelastchange, Q.timing.framenumber);
        if stimChanged
            Q.timing.framelastchange = frameNum;
            Q.stims.currParam = Q.stims.params(Q.stims.currStimNum);
        end


        %% asynchronous read from serial port
        if Q.readMouse
            % Once the arduino is told to start sending data by the command
            % IOPort('Write',Q.handles.arduino,'a'); it will start sending mouse
            % reads every 2.6 ms

            % readMouse takes in the serial port to arduino handle and returns the
            % dX and dY of the mouse last time it was polled
            [Q.flyloc.mdX,Q.flyloc.mdY,Q.flyloc.mqv,Q.flyloc.nr,t] = ReadMouse(Q.handles.arduino);
        else
            t = GetSecs();
        end

        if stimChanged
            if isfield(Q.stims.params,'epochName')
                currEpoch = Q.stims.currParam.epochName;
            else
                currEpoch = Q.stims.currStimNum;
            end
            clearPrevious = ~firstDisp;
            firstDisp = 0;
            PrintStatus(frameNum,Nframes,currEpoch,showDX,showDY,clearPrevious);
            if Q.showStatusGui
                updateStatusGui(Q.statusHandles,frameNum,Nframes,currEpoch,showDX,showDY);
            end
            
            showDX = 0;
            showDY = 0;
        else
            showDX = showDX + Q.flyloc.mdX;
            showDY = showDY + Q.flyloc.mdY;
        end
        
        % update fly information appropriately with this (for internal use, with delay taken into account)
        Q.flyTimeline.addTimepoint(Q.flyloc.mdX, Q.flyloc.mdY, Q.flyloc.mqv, Q.flyloc.nr, t);
        numReads(frameNum) = Q.flyloc.nr;

        %% generate stimuli
        
        % Reset flash to zero (after the previous one's been written, but
        % before  the below stim function call's written a new one
        Q.stims.stimData.flash = false;

        % Generate stimulus and draw for pano display
        if isfield(Q.stims.currParam,'stimtype')
            Q.windowIDs.active = Q.windowIDs.pano;
            % Run the stimulus who's number is specified in currParam.stimType,
            % store the texture
            [Q.texStr,Q.stims.stimData] = Q.stims.stimlookup{Q.stims.numList == Q.stims.currParam.stimtype}(Q);
            
            % We want to allow stimfunctions to add alignment flashes if
            % necessary, so we only update the flash state if the
            % stimfunction hasn't written out a flash
            if ~Q.stims.stimData.flash
                Q.stims.stimData.flash = GetPhotoDiodeFlashState(frameNum - Q.timing.framelastchange,Q.stims.currStimNum);
            end
            Q.stims.stimData.photoDiodeColor = 255*Q.stims.stimData.flash;
            % rote function to set up views, etc., and to display the texture on a cylinder
            if Q.useDLPs
                DrawTexture(Q);
            else
                DrawTextureThirdPerson(Q);
            end
            
        end

        % Generate stimulus and draw for flat display
        if isfield(Q.stims.currParam,'flatstimtype')
            Q.windowIDs.active = Q.windowIDs.flat;
            [Q.flatTexStr,Q.stims.flatStimData] = Q.stims.stimlookup{Q.stims.numList == Q.stims.currParam.flatstimtype}(Q);
            
            radius = 1/8;
            maskBitMap = DrawMask(radius);
            maskTex = Screen('MakeTexture', Q.windowIDs.flat, maskBitMap, [], 1);

            Screen('DrawTexture', Q.windowIDs.flat, Q.flatTexStr.tex,[],Q.flatRect);
            Screen('DrawTexture', Q.windowIDs.flat, maskTex,[],Q.flatRect);
            Screen('Close',Q.flatTexStr.tex);
            Screen('Close',maskTex);
        end
        

        %% write out data and so forth, along with some stim info -- call back?
        % frame, time, stim parameter, stim info (20 integers allowed for info),
        % frame, m1x,m1y,m2x,m2y, out to 5, just using text read in front
        % serial port
        
        WriteStimData(Q);
        WriteRespData(Q);
            
        % in general, comment this out. only have this running to adjust
        % windows.
        if align
            Q.OGL.viewLocs = AlignmentAdjust(Q);
        end

        stimEnd = GetSecs();
        stimT(frameNum)= stimEnd - stimStart;

        %% flip buffers -- v-sync, and across DLPs if possible
        Q.timing.flipt = Screen('Flip',Q.windowIDs.active,Q.timing.flipt+1/120,[],[],1);

        flipEnd = GetSecs();
        flipT(frameNum) = flipEnd - stimEnd;
        totalT(frameNum) = flipEnd - frameStart;
        
        %% Graceful program exit check
        [pressBOOL,dum,keyList]=KbCheck;
        if any(keyList(escKey))
            premature_end = true;
            break;
        end
    
    end
    
    if Q.usePhotoDiode
        SignalEndOfStimulus(Q);
    end
    
    framesMissed = sum(totalT(1:frameNum) > 0.020);
    percentMissed = 100*framesMissed/(frameNum-1);
    message = ['Missed ' num2str(framesMissed) ' frames' ...
               '(' num2str(percentMissed) '%) of ' num2str(frameNum)];
    if percentMissed > 10
        warning(message);
    else
        disp(message);
    end
end
