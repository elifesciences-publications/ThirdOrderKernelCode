function CR = CLcombineResponses(resp,combType)
    %returns a cell array of epochs where rows: time, but 1 timepoint as all
    %the data is averaged over time, columns: flies 3rd
    %dim is dx and dy    

    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 2 || isempty(combType)
        combType = 'mean';
    end
    
    combFunc = str2func(combType);
    
    CR.numEpochs = size(resp.lead,1);
    CR.numFlies = size(resp.lead{1},2);
    CR.numData = size(resp.lead{1},1);
    
    CR.combResp.lead = cell(CR.numEpochs,1);
    CR.stdResp.lead = cell(CR.numEpochs,1);
    CR.semResp.lead = cell(CR.numEpochs,1);
    
    CR.combResp.yoke = cell(CR.numEpochs,1);
    CR.stdResp.yoke = cell(CR.numEpochs,1);
    CR.semResp.yoke = cell(CR.numEpochs,1);
    
    for ii = 1:CR.numEpochs
        if strcmp(combType,'max')
            CR.combResp.lead{ii} = combFunc(resp.lead{ii},[],1);
        else
            CR.combResp.lead{ii} = combFunc(resp.lead{ii},1);
        end
        if strcmp(combType,'sum')
            CR.combResp.lead{ii} = CR.combResp.lead{ii}/60;
        end
        CR.stdResp.lead{ii} = std(resp.lead{ii},0,1);
        CR.semResp.lead{ii} = CR.stdResp.lead{ii}/sqrt(size(resp.lead{ii},1));
        
        if strcmp(combType,'max')
            CR.combResp.yoke{ii} = combFunc(resp.yoke{ii},[],1);
        else
            CR.combResp.yoke{ii} = combFunc(resp.yoke{ii},1);
        end
        if strcmp(combType,'sum')
            CR.combResp.yoke{ii} = CR.combResp.yoke{ii}/60;
        end
        CR.stdResp.yoke{ii} = std(resp.yoke{ii},0,1);
        CR.semResp.yoke{ii} = CR.stdResp.yoke{ii}/sqrt(size(resp.yoke{ii},1));
    end
end