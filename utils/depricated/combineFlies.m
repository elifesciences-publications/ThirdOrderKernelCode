function CF = combineFlies(resp,combType)
    %combines fly data for each epoch returns cell array of each epoch
    %row: time, columns: 1 column of averaged fly data, 3rd dim dx dy
    %also calculates the standard deviation, returns a cell array of matricies 
    %containing a STD and SEM for each data point in the returned matrix
    
    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 2 || isempty(combType)
        combType = 'mean';
    end
    
    combFunc = str2func(combType);
    
    CF.numEpochs = size(resp,1);
    CF.numFlies = size(resp{1},2);
    CF.numData = size(resp{1},1);
    
    CF.combFly = cell(CF.numEpochs,1);
    CF.combReads = cell(CF.numEpochs,1);
    CF.stdFly = cell(CF.numEpochs,1);
    CF.semFly = cell(CF.numEpochs,1);
    
    for ii = 1:CF.numEpochs
        CF.combFly{ii} = combFunc(resp{ii},2);
        
        CF.stdFly{ii} = std(resp{ii},0,2);
        CF.semFly{ii} = CF.stdFly{ii}/sqrt(size(resp{ii},2));
    end
end