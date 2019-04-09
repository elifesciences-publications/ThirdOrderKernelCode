function CF = CLcombineFlies(resp,combType)
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
    
    CF.numEpochs = size(resp.lead,1);
    CF.numFlies = size(resp.lead{1},2);
    CF.numData = size(resp.lead{1},1);
    
    CF.combFly.lead = cell(CF.numEpochs,1);
    CF.stdFly.lead = cell(CF.numEpochs,1);
    CF.semFly.lead = cell(CF.numEpochs,1);
    
    CF.combFly.yoke = cell(CF.numEpochs,1);
    CF.stdFly.yoke = cell(CF.numEpochs,1);
    CF.semFly.yoke = cell(CF.numEpochs,1);
    
    for ii = 1:CF.numEpochs
        CF.combFly.lead{ii} = combFunc(resp.lead{ii},2);
        CF.stdFly.lead{ii} = std(resp.lead{ii},0,2);
        CF.semFly.lead{ii} = CF.stdFly.lead{ii}/sqrt(size(resp.lead{ii},2));
        
        CF.combFly.yoke{ii} = combFunc(resp.yoke{ii},2);
        CF.stdFly.yoke{ii} = std(resp.yoke{ii},0,2);
        CF.semFly.yoke{ii} = CF.stdFly.yoke{ii}/sqrt(size(resp.yoke{ii},2));
    end
end