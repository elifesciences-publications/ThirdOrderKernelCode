function flyIds = GetFlyBehaviorIdFromDatabase(pathCell)
% Grab the z stack path from the database--either by giving a stimulus grab
% one's interested in looking at the z stack of, or by giving column/value
% pairs that will be sent to a database query

sysConfig = GetSystemConfiguration;
connDb = connectToDatabase(sysConfig.databasePathLocal, true);
if isempty(connDb)
    connDb = connectToDatabase(sysConfig.databasePathServer);
end

flyIds = uint64(zeros(1,length(pathCell)));

for i = 1:length(pathCell)
    moviePathIn = pathCell{i};
    
    
    
    if any(strfind(moviePathIn, sysConfig.twoPhotonDataPathLocal))
        relativeDataPath = moviePathIn(length(sysConfig.twoPhotonDataPathLocal)+1:end-1);
        relativeDataPath(relativeDataPath == '/') = '\';
    elseif any(strfind(moviePathIn, sysConfig.twoPhotonDataPathServer))
        if any(moviePathIn(end) == '\/')
            relativeDataPath = moviePathIn(length(sysConfig.twoPhotonDataPathServer)+1:end-1);
        else
            relativeDataPath = moviePathIn(length(sysConfig.twoPhotonDataPathServer)+1:end);
        end
        relativeDataPath(relativeDataPath == '/') = '\';
    else
        error('Can''t determine the relative data path to the fly');
    end
    
    flyIdCell = fetch(connDb, sprintf('select behaviorId from fly as f join stimulusPresentation as sP on f.flyId=sP.fly where sP.relativeDataPath like "%%%s%%"', relativeDataPath));
    flyIds(i) = sscanf(flyIdCell{1}, '%lu');
    
end