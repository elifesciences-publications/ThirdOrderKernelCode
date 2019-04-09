function CI = combineInput(input,dim,combType)
    %returns a cell array of epochs where rows: time, but 1 timepoint as all
    %the data is averaged over time, columns: flies 3rd
    %dim is dx and dy    

    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 3 || isempty(combType)
        combType = 'mean';
    end
    
    if nargin < 2 || isempty(dim)
        dim = 1;
    end
    
    combFunc = str2func(combType);
    
    if strcmp(combType,'max')
        CI.comb = combFunc(input,[],dim);
    else
        CI.comb = combFunc(input,dim);
    end
    
    if strcmp(combType,'sum')
        CI.comb = CI.comb/60;
    end
    
    CI.std = std(input,[],dim);
    CI.sem = CI.std/sqrt(size(input,dim));
    
    % separate turn and walk for ease of plotting in the analysis file
    CI.turn = CI.comb(:,:,:,1);
    CI.stdTurn = CI.std(:,:,:,1);
    CI.semTurn = CI.sem(:,:,:,1);
    
    CI.walk = CI.comb(:,:,:,2);
    CI.stdWalk = CI.std(:,:,:,2);
    CI.semWalk = CI.sem(:,:,:,2);
    
    CI.numData = size(CI.comb,1);
    CI.numEpochs = size(CI.comb,2);
    CI.numFlies = size(CI.comb,3);
end