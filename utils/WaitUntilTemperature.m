function WaitUntilTemperature(boxTemperature,port)

try
    [tempPort,~] = IOPort('OpenSerialPort',port,['BaudRate=38400','ReceiveTimeout=1','PollLatency=.001']);
catch
    warning('COULD NOT SET TEMPERATURE: COULD NOT OPEN PORT! \nPlease check connection and restart program\n');
    return;
end
navailable = IOPort('BytesAvailable', tempPort);
IOPort('Read',tempPort,1,navailable);
valueSet = 0;
for i = 1:3
    temp = boxTemperature*10;
    command = [uint8(1) uint8(5) uint8([0 0]) uint8([floor(temp/256) temp-floor(temp/256)*256])];
    IOPort('Write',tempPort, command,1);
    readBytes = IOPort('Read',tempPort,1,6);
    if isequal(readBytes,command)
        valueSet = 1;
        break
    end
end
pause(0.1);
navailable = IOPort('BytesAvailable', tempPort);
IOPort('Read',tempPort,1,navailable);
if valueSet == 0
    warning('COULD NOT SET TEMPERATURE! \nPlease check connection and restart program\n');
    IOPort('Close',tempPort);
    return;
end
currentTemp = 0;
failedReads = 0;
timesCorrect = 0;
while timesCorrect < 1;
    command = [uint8(1) uint8(4) uint8([16 0]) uint8([0 1])];
    IOPort('Write',tempPort, command,1);
    readBytes = IOPort('Read',tempPort,1,5);
    if(length(readBytes) == 5)
        currentTemp = (readBytes(4)*256+readBytes(5))/10
    else
        failedReads = failedReads + 1;
    end
    if failedReads > 5
        warning('COULD NOT READ TEMPERATURE! \nPlease restart program\n');
        IOPort('Close',tempPort);
        return;
    end
    if abs(currentTemp - boxTemperature) > 0.2
        timesCorrect = 0;
    else
        timesCorrect = timesCorrect + 1;
    end
    [secs, kbVector, dsecs] = KbWait([],0,GetSecs()+10);
    if kbVector(27)% esc
        fprintf('Warm-up canceled. Continuing');
        IOPort('Close',tempPort);
        return;
    end
end
fprintf('Requested temperature reached. Continuing');
IOPort('Close',tempPort);

end