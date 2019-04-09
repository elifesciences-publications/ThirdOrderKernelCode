function NT = normalizeTurn(input,sem,do,epsilon)
    %combine epochs that are just negative versions of one another.
    %starting with the first
    %epoch, assumes the next epoch is the negative duplicate and subtracts
    %it from the previous and divides by 2. returns a cell array of epoch data of the form
    %row time columns: flies, layers: dx vs dy
    %cell array will be size numEpochs/2
    
    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    
    if nargin < 4 || isempty(epsilon)
        epsilon = 0;
    end
    
    if nargin < 3 || isempty(do)
        do = 1;
    end
    
    NT.numData = size(input,1);
    NT.numEpochs = size(input,2);
    NT.numFlies = size(input,3);
    
    NT.comb = input;
    NT.sem = sem;
    
    if do
        NT.sem(:,:,:,1) = bsxfun(@rdivide,NT.sem(:,:,:,1),mean(NT.comb(:,:,:,1),2)+epsilon);
        NT.comb(:,:,:,1) = bsxfun(@rdivide,NT.comb(:,:,:,1),mean(NT.comb(:,:,:,1),2)+epsilon);
    end
    
    NT.do = do;
    
    NT.turn = NT.comb(:,:,:,1);
    NT.walk = NT.comb(:,:,:,2);
    NT.semTurn = NT.sem(:,:,:,1);
    NT.semWalk = NT.sem(:,:,:,2);
end