function [conn, relativePath] = connectToDatabase(dbpath, allowEmpty)
% need a javapath.txt file in the folder output by prefdir command and the
% javapath.txt file needs to point to the *.jar file for sqlite (think
% sqlite-jdbc-3.8.7.jar) found at https://bitbucket.org/xerial/sqlite-jdbc/downloads
if nargin< 1 || isempty(dbpath)
    sysConfig = GetSystemConfiguration;

    
    relativePath = sysConfig.twoPhotonDataPathLocal;
    dbpath = sysConfig.databasePathLocal;
end

if nargin<2
    allowEmpty = false;
end

% setdbprefs('DataReturnFormat', 'structure')
if ~ischar(dbpath)
    error('You must include the location of the database (with database name included!) as the fourth line of the dataPath.csv file!');
end

% jdbc is the database style, and sqlite is the type of database
URL = ['jdbc:sqlite:' dbpath];
% org.sqlite.JDBC is the driver it's looking for
conn = database('', '', '', 'org.sqlite.JDBC', URL);
if ~isempty(conn.Message)
    if strcmp(conn.Message, 'Unable to find JDBC driver.')
        error(['You must download the sqlite Java driver '...
            '(check out https://bitbucket.org/xerial/sqlite-jdbc/downloads '...
            'and look for sqlite-jdbc-*.*.*.jar) and then run prefdir in Matlab '...
            'to find the directory in which to create a javaclasspath.txt file which '...
            'includes a full pathway (including filename!) to the *.jar file '...
            'you downloaded.']);
    else
        if allowEmpty
            warning('database:connect:emptyConnection', ['Connection attempt returned the following message: ' conn.Message]);
            conn = [];
        else
            error(['Connection attempt returned the following message: ' conn.Message]);
        end
    end
end
