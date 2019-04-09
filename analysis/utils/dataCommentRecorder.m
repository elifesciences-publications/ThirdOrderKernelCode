function dataCommentRecorder(stimulusPresentationInformation)

connDb = connectToDatabase;
stimulusPresentationId = stimulusPresentationInformation.stimulusPresentationId;
analysisMethod = stimulusPresentationInformation.analysisFunction;
functionCall = stimulusPresentationInformation.functionCall;

if ~isfield(stimulusPresentationInformation, 'params')
    runInfoVariable = '';
else
    runInfoVariable = '';
    paramNames = fieldnames(stimulusPresentationInformation.params);
    for paramInd = 1:length(paramNames)
        stringValue = ValueToStringFormattedAsMatlabInput(stimulusPresentationInformation.params.(paramNames{paramInd}));
        runInfoVariable = sprintf('%sZ.params.%s = %s;\n', runInfoVariable, paramNames{paramInd}, stringValue);
    end
end

% Check to make sure that we haven't seen this data before!
count = fetch(connDb, sprintf('select count(*) from analysisRun where stimulus=%d and runInfoVariable="%s"', stimulusPresentationId, runInfoVariable));

if ~count{1}
    defaults.analysisQuality = '3';
    prompts(1, :) = { 'Analysis quality (1-5)', 'analysisQuality', []};
    formats(1,1).type = 'list';
    formats(1,1).format = 'text';
    formats(1,1).style = 'radiobutton';
    formats(1,1).items = {'1', '2', '3', '4', '5'};
    formats(1,1).labelloc = 'topleft';
    
    prompts(2, :) = { 'Enter any comments', 'comments', []};
    formats(2,1).type = 'edit';
    formats(2,1).format = 'text';
    formats(2,1).labelloc = 'topleft';
    formats(2,1).span = [1, 1];
    formats(2,1).limits = [1, 2];
    formats(2,1).limits = [0 9]; % default: show 20 lines (10 around the middle on both sides)
    formats(2,1).size = [500 100];
    formats(2,1).span = [1 1];
    
    dialogTitle = 'Analysis comment form';
    
    % numLines = [1 80; 1 40; 1 40; 1 80; 1 40; 1 40; 5 80];
    % answer = inputdlg(prompts, 'Fly database input',numLines);
    
    options.Interpreter = 'none';
    options.CancelButton = 'on';
    options.ButtonNames = {'Submit'};
    
    [commentsInfo,Cancelled] = InputsDlg(prompts,dialogTitle,formats,defaults,options);
    commentsOnData = commentsInfo.comments;
    commentsOnData = wordWrap(commentsOnData);
    analysisQuality = commentsInfo.analysisQuality;
    
    
    
    if ~Cancelled
        runDate = datestr(now);
        currDir = cd;
        analysisLocation = fileparts(which('RunMultipleStimuli'));
        cd(analysisLocation)
        
        [~, gitCommit] = system('git rev-parse HEAD');
        [~,~] = system('git add .');
        [~, gitPatch] = system('git diff --cached --exit-code');
        [~,~] = system('git reset HEAD .');
        
        datainsert(connDb, 'analysisRun', {'runDate','stimulus', 'comments', 'functionCall', 'analysisMethod', 'runInfoVariable', 'analysisQuality', 'gitCommit', 'gitPatch'},...
            {runDate,stimulusPresentationId, commentsOnData,functionCall,analysisMethod, runInfoVariable, analysisQuality, gitCommit, gitPatch});
        
        %It's nice to end in the folder with the originally analyzed file...
        cd(currDir)
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

end