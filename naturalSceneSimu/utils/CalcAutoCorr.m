function AC = CalcAutoCorr(input)
    %returns a cell array where each column is the autocorrelation of its
    %corresponding column in resp
    
    nLags = 20;
    AC.numData = nLags + 1;
    AC.numEpochs = size(input,2);
    AC.numFlies = size(input,3);
    
    AC.aCorr = zeros(AC.numData,AC.numEpochs,AC.numFlies);
    
    for ii = 1:AC.numEpochs
        for jj = 1:AC.numFlies
            AC.aCorr(:,ii,jj,1) = autocorr(input(:,ii,jj,1),nLags);
            AC.aCorr(:,ii,jj,2) = autocorr(input(:,ii,jj,2),nLags);
        end
    end
end