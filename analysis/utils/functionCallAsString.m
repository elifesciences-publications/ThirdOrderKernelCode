function functionCallString = functionCallAsString(functionToStringInfo, varargin)

%Add in the outputs (names won't matter here, just # of outputs)
argsOutput = functionToStringInfo.outputs;
if argsOutput
    functionCallString = sprintf('[');
    i=0; %Only initialize in case there's only 1 output
    for i = 1:argsOutput-1
        functionCallString = sprintf('%sout_%d, ', functionCallString, i);
    end
    %Add in the last output and close up the vector
    functionCallString = sprintf('%sout_%d] = ', functionCallString, i+1);
else
    functionCallString = '';
end

%Add function name
functionCallString = sprintf('%s%s(', functionCallString, functionToStringInfo.functionName);

%Add inputs
% if argsInput==0
%     %No inputs means you can delete the open parenthesis
%     functionCallString = sprintf('%s\b', functionCallString);
% elseif argsInput < 0
%     numHardInputs = abs(argsInput)-1;
%     varArgs = true;
% else
%     numHardInupts = argsInput;
%     varArgs = false;
% end

%Insert the hard inputs
for i = 1:length(varargin)
    if functionToStringInfo.inputs(i).bytes < 2*2^10; % Only write out inputs that are less than 2KB
        actualString = ValueToStringFormattedAsMatlabInput(varargin{i});
        if isempty(actualString)
            % If we can't parse the input type (I'm thinking something like
            % connDb here)
            functionCallString = sprintf(['%s' functionToStringInfo.inputs(i).name ', '], functionCallString);
        else
            functionCallString = sprintf(['%s' actualString ', '], functionCallString);
        end
    else
        % If it's greater than 2KB, we write the placeholder variable. I'm
        % imagining this as being things like Z, which just isn't necessary
        % lulz
        functionCallString = sprintf(['%s' functionToStringInfo.inputs(i).name ', '], functionCallString);
    end
end

% Close up the function after removing the trailing ', '
functionCallString = functionCallString(1:end-2);
functionCallString = [functionCallString ');'];


   
end