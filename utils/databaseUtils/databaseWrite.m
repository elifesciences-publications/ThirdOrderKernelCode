function key = databaseWrite(databaseConnection, inputs, table)



switch table
    case 'fly'
        newFly = inputs.newFly;
        inputs = rmfield(inputs, 'newFly');
        columns = fieldnames(inputs)';
        if ~any(strcmp(columns, 'relativePath'))
            error('We need a relativePath for the fly!');
        end
        
        if newFly
            datainsert(databaseConnection, table, columns, struct2cell(inputs)')
        end
        data = fetch(databaseConnection, sprintf('select flyId from fly where behaviorId = "%s"', inputs.behaviorId));
        key = data{1};
    case 'stimulusPresentation'
        columns = fieldnames(inputs)';
        if ~any(strcmp(columns, 'relativeDataPath'))
            error('We need a relativeDataPath for the stimulus presentation!');
        end
        data = fetch(exec(databaseConnection, sprintf('select stimulusPresentationId from stimulusPresentation where relativeDataPath = "%s"', inputs.relativeDataPath)));
        if ~iscell(data.Data) || strcmp(data.Data, 'No Data')
            datainsert(databaseConnection, table, columns, struct2cell(inputs)')
            data = fetch(exec(databaseConnection, sprintf('select stimulusPresentationId from stimulusPresentation where relativeDataPath = "%s"', inputs.relativeDataPath)));
        end
        key = data.Data{1};
    case 'expressionSystemFlyJoin'
        columns = fieldnames(inputs)';
        if ~any(strcmp(columns, 'expressionSystem'))
            error('We need an expressionSystem for the stimulus presentation!');
        end
        for exprSystems = 1:length(inputs.expressionSystem)
            data = fetch(exec(databaseConnection, sprintf('select expressionSystemId from expressionSystem where name = "%s"', inputs.expressionSystem{exprSystems})));
            if ~iscell(data.Data) || strcmp(data.Data, 'No Data')
                databaseExpressionSystem.name = inputs.expressionSystem;
                inputs.expressionSystem = databaseWrite(databaseConnection, databaseExpressionSystem, 'expressionSystem');
            else
                inputs.expressionSystem = data.Data{1};
            end
            datainsert(databaseConnection, table, columns, struct2cell(inputs)')
            data = fetch(exec(databaseConnection, sprintf('select esfId from expressionSystemFlyJoin where expressionSystem = %d and fly = %d', inputs.expressionSystem, inputs.fly)));
        end
        key = data.Data{1};
    case 'expressionSystem'
        columns = fieldnames(inputs)';
        datainsert(databaseConnection, table, columns, struct2cell(inputs)')
        data = fetch(exec(databaseConnection, sprintf('select expressionSystemId from expressionSystem where name = "%s"', inputs.name)));
        key = data.Data{1};
end