function outSnipMat = ReduceDimension(inSnipMat,dimension,func)
% Take the mean along a given dimension.
% Takes in a snipMat and a string specifying the dimension to average
% across: 'flies','epochs','time', or 'trials'. Optionally take in a
% function handle to apply to the dimension. dimension can also be a cell
% array of dimensions to apply in order.

    if nargin < 3
        func = @nanmean;
    end
    
    if iscell(dimension) % If given a cell array of dimensions, apply each
                         % in sequential order by calling ReduceDimension
       tempSnipMat = inSnipMat;
       for i = 1:length(dimension)
           tempSnipMat = ReduceDimension(tempSnipMat,dimension{i},func);
       end
       outSnipMat = tempSnipMat;
    else % If given a single dimension, apply function on that dimension
        
        [numEpochs,numFlies] = size(inSnipMat);
        switch dimension
            case 'flies'
                for i = 1:numEpochs
                    %Take all flys in an epoch, stack them in the 4th
                    %dimension, convert to a matrix (implicitly assume 
                    %submatricies are of equal size) then perform func on them
                    %along the fourth dimension
                    outSnipMat{i,1} = func(cat(4,inSnipMat{i,:}),4);
                end
            case 'epochs'
                for i = 1:numFlies
                    %Take all epochs per fly, stack them in the 4th
                    %dimension, convert to a matrix (implicitly assume 
                    %submatricies are of equal size) then perform func on them
                    %along the fourth dimension
                    outSnipMat{1,i} = func(cat(4,inSnipMat{:,i}),4);
                end
            case 'time'
                outSnipMat = cellfun(@(x)func(x,1),inSnipMat,'UniformOutput',false);
            case 'trials'
                outSnipMat = cellfun(@(x)func(x,2),inSnipMat,'UniformOutput',false);
        end
    end
end