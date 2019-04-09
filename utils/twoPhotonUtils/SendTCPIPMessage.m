function returnMessage = SendTCPIPMessage(tcpipConnection, message, pauseTime, secWait)

if nargin<3
    pauseTime = 0;
end

if ~exist('secWait', 'var')
    secWait = 0;
end

% Press 'Esc' to quit program (gracefully!)
escKey = [27 41];
endProgram = false;

fwrite(tcpipConnection, message);
tStart = tic;
while ~tcpipConnection.BytesAvailable
    pause(pauseTime);
    % Wait for a reply
    [~,~,keyList]=KbCheck;
    if any(keyList(escKey))
        returnMessage = ['end']';
        return;
    end
    timePast = toc(tStart);
    if secWait && timePast > secWait
        returnMessage = [];
        return;
    end
end
if ~tcpipConnection.BytesAvailable
    returnMessage = 'failed';
else
    returnMessage = fread(tcpipConnection, tcpipConnection.BytesAvailable);
end