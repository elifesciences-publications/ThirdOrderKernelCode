function [dx,dy,qv,nr,t] = ReadMouse(mousePort)
    %IOPort('Write',mousePort,'a');
    nr = 0;
    numBytes = 10;
    qv = zeros(1,5);
    readBytes = zeros(1,numBytes);
    sumBytes = zeros(1,numBytes);
    while IOPort('BytesAvailable', mousePort)>=numBytes;
        readBytes = IOPort('Read',mousePort,1,numBytes);
        
        readBytes(readBytes>127) = readBytes(readBytes>127) - 256;
        %qv = readBytes(11:15);
        sumBytes = sumBytes + readBytes;
        nr = nr + 1;
    end
    
    if isempty(readBytes)
        sumBytes = zeros(1,numBytes)-1;
    end
    
    dx = sumBytes(1:5);
    %flip the sign of dx
    dx = -1*dx;
    dy = sumBytes(6:10);
    t = GetSecs();
end