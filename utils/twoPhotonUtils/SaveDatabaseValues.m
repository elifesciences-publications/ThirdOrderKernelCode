function flyId = SaveDatabaseValues(connectionToTwoPhoton, paramPaths, databaseInfo)



[~, paramFilename, ~] = fileparts(paramPaths);
 
SendTCPIPMessage(connectionToTwoPhoton, 'stimulusParameterFilename');
SendTCPIPMessage(connectionToTwoPhoton, paramFilename);
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.genotype);
flyId = SendTCPIPMessage(connectionToTwoPhoton, num2str(databaseInfo.flyId));
flyId = char(flyId');
% this is matlabs weird way of converting from string to uint64. do not use
% str2double it won't work.
flyId = str2num(['uint64(' flyId ')']);
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.cellType);
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.fluorescentProtein);
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.expressionSystem);
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.surgeon);
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.condition);
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.eye);
if isempty(databaseInfo.comments)
    databaseInfo.comments = 'no comment';
end
SendTCPIPMessage(connectionToTwoPhoton, databaseInfo.comments);
% I don't want to check if the number would transfer appropriately on its
% own, so we're num2str-ing this
SendTCPIPMessage(connectionToTwoPhoton, num2str(databaseInfo.perfusion));
SendTCPIPMessage(connectionToTwoPhoton, num2str(databaseInfo.cylinderRotation));
SendTCPIPMessage(connectionToTwoPhoton, num2str(databaseInfo.flyHeight));
