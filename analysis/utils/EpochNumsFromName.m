function epochNumbers = EpochNumsFromName(epochInputName, epochNames) 

if ~isnumeric(epochInputName)
    if iscell(epochInputName)
        epochInputName = [];
        for i = 1:size(epochInputName, 1)% We should only compare two at a time!
            for j = 1:size(epochInputName, 2) 
                epochIndex = find(strcmp({Z.stimulus.params.epochName}, epochInputName{i, j}));
                if ~isempty(epochIndex)
                    epochInputName(i, j) = epochIndex;
                end
            end
        end
        epochNumbers = epochInputName;
    elseif ischar(epochInputName)
        epochNumbers = find(strcmp(epochNames, epochInputName));
    end
end

% epochNumbers = epochName;