function laserConnected = PrepareLaser()
    % Connect 
    global serialConnectionToMaiTaiLaser
    serialConnectionToMaiTaiLaser = ControlMaiTai(serialConnectionToMaiTaiLaser, 'OPENPORT');% Note OPENPORT is not in the MaiTai manual--we're creating it for our purposes
    if isempty(serialConnectionToMaiTaiLaser) || strcmp(serialConnectionToMaiTaiLaser, 'fail')
        % We can't control the laser--the LabView Maitai program is likely
        % using it
        warning('Can''t speak with laser--probably a result of you controlling it with the main MaiTai program');
        laserConnected = false;
        return;
    else
        laserConnected = true;
    end
    
    % Check that the laser is warmed up 
    out = ControlMaiTai(serialConnectionToMaiTaiLaser, 'ON');
    % out will be 100.00% when the laser is ON and good to go
    while ~strcmp(out, '100.00%')
        pause(1)
        out = ControlMaiTai('ON');
    end
    
    
%     diode1Curr = ControlMaiTai(readDiode1Curr, [], false);
%     diode2Curr = ControlMaiTai(readDiode2Curr, [], false);
%     laserPowVal = ControlMaiTai(readLaserPowVal, [], false);
%     oldLaserPowVal = -1;
    
    % Setup figure with labels
    lPFig = figure;
    set(lPFig, 'menubar', 'None', 'Name', 'Laser Diagnostics', 'numbertitle', 'off', 'resize', 'off', 'Position', [680   558   280   420]);
    bkgdColor = get(lPFig, 'Color');
    figPos = get(lPFig, 'Position');
    figHeight = figPos(4);
    textFontSize = 13;
    uicontrol('Style', 'text', 'Parent', lPFig, 'Position',[10 figHeight/2-20 130 22], 'String', 'Diode 1 Current', 'FontSize', textFontSize, 'BackgroundColor', bkgdColor);
    d2CurrLab = uicontrol('Style', 'text', 'Parent', lPFig, 'Position',[10 figHeight/2+20+25 130 22], 'String', 'Diode 2 Current', 'FontSize', textFontSize, 'BackgroundColor', bkgdColor);
    secondsStart = tic;
    stabilizeButton = uicontrol('Style', 'pushbutton', 'Parent', lPFig, 'Position',[10 figHeight/5 130 50], 'String', '<html>Click if laser<br>doesn''t settle</html>', 'FontSize', textFontSize, 'BackgroundColor', [1 0 0], 'Callback', {@SetCurrMode, secondsStart});
    shutterButton = uicontrol('Style', 'pushbutton', 'Parent', lPFig, 'Position',[10 4*figHeight/5 130 50], 'String', '<html>Open shutter</html>', 'FontSize', textFontSize, 'BackgroundColor', [0.5 0.5 0.5], 'Callback', {@ToggleLaserShutter});
    wavelengthValEdit = uicontrol('Style', 'edit', 'Parent', lPFig, 'Position',get(d2CurrLab, 'Position')+[0 30 -65 0], 'FontSize', textFontSize, 'KeyPressFcn', {@ChangeWavelength});
    wavelengthValText = uicontrol('Style', 'text', 'Parent', lPFig, 'Position',get(wavelengthValEdit, 'Position')+[65 0 0 0], 'String', 'Wavelength', 'FontSize', textFontSize, 'BackgroundColor', bkgdColor);
    wavelengthDesc = uicontrol('Style', 'text', 'Parent', lPFig, 'Position',get(wavelengthValEdit, 'Position')+[0 20 65 0], 'String', 'Wavelength', 'FontSize', textFontSize, 'BackgroundColor', bkgdColor);
    pulsingCheck = uipanel('Parent', lPFig, 'Title', 'Pulsing?', 'TitlePosition', 'righttop', 'BackgroundColor','white','Units', 'pixel', 'Position',get(stabilizeButton, 'Position') + [52 -40 -104 -18], 'BorderType', 'line', 'HighlightColor', [1 0 0]);
    %     d1ValDial = [];
%     d2ValDial = [];
    parAx = axes('Parent', lPFig);
    parAxPos = get(parAx, 'Position');
    set(parAx, 'XColor', bkgdColor, 'box', 'off', 'Position', parAxPos + [0.3 0 0 0], 'Parent', lPFig);
    set(parAx, 'Units', 'pixels');
    parAxPos = get(parAx, 'Position');
    set(parAx, 'Units', 'normalized');
    
%     keepGoing = true;
%     timesCorrect = 0;
    d1ValDial = uicontrol('Style', 'text', 'Parent', lPFig, 'Position',[40 figHeight/2-20-25 100 22], 'String', 'Reading...', 'FontSize', textFontSize);
    d2ValDial = uicontrol('Style', 'text', 'Parent', lPFig, 'Position',[40 figHeight/2+20 100 22], 'String', 'Reading...', 'FontSize', textFontSize);
    laserPowDial = uicontrol('Style', 'text', 'Parent', lPFig, 'Position', [parAxPos(1:2) + [20 -40], 100, 22], 'String', 'Reading...', 'FontSize', textFontSize);
    
    laserDiagnosticTimer = timer('ExecutionMode', 'fixedRate', 'TimerFcn', {@UpdateLaserGUIErrorCatch, parAx, d1ValDial, d2ValDial, laserPowDial, wavelengthValText, pulsingCheck}, 'Period', 5, 'ErrorFcn', {@TimerError});
    start(laserDiagnosticTimer);
end

function UpdateLaserGUIErrorCatch(tmr, evt, parAx, d1ValDial, d2ValDial, laserPowDial, wavelengthValText, pulsingCheck)
        try
            UpdateLaserGUI(tmr, evt, parAx, d1ValDial, d2ValDial, laserPowDial, wavelengthValText, pulsingCheck) 
        catch me
            keyboard
            warning(me.message)
        end
    end

function UpdateLaserGUI(~, ~, parAx, d1ValDial, d2ValDial, laserPowDial, wavelengthValText, pulsingCheck)
    persistent laserPowVal timesCorrect fail
    global serialConnectionToMaiTaiLaser
    textFontSize = 13;
    
    oldLaserPowerVal = laserPowVal;
    
    readDiode1Curr = 'READ:PLASER:DIODE1:CURRENT?';
    readDiode2Curr = 'READ:PLASER:DIODE2:CURRENT?';
    readLaserPowVal = 'READ:POWER?';
    readWavelength = 'READ:WAVELENGTH?';
    readPulsingStatus = 'READ:PULSING?'; % Note that we came up with this command... it's not default MaiTai but makes use of it in ControlMaiTai
    diode1Curr = ControlMaiTai(serialConnectionToMaiTaiLaser, readDiode1Curr, [], false);
    diode2Curr = ControlMaiTai(serialConnectionToMaiTaiLaser, readDiode2Curr, [], false);
    laserPowVal = ControlMaiTai(serialConnectionToMaiTaiLaser, readLaserPowVal, [], false);
    wavelengthVal = ControlMaiTai(serialConnectionToMaiTaiLaser, readWavelength, [], false);
    pulsingStatus = ControlMaiTai(serialConnectionToMaiTaiLaser, readPulsingStatus, [], false);

    if isempty(timesCorrect)
        timesCorrect = 0;
    end
    
    try
        if ~strcmp(laserPowVal, 'fail') 
            if ~isempty(laserPowVal) && ~isempty(oldLaserPowerVal) && laserPowVal>0.1 && round(100*laserPowVal)/100 == round(100*oldLaserPowerVal)/100
                timesCorrect = timesCorrect+1;
            else
                timesCorrect = 0;
            end
            fail = 0;
        else
            laserPowVal = oldLaserPowerVal;
            fail = fail + 1;
            if fail > 10
                error('Failed to connect too many times')
            end
        end
    catch err
        keyboard
    end

    if timesCorrect > 10
        keepGoing = false;
    end

    cla(parAx)

    % Present laser bar as a bar
%         axes(parAx)
    bar(parAx, laserPowVal);
    a = title(parAx, 'Laser Power');
    set(a, 'FontSize', textFontSize, 'FontWeight', 'normal');
    axis(parAx, 'equal')
    axis(parAx, [.75 1.25 0 4])

    % Present photodiode values
    set(d1ValDial, 'String',  [num2str(diode1Curr) ' A']);
    set(d2ValDial, 'String',  [num2str(diode2Curr) ' A']);
        
    % Present laser power as a value
    set(laserPowDial, 'String', num2str(laserPowVal));
    
    % Present wavelength as a value
    set(laserPowDial, 'String', num2str(laserPowVal));
    set(wavelengthValText, 'String', num2str(wavelengthVal));
    
    if pulsingStatus
        set(pulsingCheck, 'BackgroundColor', [0 1 0], 'HighlightColor', [0 .5 0]);
    end



    
    % Now allow the MaiTai to be idle in the ON state for five minutes at
    % a time without worrying about a command ping
%     warning('Laser will remain on for AT LEAST 15 seconds EVEN IF THE COMPUTER SHUTS OFF')
    ControlMaiTai(serialConnectionToMaiTaiLaser, 'TIMER:WATCHDOG', 600, false);
    
end

function TimerError(hObject, callbackData)
%     keyboard
disp('Timer errored')
%     PrepareLaser
end

% Quickly sets the mode to PCURRENT which settles the laser in extreme
% cases
function SetCurrMode(~, ~, secondsStart)
    global serialConnectionToMaiTaiLaser
    numSecondsTried = toc(secondsStart);
    secondsToWait = 300;
    if numSecondsTried < secondsToWait
        warning('The laser''s been on for only %0.2f minutes. Try again when it''s been on for %0.2f minutes.', numSecondsTried/60, secondsToWait/60)
        return
    end
    
    ControlMaiTai(serialConnectionToMaiTaiLaser, 'MODE', 'PCUR');
    pause(5)
    % Note that this should be POW and *NOT* PPOW, because PPOW sets the
    % laser to Green laser power mode, where as POW sets it to IR power
    % mode--this is not documented (as far as I could find)
    ControlMaiTai(serialConnectionToMaiTaiLaser, 'MODE', 'POW');
end

function ToggleLaserShutter(hObject, callbackData)
    global serialConnectionToMaiTaiLaser
    shutterState = ControlMaiTai(serialConnectionToMaiTaiLaser, 'SHUTTER?');
    if shutterState
        ControlMaiTai(serialConnectionToMaiTaiLaser, 'SHUTTER', '0')
        set(hObject, 'String', '<html>Open shutter</html>', 'BackgroundColor', [0.5 0.5 0.5])
    else
        ControlMaiTai(serialConnectionToMaiTaiLaser, 'SHUTTER', '1')
        set(hObject, 'String', '<html>Close shutter</html>', 'BackgroundColor', [1 1 0])
    end
end

function ChangeWavelength(hObject, callbackData)
    global serialConnectionToMaiTaiLaser
    if strcmp(callbackData.Key, 'return')
        out = 'fail';
        pause(0.1); %Dunno why but this is apparently needed ... >.>
        newWavelength = get(hObject, 'String');
        timesAttempted = 0;
        while strcmp(out, 'fail')
            out = ControlMaiTai(serialConnectionToMaiTaiLaser, 'WAVELENGTH', newWavelength);
            timesAttempted = timesAttempted+1;
            if timesAttempted>10
                break
            end
            pause(0.1)
        end
        if timesAttempted>10
            set(hObject, 'String', 'SetFail');
        else
            set(hObject, 'String', 'Success');
        end
    end
    

end