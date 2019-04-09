function CD = CombineDuplicates(input,do,combType)
    %combine epochs that are just negative versions of one another.
    %starting with the first
    %epoch, assumes the next epoch is the negative duplicate and subtracts
    %it from the previous and divides by 2. returns a cell array of epoch data of the form
    %row time columns: flies, layers: dx vs dy
    %cell array will be size numEpochs/2
    
    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 3 || isempty(combType)
        combType = 'mean';
    end
    
    if nargin < 2 || isempty(do)
        do = 1;
    end
    
    if do
        combFunc = str2func(combType);

        CD.numData = size(input,1);
        CD.numEpochs = size(input,2)/2;
        CD.numFlies = size(input,3);

        odds = input(:,1:2:end,:,:);
        evens = input(:,2:2:end,:,:);
        evens(:,:,:,1) = -1*evens(:,:,:,1); % multiply turning by turning by -1 for assymetric combine

        CD.comb = combFunc(cat(5,odds,evens),5);
        CD.turn = CD.comb(:,:,:,1);
        CD.walk = CD.comb(:,:,:,2);
    else
        CD.numData = size(input,1);
        CD.numEpochs = size(input,2);
        CD.numFlies = size(input,3);
        
        CD.comb = input;
        CD.turn = CD.comb(:,:,:,1);
        CD.walk = CD.comb(:,:,:,2);
    end
    
    CD.do = do;
end