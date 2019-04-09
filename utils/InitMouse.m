function [mousePort,t_start] = InitMouse(readLate)
    [mousePort,~] = IOPort('OpenSerialPort','Com3',['BaudRate=115200','ReceiveTimeout=1','PollLatency=.001']);
    %if 1 reads mouse output 1 frame behind, but mouse read is approx 10x
    %faster than reading in same frame -MSC
%     if readLate
%         IOPort('Write',mousePort,'a');
%     end
    t_start = GetSecs;
end

