function CS = calcSTD(input,aveSize)
    %returns a cell array where each column is the STD over a certain
    %amount of time designated by aveSize. also returns Variance
    if nargin < 2
        aveSize = 60*60;
    end
    
    CS.numData = size(input,1);
    CS.numEpochs = size(input,2);
    CS.numFlies = size(input,3);
    
    CS.varTrace = zeros(size(input));
    
    ff = ones(aveSize,1)/aveSize;
    
    for ii = 1:CS.numEpochs
        for jj = 1:CS.numFlies
            CS.varTrace(:,ii,jj) = filter(ff,1,input(:,ii,jj).^2)-filter(ff,1,input(:,ii,jj)).^2;
            %adjust variance for small N's by making it divided by N-1 instead of N
            CS.varTrace(:,ii,jj) = CS.varTrace(:,ii,jj)*CS.numData/(CS.numData-1);

            CS.stdTrace(:,ii,jj) = sqrt(CS.varTrace(:,ii,jj));
        end
    end
end