function [epochsForSelectionForFly, flyEye, vararginOut] = AdjustEpochsForEye(dataPath, epochsForSelectivity, epochsForIdentification, varargin)

varsNeedingChanging = [isempty(epochsForSelectivity), isempty(epochsForIdentification)];
changeableVarargin = {'epochsForSelectivity', 'epochsForIdentification'};
changeableVarargin = changeableVarargin(varsNeedingChanging);

for ii = 1:2:length(varargin)
    if any(strcmp(changeableVarargin, varargin{ii}))
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    else
        continue
    end
end

flyEye = GetEyeFromDatabase(dataPath);
% We're going to make left the dominant eye so we only switch
% up epochsForSelectivity if the eye is 'right'
if strcmp('right', flyEye)
    if exist('epochsForIdentification', 'var') && ~isempty(epochsForIdentification)
        tempEpochsForIdentification = epochsForIdentification;
        valsLeft = strfind(lower(epochsForIdentification), 'left');
        leftToRightSwitch = cellfun(@(epoch) [epoch(1:strfind(epoch, 'left')-1) 'right' epoch(strfind(epoch, 'left')+4:end)], lower(epochsForIdentification), 'UniformOutput', false);
        tempEpochsForIdentification(~cellfun('isempty',valsLeft)) = leftToRightSwitch(~cellfun('isempty', valsLeft));
        
        
        valsRight = strfind(lower(epochsForIdentification), 'right');
        leftToRightSwitch = cellfun(@(epoch) [epoch(1:strfind(epoch, 'right')-1) 'left' epoch(strfind(epoch, 'right')+5:end)], lower(epochsForIdentification), 'UniformOutput', false);
        tempEpochsForIdentification(~cellfun('isempty',valsRight)) = leftToRightSwitch(~cellfun('isempty', valsRight));
        
        if any(strcmp(varargin, 'epochsForIdentificationForFly'))
            varargin{[false strcmp(varargin, 'epochsForIdentificationForFly')]} = tempEpochsForIdentification;
        else
            varargin{end+1} = 'epochsForIdentificationForFly';
            varargin{end+1} = tempEpochsForIdentification;
        end
        % Gotta assign this variable for the save extraction
        % file check
%         epochsForIdentificationForFly = tempEpochsForIdentification;
    end
    
    if ~isempty(epochsForSelectivity)
        epochsForSelectionForFly = epochsForSelectivity;
        valsLeft = strfind(lower(epochsForSelectivity), 'left');
        leftToRightSwitch = cellfun(@(epoch) [epoch(1:strfind(epoch, 'left')-1) 'right' epoch(strfind(epoch, 'left')+4:end)], lower(epochsForSelectivity), 'UniformOutput', false);
        epochsForSelectionForFly(~cellfun('isempty',valsLeft)) = leftToRightSwitch(~cellfun('isempty', valsLeft));
        
        
        valsRight = strfind(lower(epochsForSelectivity), 'right');
        leftToRightSwitch = cellfun(@(epoch) [epoch(1:strfind(epoch, 'right')-1) 'left' epoch(strfind(epoch, 'right')+5:end)], lower(epochsForSelectivity), 'UniformOutput', false);
        epochsForSelectionForFly(~cellfun('isempty',valsRight)) = leftToRightSwitch(~cellfun('isempty', valsRight));
    else
        epochsForSelectionForFly = epochsForSelectivity;
    end
else
    if exist('epochsForIdentification', 'var')
        % Gotta assign this variable for the save extraction
        % file check
%         epochsForIdentificationForFly = epochsForIdentification;
        if any(strcmp(varargin, 'epochsForIdentificationForFly'))
            varargin{[false strcmp(varargin, 'epochsForIdentificationForFly')]} = epochsForIdentification;
        else
            varargin{end+1} = 'epochsForIdentificationForFly';
            varargin{end+1} = epochsForIdentification;
        end
    end
    epochsForSelectionForFly = epochsForSelectivity;
    
end

% flyEye = {flyEye};
vararginOut = varargin;