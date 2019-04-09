function CI = snipMatCombineInput(input,dim,combType)
    %returns a cell array of epochs where rows: time, columns: flies,
    %3rd dim is dx and dy    

    %determine how to combine from user input. If there isn't user input
    %default to using the mean.
    if nargin < 3 || isempty(combType)
        combType = 'mean';
    end
    
    if nargin < 2 || isempty(dim)
        dim = 1;
    end
    
    if isa(combType,'function_handle')
        combFunc = combType;
    else %string in
        switch combType
            case 'max'
                combFunc = @(input,dim) max(input,[],dim);
            case 'sum'
                combFunc = @(input,dim) sum(input,dim)/60;
            otherwise
                combFunc = str2func(combType);
        end
    end
    
    CI.numData = size(input{1},1);
    CI.numEpochs = size(input,1);
    CI.numFlies = size(input,2);
  
    switch dim
        case 'epochs'
            for inputCol = 1:size(input,2)
                reorganized = cat(4,input{:,inputCol});
                CI.comb{1,inputCol} = combFunc(reorganized,4);
                CI.std{1,inputCol} = std(reorganized,[],4);
                CI.sem{1,inputCol} = CI.std{1,inputCol}/sqrt(size(reorganized,4));
            end
        case 'flies'
            for inputRow = 1:size(input,1)
                reorganized = cat(4,input{inputRow,:});
                CI.comb{inputRow,1} = combFunc(reorganized,4);
                CI.std{inputRow,1} = std(reorganized,[],4);
                CI.sem{inputRow,1} = CI.std{inputRow,1}/sqrt(size(reorganized,4));
            end
        case 'trials'
            CI.comb = cellfun(@(x) combFunc(x,2),input,'UniformOutput',false);
            CI.std = cellfun(@(x) std(x,[],2),input,'UniformOutput',false);
            sampleSize = size(input{1},2);
            CI.sem = cellfun(@(x) x/sqrt(sampleSize),CI.std,'UniformOutput',false);
        case 'time'
            CI.comb = cellfun(@(x) combFunc(x,1),input,'UniformOutput',false);
            CI.std = cellfun(@(x) std(x,[],1),input,'UniformOutput',false);
            sampleSize = size(input{1},1);
            CI.sem = cellfun(@(x) x/sqrt(sampleSize),CI.std,'UniformOutput',false);            
    end
    
    % separate turn and walk for ease of plotting in the analysis file
    CI.turn = cellfun(@(x) x(:,:,1),CI.comb,'UniformOutput',false);
    CI.stdTurn = cellfun(@(x) x(:,:,1),CI.std,'UniformOutput',false);
    CI.semTurn = cellfun(@(x) x(:,:,1),CI.sem,'UniformOutput',false);
    
    CI.turn = cellfun(@(x) x(:,:,2),CI.comb,'UniformOutput',false);
    CI.stdTurn = cellfun(@(x) x(:,:,2),CI.std,'UniformOutput',false);
    CI.semTurn = cellfun(@(x) x(:,:,2),CI.sem,'UniformOutput',false);
end