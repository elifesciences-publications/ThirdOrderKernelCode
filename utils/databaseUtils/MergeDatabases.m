function MergeDatabases(database1, database2)

if nargin<1
    unchosenDatabases = 2;
    databasesToMerge = {};
elseif nargin<2
    unchosenDatabases = 1;
    databasesToMerge = {database1};
else
    unchosenDatabases = 0;
    databasesToMerge = {database1, database2};
end

while unchosenDatabases > 0
    databasesToMerge = [databasesToMerge UiPickFiles('out', 'cell')];
    unchosenDatabases = 2-length(databasesToMerge);
end

connDb1 = connectToDatabase(databasesToMerge{1});
connDb2 = connectToDatabase(databasesToMerge{2});


tableNames1 = tables(connDb1);
tableNames2 = tables(connDb2);
tableNames1 = tableNames1(:, 1);
tableNames2 = tableNames2(:, 1);
if ~isequal(tableNames1, tableNames2)
    error('The two databases must have the same tables!');
end
tableNames = tableNames1;

for i = 1:length(tableNames1)
    tableOfInterest = tableNames{i};
    
    % We want the column data, this is the only way I know how to get it
    tableFetch = exec(connDb1, sprintf('select * from %s', tableOfInterest));
    tableRow = fetch(tableFetch, 1);
    columnData = attr(tableRow);
    columnNames1 = {columnData.fieldName};
    
    tableFetch = exec(connDb2, sprintf('select * from %s', tableOfInterest));
    tableRow = fetch(tableFetch, 1);
    columnData = attr(tableRow);
    columnNames2 = {columnData.fieldName};
    if ~isequal(columnNames1, columnNames2)
        error('The tables %s don''t have the same column names in the two databases!', tableOfInterest);
    end
    columnNames = columnNames1;
    
    
    rows1 = fetch(connDb1, sprintf('select * from %s', tableOfInterest));
    rows2 = fetch(connDb2, sprintf('select * from %s', tableOfInterest));
    
    try
        datainsert(connDb2, tableOfInterest, columnNames, rows1);
    catch uniqueError
        if any(strfind(uniqueError.message, 'UNIQUE'))
            if any(strfind(uniqueError.message, tableOfInterest));
                indexesOfInterest = strfind(uniqueError.message, tableOfInterest);
                messagePartOfInterest = uniqueError.message(indexesOfInterest(1):end);
                periodIndex = strfind(messagePartOfInterest, '.');
                fieldOfInterest = messagePartOfInterest(periodIndex+1:end);
            else
                rethrow(uniqueError)
            end
        else
            rethrow(uniqueError)
        end
    end
    
    columnOfInterest = strcmp(columnNames, fieldOfInterest);
    if isnumeric(rows1{1, columnOfInterest})
        differentRows1 = ~ismember([rows1{:, columnOfInterest}], [rows2{:, columnOfInterest}]);
    else
        differentRows1 = ~ismember(rows1(:, columnOfInterest), rows2(:, columnOfInterest));
    end
    rowsToInsert = rows1(differentRows1, :);
    
    % Insert unique rows, update rows2 to find any unique rows it has
    datainsert(connDb2, tableOfInterest, columnNames, rowsToInsert);
    rows2 = fetch(connDb2, sprintf('select * from %s', tableOfInterest));
    
    if isnumeric(rows1{1, columnOfInterest})
        differentRows2 = ~ismember([rows2{:, columnOfInterest}], [rows1{:, columnOfInterest}]);
    else
        differentRows2 = ~ismember(rows2(:, columnOfInterest), rows1(:, columnOfInterest));
    end
    rowsToInsert = rows2(differentRows2, :);
    % Insert unique rows, so they're now equivalent
    datainsert(connDb1, tableOfInterest, columnNames, rowsToInsert);
end