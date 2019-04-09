function SendAcquisitionInitiationMessage(connectionToTwoPhoton, Q)

SendTCPIPMessage(connectionToTwoPhoton, 'grab');

% Divide by 60 because totalTime gives the actual number of
% presented frames (yeah, seems misnamed, but it is what it is)
grabDuration = Q.stims.params(1).totalTime/60;
% initial grab interval--this is here because transients in the
% signal have been noticed at the start of grabs; this is the
% amount of time it will hopefully take to stabilize them
grabStabilizeTime = 5;
totalGrabDuration = grabDuration + grabStabilizeTime;

SendTCPIPMessage(connectionToTwoPhoton, num2str(totalGrabDuration));

pause(grabStabilizeTime);