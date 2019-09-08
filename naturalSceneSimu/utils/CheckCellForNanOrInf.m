function numNan = CheckCellForNanOrInf(snipMat)
    reshapeSnipMat = snipMat(:);
    columnVect = [];
    
    for ii = 1:length(reshapeSnipMat)
        columnVect = [columnVect; reshapeSnipMat{ii}(:)];
    end
    
    numNan = sum(isnan(columnVect) | isinf(columnVect));
end