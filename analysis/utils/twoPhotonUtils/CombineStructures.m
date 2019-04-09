function combinedStructure = CombineStructures(mainStructure, appendStructure)
%COMBINESTRUCTURES combines the two input structures
%   combinedStructure = COMBINESTRUCTURES(mainStructure, appendStructure)
%   merges the two input structures so the output combinedStructure has all
%   the fields of both mainStructure and appendStructure. If any fields are
%   identical between the two structures, the values in appendStructure
%   take precedence, unless the field is 'defaults', in which case those
%   are merged recursively

if ~isempty(appendStructure)
    extraVarNames = fieldnames(appendStructure);
    for extraVarNameInd = 1:length(extraVarNames)
        if strcmp(extraVarNames{extraVarNameInd}, 'defaults')
            if isfield(mainStructure, 'defaults')
                mainStructure.defaults = CombineStructures(mainStructure.defaults, appendStructure.defaults);
            else
                mainStructure.defaults = appendStructure.defaults;
            end
        else
            mainStructure.(extraVarNames{extraVarNameInd}) = appendStructure.(extraVarNames{extraVarNameInd});
        end
    end
end

combinedStructure = mainStructure;