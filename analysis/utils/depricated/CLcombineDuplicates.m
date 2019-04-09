function CD = CLcombineDuplicates(resp,combType)
    %combine epochs that are just negative versions of one another.
    %starting with the first
    %epoch, assumes the next epoch is the negative duplicate and subtracts
    %it from the previous and divides by 2. returns a cell array of epoch data of the form
    %row time columns: flies, layers: dx vs dy
    %cell array will be size numEpochs/2
    
    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 2 || isempty(combType)
        combType = 'mean';
    end
    
    combFunc = str2func(combType);
    
    CD.numEpochs = size(resp.lead,1)/2;
    CD.numFlies = size(resp.lead{1},2);
    
    CD.numData = size(resp.lead{1},1);
    CD.combDup.lead = cell(CD.numEpochs,1);
    CD.combDup.yoke = cell(CD.numEpochs,1);
    
    for ii = 1:2:CD.numEpochs*2
        resp.lead{ii+1}(:,:,1) = -1*resp.lead{ii+1}(:,:,1);
        CD.combDup.lead{(ii+1)/2}(:,:,1) = combFunc(cat(3,resp.lead{ii}(:,:,1),resp.lead{ii+1}(:,:,1)),3);
        CD.combDup.lead{(ii+1)/2}(:,:,2) = combFunc(cat(3,resp.lead{ii}(:,:,2),resp.lead{ii+1}(:,:,2)),3);
        
        resp.yoke{ii+1}(:,:,1) = -1*resp.yoke{ii+1}(:,:,1);
        CD.combDup.yoke{(ii+1)/2}(:,:,1) = combFunc(cat(3,resp.yoke{ii}(:,:,1),resp.yoke{ii+1}(:,:,1)),3);
        CD.combDup.yoke{(ii+1)/2}(:,:,2) = combFunc(cat(3,resp.yoke{ii}(:,:,2),resp.yoke{ii+1}(:,:,2)),3);
    end
end