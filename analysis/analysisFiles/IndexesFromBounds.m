function [indexes, indexesCell] = IndexesFromBounds(bounds)
% Takes in bounds, spits out appropriate indexes
indexes = [];
for i = 1:size(bounds, 2)
    indexes = [indexes; [ceil(bounds(1, i)):floor(bounds(2, i))]'];
    indexesCell{i} = [ceil(bounds(1, i)):floor(bounds(2, i))]';
end

end