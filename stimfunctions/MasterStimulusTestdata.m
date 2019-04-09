% show a stimulus but produce a predicted output. Good for testing analysis
% files, etc.

%% set up screens, paths, and handles for writing
%% initializes serial ports, labjack, reads mice once, etc.
%% collect various bits of user input
%% Q contains all the relevant information for future stuff
Q = preliminary_setup;
showDX = 0;
showDY = 0;

Nframes = Q.stims.duration;
%Nframes = 10*60;

stimT = zeros(Nframes,1);
flipT = zeros(Nframes,1);
totalT = zeros(Nframes,1);
numReads = zeros(Nframes,1);

Q.timing.flipt = GetSecs(); % relative time of most recent flip
Q.timing.framenumber = GetSecs();
Q.timing.punishlastchange = GetSecs();

%% giant for loop for every frame -- 20 minutes at 60 Hz
for frame_num = 1:Nframes
    frameStart = GetSecs();
    % for optimally short time between a mouse read and a flip, a delay
    % should occur here. If the stimulus generation time is constant this
    % will cause 3/4 of the flip time wait to occur here rather than before
    % flipping.
    if frame_num > 11
        WaitSecs(1/2*(1/60 - max(stimT(frame_num-11:frame_num-1))));
    end
    
    stimStart = GetSecs();
    %% state-machine decides on which parameter set comes next
    Q.timing.framenumber = frame_num; % it increments no matter what

    [Q.stims.currStimNum,stimChanged,Q.stims.params] = state_machine(Q.stims.params,Q.stims.currStimNum,Q.timing.framenumber - Q.timing.framelastchange);
    if stimChanged
        Q.timing.framelastchange = frame_num;
        Q.stims.currParam = Q.stims.params(Q.stims.currStimNum);
    end
    
    %% asynchronous read from serial port

    [Q.flyloc.mdX,Q.flyloc.mdY,Q.flyloc.mqv,Q.flyloc.nr,t] = HOWTOPREDICT[dx,dy,qv,nr,t];
    t = GetSecs();

    if mod(frame_num,60) == 0
        %disp(['frame = ',num2str(frame_num),' dX = ',num2str(showDX),' dY = ',num2str(showDY),' qv = ',num2str(Q.flyloc.mqv)]);
        %fprintf('%s%6d%s%5d%5d%5d%5d%5d%s%5d%5d%5d%5d%5d%s%3d%3d%3d%3d%3d\n','frame =',frame_num,' dX =',showDX,' dY =',showDY,' qv =',Q.flyloc.mqv);
        fprintf('%s%6d%s%5d%5d%5d%5d%5d%s%5d%5d%5d%5d%5d\n','frame =',frame_num,' dX =',showDX,' dY =',showDY);
        showDX = 0;
        showDY = 0;
    else
        showDX = showDX + Q.flyloc.mdX;
        showDY = showDY + Q.flyloc.mdY;
    end

    % update fly information appropriately with this (for internal use, with delay taken into account)
    Q.flyTimeline.addTimepoint(Q.flyloc.mdX, Q.flyloc.mdY, Q.flyloc.mqv, Q.flyloc.nr, t);
    numReads(frame_num) = Q.flyloc.nr;

    %% write out data and so forth, along with some stim info -- call back?
    % frame, time, stim parameter, stim info (20 integers allowed for info),
    % frame, m1x,m1y,m2x,m2y, out to 5, just using text read in front
    % serial port
    
    write_stimdata(Q);
    write_respdata(Q);
    if Q.isClosedLoop
        writeTimelines(Q);
    end
    
    %% create texture for all 3 time points in frame, based on selected parameter file (starts with 1)
    % should use static variables, and gets a parameter file, abs and
    % relative frame numbers. once everything is debugged, pretty much only
    % this function will ever change... and that's a good thing. store
    % required data in Stims(ii).data structure, as required. need to think
    % hard about how to set things up on cylinder, especially for two eyes.
    % want to make 2 eyes easy, especially for matt's project. perhaps come
    % up with a couple routines that draw half cylinders, with appropriate
    % texture coordinates, do it that way. those can be used over and over.
    % also specify some center piece.
    Q = generateTexture(Q);
    
    % in general, comment this out. only have this running to adjust
    % windows.
    Q.OGL.viewLocs = alignment_adjust(Q);
    
    %% rote function to set up views, etc., and to display the texture on a cylinder
    drawTexture(Q);
    stimEnd = GetSecs();
    stimT(frame_num)= stimEnd - stimStart;

    %% flip buffers -- v-sync, and across DLPs if possible
    Q.timing.flipt = Screen('Flip',Q.OGL.windowID,Q.timing.flipt+1/120);

    flipEnd = GetSecs();
    flipT(frame_num) = flipEnd - stimEnd;
    totalT(frame_num) = flipEnd - frameStart;
end
%% shut it all down in psych toolbox, close all the writing files
shutdown_program(Q);

%% zip all the *.m files into the data directory, just to have them on file with the data.
backup_text_m_files(Q);

%% subsequent nice scripts for reading in all the data... use textscan to get stuff in nicely

% makeFigure;
% stim = csvread([Q.paths.data '\stimdata.csv']);
% plot(diff(stim(:,1)));
% xlabel('frame #')
% ylabel('duration of flip (ms)');

% makeFigure;
% plot(numReads);
% xlabel('frame #');
% ylabel('# mouse reads');
% 
% makeFigure;
% resp = csvread([Q.paths.data '\respdata.csv']);
% hold on;
% plot(resp(:,3)>0);
% plot(resp(:,4),'color','red');
% xlabel('frame #')
% ylabel('intensity');
% legend({'mouse output' 'mouse luminence read'});
% 
% makeFigure;
% hold on;
% plot(resp(:,3)>0);
% plot(resp(:,4)>5,'color','red');
% xlabel('frame #')
% ylabel('intensity > 5');
% legend({'mouse output' 'mouse luminence read'});
% 
% makeFigure;
% hold on;
% cross = double([resp(:,3)>0 resp(:,4)>5]);
% crossReadLum = xcorr(cross);
% plot(-1*(size(resp,1)-1):size(resp,1)-1,crossReadLum(:,3));
% xlabel('frame delay')
% ylabel('correlation between mouse output and lum read');