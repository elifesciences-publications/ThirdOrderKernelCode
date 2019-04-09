function connectionToProjector = OpenTCPIPConnectionToProjector

% We're going to use the IP to check whether this is the client computer
% (which is the data acquisition computer of the two photon) or the server
% computer (which the one controlling the projector).
[sysError, ipConfiguration] = system('ipconfig');
if ~sysError
    ipCell = regexp(ipConfiguration, 'its.yale.internal.*IPv4 Address[^\n\r\f]*: (\d+\.\d+\.\d+\.\d+)[\r\f\n]', 'tokens');
    try 
        ip = ipCell{1}{1};
    catch err
        if strcmp(err.identifier, 'MATLAB:nonExistentCellElement')
            error(sprintf(['Looks like you might not be connected to the internet.\n' ...
                'The program couldn''t correctly parse the ipconfig command\n'...
                'to find this computer''s IP address. If the internet is, in fact,\n'
                'not working, try unplugging the ethernet cord and plugging it\n'...
                'back in. If that doesn''t work... you''re on your own. Good luck.']));
        else
            rethrow(err)
        end
    end
else
    error('The system call to ipconfig failed');
end

%twoPhotonIPAddress = '172.29.49.193';
twoPhotonIPAddress = '172.29.49.74';
projectorIPAddress = '172.29.53.143';

if ~strcmp(ip, twoPhotonIPAddress)
     error(['Looks like your computer''s IP address has changed!\n'...
        'You''re gonna have to go into OpenTCPIPConnectionToProjector.m\n'...
        'and OpenTCPIPConnectionToTwoPhoton.m and OpenTCPIPRaspberryPi.m on\n'...
        'both the two photon computer and the projector computer and rewrite\n'...
        'the hard written IPs for the projector computer with the following one:\n\n%s\n\n'...
        'You''ll be changing the variable projectorIPAddress in both files\n'...
        'on both machines. Oh, and tell somebody who knows the codebase that this happened.'], ip);
end

connectionToProjector = tcpip(projectorIPAddress, 30000, 'NetworkRole', 'client');
disp('Waiting for connection from projector computer--run RunMultipleStimuli on that one to make it so!')

notConnected = true;
timesAttempted = 1;
maxAttempts = 10;
while notConnected
    try fopen(connectionToProjector);
        notConnected = false;
    catch err
        timesAttempted = timesAttempted+1;
        if strcmp(err.identifier, 'instrument:fopen:opfailed')
            if timesAttempted < maxAttempts
                fprintf('Connection unsuccessful. Make sure you''ve run RunMultipleStimuli on the projector computer. Trying again--%d of %d times\n', timesAttempted, maxAttempts)
            else
                fprintf('Connection unsuccessful. Problems endemic. But perhaps !')
                warning(err.message)
                connectionToProjector = [];
                break
            end
            pause(1)
        else
            rethrow(err);
        end
    end
end
disp('Successfully connected to the projector computer!')