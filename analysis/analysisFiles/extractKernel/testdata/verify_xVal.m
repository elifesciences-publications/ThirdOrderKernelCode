close all
clear all

%% Verify cross-validation script

% params
order = 2;
inVar = 1;
noiseVar = 1;

% First check: are the predicted R2 values what they should be?
numTimes = 3;
for q = 1:numTimes
    noiseVar = noiseVar * 10;
    testData = genTestData(order,'inVar',inVar,'noiseVar',noiseVar);
    trueKernel = testData.trueKernel;
    R(q) = xVal(2,'testData',testData,'inKernel',trueKernel);
    
    % Analytically predicted
    filtMagNorm = trueKernel(:)'*trueKernel(:);
    numerator = sqrt(inVar^2*filtMagNorm);
    Rpred_alyt(q) = numerator / sqrt(numerator^2 + noiseVar);
    Rpred_alyt_sq(q) = Rpred_alyt(q)^2;
    
    % Manually predicted
    Rpred_mean = mean(testData.data.resp(:,3:8),2);
    mean_mag = sqrt(Rpred_mean'*Rpred_mean);
    for r = 1:5
        Rpred_mean_manual(q,r) = Rpred_mean'*testData.data.resp(:,2+r) / (mean_mag*sqrt(testData.data.resp(:,2+r)'*testData.data.resp(:,2+r)));
    end

end


