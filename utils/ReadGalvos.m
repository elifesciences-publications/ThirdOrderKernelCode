%
% Basic U3 example does a PWM output and a counter input features using
% MATLAB, .NET and the UD driver.
%
% support@labjack.com
%

% clc %Clear the MATLAB command window
clear %Clear MATLAB variables

ljasm = NET.addAssembly('LJUDDotNet'); %Make the UD .NET assembly visible in MATLAB
ljudObj = LabJack.LabJackUD.LJUD;

try
    disp(['UD Driver Version = ' num2str(ljudObj.GetDriverVersion())])
    
    %Used for casting a value to a CHANNEL enum
    chanType = LabJack.LabJackUD.CHANNEL.LOCALID.GetType;
    
    %Open the first found LabJack U3.
    [ljerror, ljhandle] = ljudObj.OpenLabJack(LabJack.LabJackUD.DEVICE.U3, LabJack.LabJackUD.CONNECTION.USB, '0', true, 0);
    
    %Start by using the pin_configuration_reset IOType so that all
    %pin assignments are in the factory default condition.
    chanObj = System.Enum.ToObject(chanType, 0); %channel = 0
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PIN_CONFIGURATION_RESET, chanObj, 0, 0);
    
    %First requests to configure the timer and counter.  These will be
    %done with and add/go/get block.
    
    %Set the timer/counter pin offset to 4, which will put the first
    %timer/counter on FIO4.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_COUNTER_PIN_OFFSET, 4, 0, 0);
    
    %Use the 48 MHz timer clock base with divider (LJ_tc48MHZ_DIV = 26).  Since we are using clock with divisor
    %support, Counter0 is not available.
    %You've gotta magic number the timer base for some reason likely
    %relating to the stupidity of those who wrote this codebase, but for
    %the sake of people reading the code and for me writing it later on,
    %here are the codes (we have this hardware version):
    % const long LJ_tc4MHZ = 20;     // U3: Hardware Version 1.21 or higher
    % const long LJ_tc12MHZ = 21;     // U3: Hardware Version 1.21 or higher
    % const long LJ_tc48MHZ = 22;     // U3: Hardware Version 1.21 or higher
    % const long LJ_tc1MHZ_DIV = 23;// U3: Hardware Version 1.21 or higher
    % const long LJ_tc4MHZ_DIV = 24;  // U3: Hardware Version 1.21 or higher
    % const long LJ_tc12MHZ_DIV = 25;  // U3: Hardware Version 1.21 or higher
	% const long LJ_tc48MHZ_DIV = 26; // U3: Hardware Version 1.21 or higher
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_BASE, 26, 0, 0);
    %ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_BASE, 16, 0, 0);  %Use this line instead for hardware rev 1.20 (LJ_tc24MHZ_DIV = 16).
    
    %Set the divisor to 48 so the actual timer clock is 1 MHz.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_DIVISOR, 48, 0, 0);
    %ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.TIMER_CLOCK_DIVISOR, 24, 0, 0);  %Use this line instead for hardware rev 1.20.
    
    %Enable 2 timer.  They will use FIO4 & FIO5.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_CONFIG, LabJack.LabJackUD.CHANNEL.NUMBER_TIMERS_ENABLED, 2, 0, 0);
    
    %Configure Timer0 as a period calculator for rising edges (mode 2)
    % Also I'm guessing that first zero indicates that timer0 is being
    % configured but yay magic numbers!
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_TIMER_MODE, 0, 2, 0, 0);
    
    %Configure Timer1 as 8-bit PWM (LJ_tmPWM8 = 1).  Frequency will be 1M/256 = 3906 Hz.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_TIMER_MODE, 1, 0, 0, 0);
    
    %Set the PWM duty cycle to 50%.
    ljudObj.AddRequest(ljhandle, LabJack.LabJackUD.IO.PUT_TIMER_VALUE, 1, 32768, 0, 0);
    
    %Execute the requests.
    ljudObj.GoOne(ljhandle);
    
    ioDummy = LabJack.LabJackUD.IO;
    chanDummy = LabJack.LabJackUD.CHANNEL;
    
    %Get all the results just to check for errors.
    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, ioDummy, chanDummy, 0, 0, 0);
    
    finished = false;
    while finished == false
        try
            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetNextResult(ljhandle, ioDummy, chanDummy, 0, 0, 0);
        catch e
            if(isa(e, 'NET.NetException'))
                eNet = e.ExceptionObject;
                if(isa(eNet, 'LabJack.LabJackUD.LabJackUDException'))
                    %If we get an error, report it.  If the error is NO_MORE_DATA_AVAILABLE we are done
                    if(eNet.LJUDError == LabJack.LabJackUD.LJUDERROR.NO_MORE_DATA_AVAILABLE)
                        finished = true;
                    end
                end
            end
            %Report non NO_MORE_DATA_AVAILABLE error.
            if(finished == false)
                throw(e)
            end
        end
    end
    
    %Wait 1 second.
    pause(1);
    
    %Request a read from the counter.
    chanObj = System.Enum.ToObject(chanType, 0); %channel = 1
    [ljerror, dblValue] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_TIMER, chanObj, 0, 0);
    
    %This should read roughly 4k counts if FIO4 is shorted to FIO5.
    cntr1 = dblValue;
    disp(['Timer 1 = ' num2str(dblValue)]);
    for i = 1:10
        %Wait 1 second.
        pause(1);
        
        %Request a read from the counter.
        chanObj = System.Enum.ToObject(chanType, 0); %channel = 1
        [ljerror, dblValue] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_TIMER, chanObj, 0, 0);
        %Request a read from the counter.
        chanObj = System.Enum.ToObject(chanType, 0); %channel = 1
        [ljerror, dblValue2] = ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_TIMER, chanObj, 0, 0);
        
        %This should read about 3906 counts more than the previous read.
        cntr1 = dblValue;
        cntr2 = dblValue2;
        disp(['Timer first read = ' num2str(cntr1)]);
        disp(['Timer second read = ' num2str(cntr2)]);
        
        disp(['Difference = ' num2str(cntr2-cntr1)]);
%         cntr1=cntr2;
    end
    
    %Reset all pin assignments to factory default condition.
    chanObj = System.Enum.ToObject(chanType, 0); %channel = 0
    ljudObj.ePut(ljhandle, LabJack.LabJackUD.IO.PIN_CONFIGURATION_RESET, chanObj, 0, 0);
    
    %The PWM output sets FIO5 to output, so we do a read here to set
    %it to input.
    chanObj = System.Enum.ToObject(chanType, 5); %channel = 4
    ljudObj.eGet(ljhandle, LabJack.LabJackUD.IO.GET_DIGITAL_BIT, chanObj, 0, 0);
catch e
    showErrorMessage(e)
end

ljudObj.Close()