function actualString = ValueToStringFormattedAsMatlabInput(input)

actualString = [];
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
        actualString = regexprep(actualString, '\s+', ' ');
    case 'char'
        actualString = sprintf('''%s''', input);
    case 'struct'
        fldNames = fieldnames(input);
        
        actualString = 'struct(';
        for j = 1:length(fldNames)-1
            actualString = sprintf('%s''%s'',', actualString, fldNames{j});
            actualFieldString = ValueToStringFormattedAsMatlabInput(input.(fldNames{j}));
            actualString = sprintf('%s%s,', actualString, actualFieldString);
        end
        % Get the last field in here
        actualString = sprintf('%s''%s'',', actualString, fldNames{j+1});
        actualFieldString = ValueToStringFormattedAsMatlabInput(input.(fldNames{j+1}));
        actualString = sprintf('%s%s)', actualString, actualFieldString);
end
end