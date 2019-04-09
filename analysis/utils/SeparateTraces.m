function sepMat = SeparateTraces(respMat,numSep,sepType)
    % respMat should be of the form [time,snips,epochs,ROIs,flies,TW] and
    % this will separate the epochs so its of the form
    % [time,snips,epochs,ROIs,flies,TW,traces]

    sepMat = zeros([size(respMat,1) size(respMat,2) size(respMat,3)/numSep size(respMat,4) size(respMat,5) size(respMat,6) numSep]);
    
    if strcmp(sepType,'interleaved')
        for ss = 1:numSep
            sepMat(:,:,:,:,:,:,ss) = respMat(:,:,ss:numSep:end,:,:,:);
        end
    else % sepType is sequential
        numContiguous = size(sepMat,3);
        for ss = 1:numSep
            epochRangeStart = 1+(ss-1)*numContiguous;
            epochRangeEnd   = ss*numContiguous;
            range = epochRangeStart:epochRangeEnd;
            sepMat(:,:,:,:,:,:,ss) = respMat(:,:,range,:,:,:);
        end
    end
end