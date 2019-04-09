function functionCallString = functionCallAsString(functionName, argsOutput, varargin)

%Add in the outputs (names won't matter here, just # of outputs)
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
functionCallString = sprintf('%s%s(', functionCallString, functionName);

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
for i = 1:length(varargin)-1
    [fmtString, actualString] = getFormatString(varargin{i});
    if isempty(actualString)
        functionCallString = sprintf(['%s' fmtString ', '], functionCallString, varargin{i});
    else
        functionCallString = sprintf(['%s' actualString ', '], functionCallString);
    end
end

%Close up the function call after adding in the last variable
[fmtString, actualString] = getFormatString(varargin{end});
if isempty(actualString)
    functionCallString = sprintf(['%s' fmtString ')'], functionCallString, varargin{end});
else
    functionCallString = sprintf(['%s' actualString ')'], functionCallString);
end

    function [fmtString, actualString] = getFormatString(input)
        actualString = [];
        fmtString = '';
        switch class(input)
            case {'uint16', 'uint8', 'double', 'logical'}
                actualString = num2str(input);
                if size(actualString, 1)>1
                    tempString = actualString;
                    actualString = ['[' tempString(1, :)];
                    for strRow = 2:size(tempString, 1)
                        actualString = sprintf('%s; %s', actualString, tempString(strRow, :));
                    end
                    actualString = [actualString ']'];
                else
                    actualString = ['[' actualString ']'];
                end
            case 'char'
                fmtString = '''%s''';
        end
    end
end