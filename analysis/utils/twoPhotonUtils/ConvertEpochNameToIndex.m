function selectedEpochs = ConvertEpochNameToIndex(params,epochsForSelection)

if ischar(epochsForSelection)
    epochsForSelection = {epochsForSelection};
end
if iscell(epochsForSelection)
    for ee = 1:size(epochsForSelection, 1)
        for ff = 1:size(epochsForSelection, 2)
            if ~isnumeric(epochsForSelection{ee,ff})
                %                 found = 0;
                if isempty(epochsForSelection{ee,ff})
%                     error('no epoch by that name');
                    epochsForSelection{ee,ff} = nan;
                elseif isfield(params,'epochName')
                    % Convert epochs without names to having empty strings
                    epochNames = cellfun(@(nm) ['' nm], {params.epochName}, 'UniformOutput', false);
                    % Find the epochs we're looking for
                    epochsForSelection{ee,ff} = find(strcmp(lower(epochNames),lower(epochsForSelection{ee,ff})));
                end
                %                 for pp = 1:length(params)
                %                     if isfield(params(pp),'epochName')
                %                         if strcmp(lower(params(pp).epochName),lower(epochsForSelection{ee}))
                %                             epochsForSelection{ee} = pp;
                %                             found = 1;
                %                         end
                %                     end
                %                 end
                
                if isempty(epochsForSelection{ee,ff})
%                     error('no epoch by that name');
                    epochsForSelection{ee,ff} = nan;
                end
            end
        end
        
    end
    selectedEpochs = cell2mat(epochsForSelection);
else
    selectedEpochs = epochsForSelection;
end