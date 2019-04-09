function out = ControlMaiTai(s, command,parameter,displayOut)
%CONTROL_MAITAI controls mai tai laser
%
%  OUT = CONTROL_MAITAI( COMMAND )
%  OUT = CONTROL_MAITAI( COMMAND, PARAMETER )
%
%
% 2012, Alexander Heimel
%

if nargin<4
    displayOut = true;
end

% a = tic;
if displayOut
    disp(['Command = ' command ]);
end

port = 'COM1';  % dependent on setup

out = [];

if isempty(s) || (strcmp(command, 'OPENPORT') && ~isvalid(s))
    s = serial(port);
    s.BaudRate = 38400;
    s.DataBits = 8;
    s.StopBits = 1;
    s.Parity = 'none';
    s.FlowControl = 'software';
    s.Terminator = 'LF';
    
    
                
    try
        fopen(s);
    catch me
        switch    me.identifier
            case 'MATLAB:serial:fopen:opfailed'
                if displayOut
                    disp(['Cannot open communications to port ' port]);
                end
                delete(s)
                return
            otherwise
                delete(s)
                rethrow(me);
        end
    end
%     toc(a)
    out = s;
    return
end



% toc(a)
try
switch command
    case 'READ:PCTWARMEDUP?' 
        fprintf(s,'READ:PCTWARMEDUP?');
        pause(0.01)
        out = strtrim(fscanf(s));
        if isempty(out)
            out = 'No return';
        end
        if out(end)~='%'
            if displayOut
                disp(['CONTROL_MAITAI: Unexpected response from laser to warmup status enquiry: ' out]);
            end
            out = '?';
            fclose(s);
            delete(s);
            return
        end
    case 'ON'
        fprintf(s,'READ:PCTWARMEDUP?');
        pause(0.01)
        out = strtrim(fscanf(s));
        if strcmp(out,'0.00%')
            if displayOut
                disp('CONTROL_MAITAI: Stabilizing diode temperature. Takes approx. 2 minutes.');
            end
            fprintf(s,'ON');
            fclose(s);
            delete(s);
            return
        end
        
        if ~strcmp(out,'100.00%')
            if displayOut
                disp(['CONTROL_MAITAI: Laser not yet warmed up. Only at ' out ]);
            end
            out = -1;
            fclose(s);
            delete(s);
            return
        end
        fprintf(s,'ON');
    case 'OFF'
        fprintf(s,'OFF');
    case 'SHUTTER?'
        fprintf(s,'SHUTTER?');
        out = str2double(fscanf(s));
    case 'SHUTTER'
        if isnumeric(parameter)
            parameter = num2str(parameter);
        end
        parameter = strtrim(parameter);
        if strcmp(parameter,'0')==0 && strcmp(parameter,'1')==0
            disp('CONTROL_MAITAI: Invalid shutter command');
            fclose(s);
            delete(s);
            return;
        end
        fprintf(s,['SHUTTER ' parameter]);
    case 'WAVELENGTH'
        if ischar(parameter)
            parameterIn = parameter;
            parameter = str2double(parameter);
        end
        if isnan(parameter) || parameter>1040 || parameter <690
            disp('CONTROL_MAITAI: Invalid wavelength: %d', parameter);
            out = 'fail';
            fclose(s);
            delete(s);
            return;
        end
        parameter = round(parameter);
        if displayOut
            disp(['CONTROL_MAITAI: Command = WAVELENGTH ' num2str(parameter)]);
        end
        fprintf(s,['WAVELENGTH ' num2str(parameter)]);
    case 'WAVELENGTH?' % last requested wavelength 
        fprintf(s,'WAVELENGTH?');
        pause(0.01)
        out = fscanf(s);
    case 'READ:WAVELENGTH?' 
        fprintf(s,'READ:WAVELENGTH?');
        pause(0.01);
        out = strtrim(fscanf(s));
        out = out(1:end-2);
        out = str2double(out);
    case 'READ:POWER?'
        fprintf(s,'READ:POWER?');
        pause(0.01)
        out = strtrim(fscanf(s));
        out = out(1:end-1); % to remove 'W'
        out = str2double(out);
    case 'READ:PLASER:POWER?'
        fprintf(s,'READ:PLASER:POWER?');
        pause(0.01)
        out = strtrim(fscanf(s));
        out = out(1:end-1); % to remove 'W'
        out = str2double(out);
    case '*STB?'
        fprintf(s,'*STB?');
        pause(0.01)
        out = str2double(fscanf(s));
    case 'READ:PULSING?' % This is our own call, uses the *STB? command and checks whether the second bit is set
        fprintf(s,'*STB?');
        pause(0.01)
        out = str2double(fscanf(s));
        bits = dec2bin(out);
        if strcmp(bits(end-1), '1')
            out = true;
        else
            out = false;
        end
    case 'MODE?'
        fprintf(s, command);
        pause(0.01)
        out = fscanf(s);
    case 'MODE'
        if isnumeric(parameter) || ~any(strcmp({'PPOW', 'PPOWER', 'PCUR', 'PCURRENT', 'POW'}, parameter))
            disp('CONTROL_MAITAI: Invalid mode command');
            fclose(s);
            delete(s);
            return;
        end
        
        fprintf(s,['MODE ' parameter]);
        
    case {'READ:PLASER:DIODE1:CURRENT?', 'READ:PLASER:DIODE2:CURRENT?'}
        fprintf(s,command);
        pause(0.01)
        out = strtrim(fscanf(s));
        out = out(1:end-2); % to remove 'A#'
        out = str2double(out);
    case 'TIMER:WATCHDOG'
        if isnumeric(parameter)
            parameter = num2str(parameter);
        end
        parameter = strtrim(parameter);
        if strcmp(parameter, '0')
            warning('Watchdog timer not reset--you will have to manually set the timer to 0 if so is your wish')
        end
        fprintf(s,['TIMER:WATCHDOG' parameter]);
    otherwise
        if displayOut
            disp(['CONTROL_MAITAI: Unknown/unimplemented command ' command]);
        end
end

% toc(a)
if displayOut
    if isnumeric(out)
        disp(['CONTROL_MAITAI: Out = ' num2str(out)]);
    else
        disp(['CONTROL_MAITAI: Out = ' out]);
    end
end


catch me
    fclose(s);
    delete(s);
    rethrow(me);
end
% 
% fclose(s);
% delete(s);

% toc(a)