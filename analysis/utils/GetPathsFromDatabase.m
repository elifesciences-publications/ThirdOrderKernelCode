function relPaths = GetPathsFromDatabase(cellType,paramfile,fluorescentProtein, flyEye, surgeon, varargin)
    sysConfig = GetSystemConfiguration;

%     connDb = connectToDatabase;

    if iscell(paramfile)
        paramfile = strjoin(paramfile, '", "');
    end
    
    % The varargin should be structured as 'name', 'value' pairs where each
    % name is a database column title and each value is that column's value
    addColChecks = '';
    addColChecksIn = '';
    colCheckStr = '';
    colCheckStrIn = '';
    if any(strcmp(varargin, 'expressionSystemName'))
        varargin{strcmp(varargin, 'expressionSystemName')} = 'name';
    end
    
    % varargins allow the user to communicate with the database using
    % simple triplets of columnName, comparison, value
    if ~isempty(varargin)
        % We take care of the 'in' token differently, and expect cells as
        % input to it
        if any(strcmp(varargin, 'in'))
            vararginInCall = varargin(bsxfun(@plus, find(strcmp(varargin, 'in')), [-1; 0; 1]));
            addColChecksIn = [', ' strjoin(vararginInCall(1:3:end), ', ')];
            colCheckStrCellIn = cellfun(@(col, val) [col ' in ("' strjoin(val, '", "') '")'], vararginInCall(1:3:end), vararginInCall(3:3:end), 'UniformOutput', false);
            colCheckStrIn = [' and ' strjoin(colCheckStrCellIn, ' and ')];
            varargin(bsxfun(@plus, find(strcmp(varargin, 'in')), [-1; 0; 1])) = [];
        end
        if ~isempty(varargin)
            addColChecks = [', ' strjoin(varargin(1:3:end), ', ') addColChecksIn];
            colCheckStrCell = cellfun(@(col, compType, val) [col ' ' compType ' "' val '"'] ,varargin(1:3:end), varargin(2:3:end), varargin(3:3:end), 'UniformOutput', false);
            colCheckStr = [' and ' strjoin(colCheckStrCell, ' and ') colCheckStrIn];
        else
            addColChecks = addColChecksIn;
            colCheckStr = colCheckStrIn;
        end
    end
    
    % We check a data quality greater than zero to allow a zero value to
    % indicate a completely bad fly (i.e. you realize the stimulus was
    % coded wrong)
    sysConfig = GetSystemConfiguration;
    connDbServer = connectToDatabase(sysConfig.databasePathServer, true);
    connDbLocal = connectToDatabase(sysConfig.databasePathLocal, true);
    if ~isempty(paramfile)
        stimFunctionCheck = ['sP.stimulusFunction in ("' paramfile '") and'];
    else
        stimFunctionCheck = '';
    end
    if ~isempty(fluorescentProtein)
        fluorescentProteinCheck = [' f.fluorescentProtein in ("' fluorescentProtein '") and'];
    else
        fluorescentProteinCheck = '';
    end
    dbCall = ['select distinct stimulusFunction, relativeDataPath, stimulusPresentationId, eye, surgeon, dataQuality' addColChecks ' from stimulusPresentation as sP join fly as f on f.flyId=sP.fly join expressionSystemFlyJoin as eSFJ on eSFJ.fly = sP.fly join expressionSystem as eS on eS.expressionSystemId = eSFJ.expressionSystem where ' stimFunctionCheck fluorescentProteinCheck ' f.cellType="' cellType '"' colCheckStr ];
    if isempty(connDbServer) && isempty(connDbLocal)
        error('You connected to neither the local nor database server')
    elseif isempty(connDbServer) && ~isempty(connDbLocal)
        dataReturnLocal = fetch(connDbLocal, dbCall);
        dataReturnServer = {};
    elseif isempty(connDbLocal) && ~isempty(connDbServer)
        dataReturnServer = fetch(connDbServer, dbCall);
        dataReturnLocal = {};
    else
        dataReturnLocal = fetch(connDbLocal, dbCall);
        dataReturnServer = fetch(connDbServer, dbCall);
    end

    if ~isempty(dataReturnLocal)
        dataReturnLocalIds = cell2mat(dataReturnLocal(:, 3));
    else
        dataReturnLocalIds = [];
    end
    if ~isempty(dataReturnServer)
        dataReturnServerIds = cell2mat(dataReturnServer(:, 3));
    else
        dataReturnServerIds = [];
    end
    
    serverOnlyPaths = dataReturnServer(~ismember(dataReturnServerIds, dataReturnLocalIds), :);
    
    dataReturn = [serverOnlyPaths; dataReturnLocal];
    % Get rid of dataQuality == 0, but keep any null values (which come out
    % as strings into the database). We do this here so if EITHER database
    % displays a dataQuality==0 that data is kicked out--prevents requiring
    % a backup to the server to get rid of a dataset for which a 0 was set
    % in the local database
    dataReturn = dataReturn(cellfun(@(x) isnan(x) || x>0, dataReturn(:, 6)), :);
    if isempty(dataReturn)
        error('no paths with these parameters');
    end
    
    relPaths = dataReturn(:,2);
    relPathsDelete = false(size(relPaths));
    if nargin > 3 && ~isempty(flyEye)
        relPathsDelete = relPathsDelete | ~strcmp(dataReturn(:, 4), flyEye);
    end
    
    if nargin > 4 && ~isempty(surgeon)
        relPathsDelete = relPathsDelete | ~strcmp(dataReturn(:, 5), surgeon);
    end
    
    relPaths = relPaths(~relPathsDelete);

    twoPhotDataServer = sysConfig.twoPhotonDataPathServer;
    twoPhotDataLocal = sysConfig.twoPhotonDataPathLocal;

    for dd = length(relPaths):-1:1
        relPaths{dd}(relPaths{dd}=='\') = '/';
        relPathsLocalTemp = fullfile(twoPhotDataLocal,relPaths{dd});
        relPathsServerTemp = fullfile(twoPhotDataServer, relPaths{dd});
        if ~isdir(relPathsLocalTemp) && isdir(relPathsServerTemp)
            relPaths{dd} =fullfile(twoPhotDataServer,relPaths{dd});
        elseif isdir(relPathsLocalTemp) && ~isdir(relPathsServerTemp)
            relPaths{dd} =relPathsLocalTemp;
        elseif ~isdir(relPathsLocalTemp) && ~isdir(relPathsServerTemp)
            warning('Couldn''t find the datapath\n\n"%s"\n\nanywhere; ignoring it.', relPaths{dd});
            relPaths(dd) = [];
        else
            relPaths{dd} =relPathsLocalTemp;
        end
        if dd==length(relPaths)
            relPaths{dd}(relPaths{dd}=='\') = '/';
        end
    end
end