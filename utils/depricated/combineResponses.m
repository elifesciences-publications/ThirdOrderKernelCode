function CR = combineResponses(resp,combType)
    %returns a cell array of epochs where rows: time, but 1 timepoint as all
    %the data is averaged over time, columns: flies 3rd
    %dim is dx and dy    

    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 2 || isempty(combType)
        combType = 'mean';
    end
    
    combFunc = str2func(combType);
    
    CR.numEpochs = size(resp,1);
    CR.numFlies = size(resp{1},2);
    CR.numData = size(resp{1},1);
    
    CR.combResp = cell(CR.numEpochs,1);
    CR.stdResp = cell(CR.numEpochs,1);
    CR.semResp = cell(CR.numEpochs,1);
    
    for ii = 1:CR.numEpochs
        if ~strcmp(combType,'max')
            CR.combResp{ii} = combFunc(resp{ii},1);
        else
            CR.combResp{ii} = combFunc(resp{ii},[],1);
        end
        if strcmp(combType,'sum')
            CR.combResp{ii} = CR.combResp{ii}/60;
        end
        CR.stdResp{ii} = std(resp{ii},0,1);
        CR.semResp{ii} = CR.stdResp{ii}/sqrt(size(resp{ii},1));
    end
end