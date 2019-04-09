function fourierGAL4SplineAnalysis

    todayIs = weekday(today);
%     if any(todayIs == [5])
%         todayIs = 7; 
%     end
    dayNames = {'Sunday Funday','Monday Punday','Tuesday Haikusday','Wednesday Trendsday',...
        'Thursday Wordsday','Friday Inspriday','Saturday Flatterday'};
    
    switch todayIs
        case 1 % Sunday Funday
            objs = ...
                {'learning to play the violin like you''ve always wanted.',...
                'catching up with old friends you haven''t seen in a while and keep meaning to call.',...
                'going on the most refreshing jog of your life.',...
                'taking another stab at Finnegan''s Wake.',...
                'writing your memoir -- I bet it''d be really interesting!',...
                'learning to bake fresh bread at home.'};
        case 2 % Monday Punday
            objs = ...
                {'Seven days without wordplay makes one weak.',...
                'Police were called to a daycare where a three-year-old was resisting a rest.',...
                'Need an ark to save two of every animal? I Noah guy.',...
                'I relish the fact that you''ve mustard the strength to ketchup to me.',...
                'Broken puppets for sale. No strings attached.',...
                'I was struggling to figure out how lightning works then it struck me.',...
                'Time flies like an arrow. Fruit flies like a banana.',...
                'What''s Thor''s favorite Daft Punk song?\nGet Loki.',...
                'What do you call a mushroom who likes to party?\nA fungi.'};
        case 3 % Tuesday Haikusday
             objs = ...
                {'Two Photon Data\nMatrix manipulations\nExtracting Kernels',...
                'Hassenstein and Reich\nardt. Adelson and Bergen.\nBarlow and Levick.',...
                'Life, Domain, Kindgom\nPhylum, Class, Order, Family,\nGenus and Species.',...
                'TwoPhotonMaster\nTwoPhotonImageParser\nTwoPhotonPlotter',...
                'Drosophila Mel\nanogaster, the fruit fly,\nis out to spite you',...
                'If photodiode\nis erroring your output,\nmight as well give up'};
            
        case 4 % Wednesday Trendsday
            % EMILIO GET ON THIS
            try
                sysConfig = GetSystemConfiguration;
                connDb = connectToDatabase(sysConfig.databasePathLocal, true);
                if isempty(connDb)
                    connDb = connectToDatabase(sysConfig.databasePathServer);
                end
                tableNames = tables(connDb, '');
                tableNames = tableNames(:, 1);
                tableNames(strcmp(tableNames, 'analysisRun')) = [];
                checkNewTable = true;
                while checkNewTable
                    tableOfInterest = tableNames{randi([1, length(tableNames)])};
                    
                    tableFetch = exec(connDb, sprintf('select * from %s', tableOfInterest));
                    tableRow = fetch(tableFetch, 1);
                    columnData = attr(tableRow);
                    numRows = rows(fetch(tableFetch));
                    columnNames = {columnData.fieldName};
                    dataType = {columnData.typeName};
                    
                    % Skip 1 because that's usually the primary key --
                    % uninteresting
                    numUniqueVals = numRows;
                    attempts = 0;
                    maxAttempts = 10;
                    while numUniqueVals>0.95*numRows && attempts <= maxAttempts
                        columnIndOfInterest = randi([2, length(columnNames)]);
                        columnOfInterest = columnNames{columnIndOfInterest};
                        numUniqueVals = fetch(connDb, sprintf('select count(distinct %s) from %s', columnOfInterest, tableOfInterest));
                        numUniqueVals = numUniqueVals{1};
                        attempts = attempts + 1;
                    end
                    
                    if numUniqueVals <= 0.95*numRows
                        checkNewTable = false;
                    end
                end
                    
                outputTypes = {'dataSummary', 'extremas'};
                outputType = outputTypes{randi([1, length(outputTypes)])};
                switch outputType
                    case 'dataSummary'
                        dataPoints = fetch(connDb, sprintf('select distinct %s from %s', columnOfInterest, tableOfInterest));
                        dataPointOfInterest = dataPoints{randi([1, length(dataPoints)])};
                        if any(strfind(lower(dataType{columnIndOfInterest}), 'text'))
                            number = fetch(connDb, sprintf('select count(*) from %s where %s="%s"', tableOfInterest, columnOfInterest, dataPointOfInterest));
                            number = number{1};
                            objs = {sprintf('There are %d %sZ with "%s" as the %s', number, tableOfInterest, dataPointOfInterest, columnOfInterest)};
                        else
                            number = fetch(connDb, sprintf('select count(*) from %s where %s=%d', tableOfInterest, columnOfInterest, dataPointOfInterest));
                            number = number{1};
                            objs = {sprintf('There are %d %sZ with %d as the %s', number, tableOfInterest, dataPointOfInterest, columnOfInterest)};
                        end
                    case 'extremas'
                        dataPoints = fetch(connDb, sprintf('select distinct %s from %s', columnOfInterest, tableOfInterest));
                        counts = zeros(1, length(dataPoints));
                        for i = 1:length(dataPoints)
                            goString = false;
                            if isnan(dataPoints{i})
                                dataPoints{i} = '''Null''';
                                goString = true;
                            end
                            if goString
                                number = fetch(connDb, sprintf('select count(*) from %s where %s is null', tableOfInterest, columnOfInterest));
                            elseif any(strfind(lower(dataType{columnIndOfInterest}), 'text'))
                                number = fetch(connDb, sprintf('select count(*) from %s where %s="%s"', tableOfInterest, columnOfInterest, dataPoints{i}));
                            else
                                number = fetch(connDb, sprintf('select count(*) from %s where %s=%d', tableOfInterest, columnOfInterest, dataPoints{i}));
                            end
                            counts(i) = number{1};
                        end
                        timeNow = clock;
                        if mod(floor(timeNow(6)), 2)
                            [~, ind] = max(counts);
                            if isnumeric(dataPoints{ind})
                                dataPoints{ind} = num2str(dataPoints{ind});
                            end
                            objs = {sprintf('The amplest %s of %sZ is "%s"', columnOfInterest, tableOfInterest, dataPoints{ind})};
                        else
                            [~, ind] = min(counts);
                            if isnumeric(dataPoints{ind})
                                dataPoints{ind} = num2str(dataPoints{ind});
                            end
                            objs = {sprintf('The scarcest %s of %sZ is "%s"', columnOfInterest, tableOfInterest, dataPoints{ind})};
                        end
                end
            catch err
                objs = {'Oh, ye sad one, ye have no database. Ye may now go forth and cry in a corner :''('};
                disp(err.message)
                keyboard
            end
            
            
            objs{1} = wordWrap(objs{1});

        case 5 % Thursday Wordsday
            randomWordWebpage = urlread('https://randomword.com/');
            randomWordRegex = '<div id="random_word">([\w\s]+)</div>';
            randomWordDefinitionRegex = '<div id="random_word_definition">(.+?)</div>';
            
            randomWordCell = regexp(randomWordWebpage,randomWordRegex,'tokens');
            randomWordDefinitionCell = regexp(randomWordWebpage,randomWordDefinitionRegex,'tokens');
            
            randomWord = strtrim(randomWordCell{1}{1});
            randomWordDefinition = strtrim(randomWordDefinitionCell{1}{1});
            
            objs = {sprintf('Did you know that "%s" means "%s"? Now you know.', randomWord, randomWordDefinition)};
            objs{1} = wordWrap(objs{1});
            
        case 6 % Friday Inspriday
            objs = ...
                {'The strongest people are not those who show strength in front of us,\nbut those who win battles we know nothing about.',...
                'Nothing great was ever achieved without enthusiasm.',...
                'You haven''t failed until you stop trying.\nUntil then, your success is merely postponed.',...
                'I may not be there yet, but I''m closer than I was yesterday.',...
                'Life is too short to worry about what others say or think about you.\nHave fun and give them something to talk about.',...
                'The only person you should try to be better than is the person you were yesterday.',...
                'Work until you no longer have to introduce yourself.',...
                'Life begins at the end of your comfort zone.',...
                'Courage does not always roar.\nSometimes courage is the quiet voice at the end of the day saying,\n"I will try again tomorrow."',...
                'Comfort is the enemy of achievement.'};
            
        case 7 % Saturday Flatterday
            nouns = { 'hair','smile','experimental result','intellect','outfit','hypothesis','methodology',...
                'analysis','left ear','mom' };
            verbs = { 'looks','smells','appears','is','seems'};
            adjs = { 'kindly','generous','clean','valid','well-grounded in empirical results','mathematically rigorous',...
                'insightful','courageous','comforting','statistically significant' };
    end
    
    switch todayIs 
        case  1
            numObjs = length(objs);
            whichObj = ceil(rand*numObjs);
            fprintf('\nRight now, you could be ');
            fprintf(objs{whichObj});
            fprintf('\nInstead, you are in lab analyzing data.\nHappy Sunday Funday!\n\n');
            
        case 7
            a = ceil(rand*length(nouns));
            b = ceil(rand*length(verbs));
            c = ceil(rand*length(adjs));
            fprintf('\nMy, your %s %s very %s today.\nHappy Saturday Flatterday!\n\n',nouns{a},verbs{b},adjs{c});
            
        otherwise
            numObjs = length(objs);
            whichObj = ceil(rand*numObjs);
            fprintf('\n');
            fprintf(objs{whichObj});
            fprintf('\nHappy %s!\n\n',dayNames{todayIs});
    end
    
end

function outString = wordWrap(inString)
outString = '';
for j = 1:size(inString, 1);
    i = 1;
    while i<size(inString, 2)
        if (i+72)>size(inString, 2)
            i_end = size(inString, 2);
        else
            i_end = i+find(inString(j, i:i+72)==' ', 1, 'last')-1;
        end
        if ~all(inString(j, i:i_end)==' ')
            outString = sprintf('%s%s\n', outString, inString(j, i:i_end));
        end
        i = i_end+1;
    end
    if ~all(inString(j, :) == ' ') && j ~= size(inString, 1)
        outString = sprintf('%s\n', outString);
    end
end
end

