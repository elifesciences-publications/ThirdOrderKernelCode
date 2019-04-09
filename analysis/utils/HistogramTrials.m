function outSnipMat = HistogramTrials(inSnipMat,edges)
    outSnipMat = cellfun(@(x)histogramCols(x,edges),inSnipMat,'UniformOutput',false);
end

function counts = histogramCols(inMat,edges)
    numTimepoints = size(inMat,1);
    counts(numTimepoints,size(edges,1),2) = 0;
    counts(:,:,1) = histc(inMat(:,:,1)',edges(:,1))';
    counts(:,:,2) = histc(inMat(:,:,2)',edges(:,2))';
    counts = bsxfun(@rdivide,counts(:,1:end-1,:),sum(counts(:,1:end-1,:),2));
end