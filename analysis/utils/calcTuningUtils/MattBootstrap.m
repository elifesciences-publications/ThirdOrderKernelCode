function varargout = MattBootstrap(bootFun,numBoot,varsToResample)

    % numBoot is the number of permutations of the data to construct
    
    % bootFun is a function which takes inputs of the format
    % permuteVars{:}
    % and returns either a scalar, vector, or matrix, always of the same
    % size
    
    % permuteVars will have their columns randomly chosen with replacement
    % staticVars will be passed in as is.
    
    % this program will take each permuteVar, Select from its
    % columns randomly with replacement and generate a new set of
    % permuteVar called sampledInputs
    % with the same dimensions and send it to the bootFun with staticVars.

    numPermuteVars = length(varsToResample);
    sampledInputs = cell(numPermuteVars,1);
    
    % generate resampling indicies using balanced resampling
    sampleList = cell(numPermuteVars,1);
    
    numColumnsVars = zeros(numPermuteVars,1);
    for vv = 1:numPermuteVars
        % number of columns in each input
        numColumnsVars(vv) = size(varsToResample{vv},2);
        
        % generate the numbers 1:numPermuteVars numBoot times in a large
        % column vector
        sampleList{vv} = repmat((1:numColumnsVars(vv))',[numBoot 1]);
        
        % randomly rearrange the indicies of sampleList{vv}
        sampleList{vv} = sampleList{vv}(randperm(numColumnsVars(vv)*numBoot));
        
        % reshape into a matrix [numPermuteVars,numBoot]
        sampleList{vv} = reshape(sampleList{vv},[numColumnsVars(vv) numBoot]);
    end
    
    % initialize bootOut
    bootOut = cell(nargout,1,numBoot);
    
    
    for bb = 1:numBoot
        % sample from each of the inputs
        for vv = 1:numPermuteVars
            % generate a list of columns. This will select from the data with
            % replacement
            sampledInputs{vv} = varsToResample{vv}(:,sampleList{vv}(:,bb));
        end
        
        [bootOut{:,1,bb}] = bootFun(sampledInputs);
    end
    
    varargout = cell(1,nargout);
    
    for no = 1:nargout
        varargout{no} = cell2mat(bootOut(no,1,:));
        CheckNanPercent(varargout{no});
    end
end