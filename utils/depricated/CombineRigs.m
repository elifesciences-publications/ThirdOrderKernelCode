function CR = combineRigs(input,rig,combType)
    %returns a cell array of epochs where rows: time, columns: ave flies in rig 1:5 3rd
    %dim is dx and dy
    
    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 3 || isempty(combType)
        combType = 'mean';
    end
    
    combFunc = str2func(combType);
    
    CR.numData = size(input,1);
    CR.numFlies = size(input,2);
    
    CR.comb = zeros(size(input,1),5,2);
    CR.std = zeros(size(input,1),5,2);
    CR.sem = zeros(size(input,1),5,2);
    
    for ii = 1:5
        CR.comb(:,ii,:) = combFunc(input(:,rig==ii,:),2);
        CR.std(:,ii,:) = std(input(:,rig==ii,:),0,2);
        CR.sem = CR.std/sqrt(sum(rig==ii));
    end
    
    CR.turn = CR.comb(:,:,1);
    CR.stdTurn = CR.std(:,:,1);
    CR.semTurn = CR.sem(:,:,1);
    
    CR.walk = CR.comb(:,:,2);
    CR.stdWalk = CR.std(:,:,2);
    CR.semWalk = CR.sem(:,:,2);
end