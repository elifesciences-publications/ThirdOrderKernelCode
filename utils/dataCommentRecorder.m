function dataCommentRecorder(name, path, analysisMethod, functionCall, outputVar, output)

%On the off chance we're not there already...
cd(path)
if isdir('analysisRuns')
    cd('analysisRuns')
else
    mkdir('analysisRuns')
    cd('analysisRuns')
end

fh = fopen([name '_comments.m'], 'a');

pos = ftell(fh);

% Start of the file!
if pos == 0
    prompts = {'Enter cells/genotypes being recorded (e.g. T4T5, 21Dhh or L2, R27B03 or HS)','Enter UAS fluorescent protein (e.g. ArcLD, GC6m, RGECO)','What do you think about the analysis? What does it show, etc.? Is it good/bad?'};
    dialogTitle = 'Data review comments';
    numLines = [1 80; 1 80; 5 80];
    default = {name, name, ''};
    comments = inputdlg(prompts,dialogTitle,numLines,default,struct('WindowStyle', 'normal'));
    
    if isempty(comments) || isempty(comments{3})
        warning('No comments about the data were written, so information about this run is being discarded');
        cd(path)
        return
    end
    
    cellGenotype = comments{1};
    fluorescentGenotype = comments{2};
    commentsOnData = comments{3};
    fprintf(fh, '%% Cell type: %s\n', cellGenotype);
    fprintf(fh, '%% Fluorescent protein: %s\n', fluorescentGenotype);
    fprintf(fh, '\n\n');
else
    prompts = {'What do you think about the analysis? What does it show, etc.? Is it good/bad?'};
    dialogTitle = 'Data review comments';
    numLines = [5 80];
    default = {''};
    comments = inputdlg(prompts,dialogTitle,numLines,default,struct('WindowStyle', 'normal'));
    if isempty(comments) || isempty(comments{1})
        warning('No comments about the data were written, so information about this run is being discarded');
        cd(path)
        return
    end
    commentsOnData = comments{1};
end



date = datestr(now);
fprintf(fh, '%% %s\n', date);
fprintf(fh, '%% Analysis method: %s\n', analysisMethod);
fprintf(fh, '%% Comments:\n%s\n', wordWrap(commentsOnData));
fprintf(fh, '%% Function call:\n%s\n', functionCall);
fprintf(fh, '%% Run info variable: %s\n', outputVar);
%Add some lines to separate extra ones
fprintf(fh, '\n\n');

fclose(fh);

%It's nice to end in the folder with the originally analyzed file...
cd(path)
saveVariables.(outputVar) = output;
saveOrAppendMatFile([name '.mat'], saveVariables);





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
                    outString = sprintf('%s%% %s\n', outString, inString(j, i:i_end));
                end
                i = i_end+1;
            end
            if ~all(inString(j, :) == ' ') && j ~= size(inString, 1)
                outString = sprintf('%s%%\n', outString);
            end
        end
    end

end