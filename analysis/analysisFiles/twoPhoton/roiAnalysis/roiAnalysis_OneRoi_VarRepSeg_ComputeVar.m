function ana = roiAnalysis_OneRoi_VarRepSeg_ComputeVar(respVec,meanVec)
% you do not make that compatible 
% you are going to use var(a,1); unbiased estimation. 
residual = respVec - meanVec; % so strange...
varNoise = var(residual,0); % N,normalized by N-1, to match the covariance.biased estimation.
varMeanResp = var(meanVec,0);
varResp = var(respVec,0); % normal normalizaton....
% MakeFigure;
% mean(residual)
% histogram(residual)
% varNoise = var(residual,1); % N,normalized by N-1, to match the covariance.biased estimation.
% varMeanResp = var(meanVec,1);
% varResp = var(respVec,1); % normal normalizaton....


covMatNoiseMean = cov(residual,meanVec);

sigToNoise = sqrt(varMeanResp/varNoise);
% varExplainable = varMeanResp/varResp;
varExplainable = corr(respVec,meanVec); % change it into r, not r square...to get the negative value....
covMatRR = cov(respVec,meanVec);

ana.varResp = varResp;
ana.varMeanResp = varMeanResp;
ana.varNoise = varNoise;
ana.covNoiseMean = covMatNoiseMean(1,2);
ana.sigToNoise = sigToNoise;
ana.varExplainable = varExplainable;
ana.covRR = covMatRR;
end
