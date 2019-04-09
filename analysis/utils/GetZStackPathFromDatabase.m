function zStackPath = GetZStackPathFromDatabase(varargin)
% Grab the z stack path from the database--either by giving a stimulus grab
% one's interested in looking at the z stack of, or by giving column/value
% pairs that will be sent to a database query

sysConfig = GetSystemConfiguration;
connDb = connectToDatabase(sysConfig.databasePathLocal, true);
if isempty(connDb)
    connDb = connectToDatabase(sysConfig.databasePathServer);
end

if length(varargin)==1
    moviePathIn = varargin{1};
    
    
    
    if any(strfind(moviePathIn, sysConfig.twoPhotonDataPathLocal))
        relativeDataPath = moviePathIn(length(sysConfig.twoPhotonDataPathLocal)+1:end-1);
        relativeDataPath(relativeDataPath == '/') = '\';
    elseif any(strfind(moviePathIn, sysConfig.twoPhotonDataPathServer))
        relativeDataPath = moviePathIn(length(sysConfig.twoPhotonDataPathServer)+1:end-1);
        relativeDataPath(relativeDataPath == '/') = '\';
    else
        error('Can''t determine the relative data path to the fly');
    end
    
    zStackPath = fetch(connDb, sprintf('select relativePath from fly as f join stimulusPresentation as sP on f.flyId=sP.fly where sP.relativeDataPath like "%%%s%%"', relativeDataPath));
    zStackPath = zStackPath{1};
else
    % The varargin should be structured as 'name', 'value' pairs where each
    % name is a database column title and each value is that column's value
    colCheckStr = '';
    if ~isempty(varargin)
        colCheckStrCell = cellfun(@(col, compType, val) [col ' ' compType ' "' val '"'] ,varargin(1:3:end), varargin(2:3:end), varargin(3:3:end), 'UniformOutput', false);
        colCheckStr = [' and ' strjoin(colCheckStrCell, ' and ')];
    end
    
    zStackPath = fetch(connDb, sprintf('select relativePath from fly where relativePath NOT NULL %s ', colCheckStr));
    
end