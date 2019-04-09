function CR = normalizeResponses(resp)
    % normalizes individual fly responses to the fly's response to the
    % first epoch, normalizing walking and turning independently.
    
    CR.numEpochs = size(resp,1);
    CR.numFlies = size(resp{1},2);
    CR.numData = size(resp{1},1);
    
    CR.normResp = cell(CR.numEpochs,1);
    CR.stdNorm = cell(CR.numEpochs,1);
    CR.semNorm = cell(CR.numEpochs,1);
    
    normVal = resp{1};
    
    for ii = 1:CR.numEpochs
        CR.normResp{ii} = resp{ii}./normVal;
    end
end