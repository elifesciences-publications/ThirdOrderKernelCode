function sepMat = SeparateTraces(respMat,numSep)
    sepMat = zeros([size(respMat,1) size(respMat,2) size(respMat,3)/numSep size(respMat,4) size(respMat,5) numSep]);
    
    for ss = 1:numSep
        sepMat(:,:,:,:,:,ss) = respMat(:,:,ss:numSep:end,:,:);
    end
end