function flyEye = GetEyeFromDatabase(pathString)

sysConfig = GetSystemConfiguration;
warning('off', 'database:connect:emptyConnection');
connDb = connectToDatabase(sysConfig.databasePathLocal, true);
warning('on', 'database:connect:emptyConnection');
if isempty(connDb)
    connDb = connectToDatabase(sysConfig.databasePathServer);
end

pathString(pathString=='\') = '/';
if strfind(pathString, sysConfig.twoPhotonDataPathLocal)
    relativeDataPath = pathString(length(sysConfig.twoPhotonDataPathLocal)+1:end);
elseif strfind(pathString, sysConfig.twoPhotonDataPathServer)
    relativeDataPath = pathString(length(sysConfig.twoPhotonDataPathServer)+1:end);
else
    relativeDataPath = pathString;
end
relativeDataPath(relativeDataPath=='/') = '\';

try
    flyEye = fetch(connDb, sprintf('select eye from fly as f join stimulusPresentation as sP on f.flyId=sP.fly where sP.relativeDataPath like "%%%s%%"', relativeDataPath));
catch err
    if strcmp(err.identifier, 'database:fetch:execError')
        pause(0.1)
        flyEye = fetch(connDb, sprintf('select eye from fly as f join stimulusPresentation as sP on f.flyId=sP.fly where sP.relativeDataPath like "%%%s%%"', relativeDataPath));
    end
end
flyEye = flyEye{1};