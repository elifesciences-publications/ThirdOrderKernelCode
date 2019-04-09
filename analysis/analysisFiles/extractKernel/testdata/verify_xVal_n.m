close all
clear all

%% Verify cross-validation script

% params
order = 2;
whichOrder = ( [1:1:3]  == order );
maxTau = 5;
inVar = 1;
noiseVar = 1;
N = 3;

% First check: are the predicted R2 values what they should be?
numTimes = 5;
for q = 1:numTimes
    noiseVar = noiseVar * 10;
    testData = testData_fun(whichOrder,maxTau,'noiseVar',noiseVar,'inVar',inVar,'N',N,'dist',2,'afterNoise',1, ...
        'deMeanStim',1);
    trueKernel = testData.filters{order} ;
    R(q) = xVal_n(order,N,'testData',testData,'inKernel',trueKernel,'maxTau',maxTau,'removeOutliers',0);
    
    % Analytically predicted
    filtMagNorm = trueKernel(:)'*trueKernel(:);
    numerator = sqrt(inVar*filtMagNorm*4/N); % factor of two for positive and negative,
                                             % factor or two for both ways a 3o kernel can self-correlate
                                             % for some reason this is the
                                             % correct way to pick both for
                                             % 3o and for 2o when I don't
                                             % divide 2o by half. 
%     numerator = sqrt(inVar*filtMagNorm*4/N);
    Rpred_alyt(q) = numerator / sqrt(numerator^2 + noiseVar);
    Rpred_alyt_sq(q) = Rpred_alyt(q)^2;
    
    % Manually predicted
    Rpred_mean = mean(testData.data.resp(:,3:7),2);
    mean_mag = sqrt(Rpred_mean'*Rpred_mean);
    for r = 1:5
        Rpred_mean_manual(q,r) = Rpred_mean'*testData.data.resp(:,2+r) / (mean_mag*sqrt(testData.data.resp(:,2+r)'*testData.data.resp(:,2+r)));
    end
    clear Rpred_mean
    clear mean_mag
end
%%
for q = 1:numTimes
    mean_r_all(q) = mean(R(q).kernel_r);
end;
%%
figure; plot(mean_r_all); hold all; plot(Rpred_alyt);

figure; plot(mean_r_all./Rpred_alyt);
%%
figure; scatter(log(mean_r_all),log(Rpred_alyt));