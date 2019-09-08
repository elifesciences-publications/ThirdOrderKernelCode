function matForm = SnipMatToMatrix(snipMat)
    % tries to convert snipMat to a matrix with diminsions [time,snips,epochs,flies,TW]
    % consider using squish afterwards for easy plotting
    permutedSnipMat = cellfun(@(x)permute(x,[1 2 4 5 3]),snipMat,'UniformOutput',0);
    matForm = cell2mat(permute(permutedSnipMat,[3 4 1 2]));
end