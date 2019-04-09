function  covFunctionMean = CovEstimation_SecondOrderKernel(noiseKernel)
maxTauSquared = size(noiseKernel,1); maxTau = round(sqrt(maxTauSquared ));
windFull = true(maxTau,maxTau);
dtBank = -(maxTau - 1):maxTau - 1;
nCov = length(dtBank);
covDiag = cell(nCov,1);

for nn = 1:1:nCov
    dt = dtBank(nn); % diagnal...
    window =  tril(windFull,dt) & triu(windFull,dt);
    % get all the elements out and compute covariance matrix between them.
    eleUsed = noiseKernel(window(:),:);
    covDiag{nn} = cov(eleUsed');
end

covFunctionMatrix = cell(maxTau,1);
for dt = 1:1:maxTau
    dtCell = num2cell(repmat(dt - 1,nCov,1));
    x = cellfun(@(X,dt)CovEstimation_SecondOrderKernel_Utils_CollectOffDiagnalElement(X,dt),covDiag,dtCell,'UniformOutput',false);
    covFunctionMatrix{dt} = cell2mat(x);
end

covFunctionMean = cellfun(@(x) mean(x), covFunctionMatrix);
% covFunctionStd = cellfun(@(x) std(x), covFunctionMatrix);
% covFunctionSize = cellfun(@(x) length(x),covFunctionMatrix);
% covFunctionSem = covFunctionStd./sqrt(covFunctionSize);

end