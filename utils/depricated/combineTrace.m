function CT = combineTrace(input,dim,combType)
    %returns a cell which contains a 1xnx2 array where is n is the number
    %of flies

    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 3 || isempty(combType)
        combType = 'mean';
    end
    
    if nargin < 2 || isempty(dim)
        dim = 1;
    end
    
    combFunc = str2func(combType);
    
    CT.numData = size(input,1);
    CT.numFlies = size(input,2);
    
    if strcmp(combType,'max')
        CT.comb = combFunc(input,[],dim);
    else
        CT.comb = combFunc(input,dim);
    end
    
    if strcmp(combType,'sum')
        CT.comb = CT.comb/60;
    end
    
    CT.std = std(input,[],dim);
    CT.sem = CT.std/sqrt(size(input,dim));
end