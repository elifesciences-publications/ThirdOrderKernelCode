function TransferBehaviorData(connectionToTwoPhoton, Q)

SendTCPIPMessage(connectionToTwoPhoton, 'transferData');

% Send out the information about the location of all the behavior
% data so it can be SFTPed back!
pauseTime = 0.01;
SendTCPIPMessage(connectionToTwoPhoton, Q.paths.data, pauseTime);