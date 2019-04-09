    elseif isfield(allStims(currEpoch),'interTag')
        if currEpoch ~= 1 && currEpoch ~= 2
            newEpoch = floor(2*rand)+1;
        else
            numEpochs = length(allStims);
            interTagMat = zeros(numEpochs,1);
            for ii = 1:length(allStims)
                interTagMat(ii,1) = allStims(ii).interTag;
            end

            interSet = [find(interTagMat==currEpoch); find(interTagMat==0)];
            
            newEpoch = interSet(floor(length(interSet)*rand)+1);
        end