function [averageCorrValue, individualCorrTrace] = K2ToGlider_One_CorrType(kernel,corrParam)
% do you want to do a lot of corrType at the same time?
% yes...
nCorrType = length(corrParam);
maxTauSquared = length(kernel);
maxTau = round(nthroot(maxTauSquared,2));
tMax = 50;

indUse = zeros(maxTau,maxTau,nCorrType);
for rr = 1:1:nCorrType
    dt = corrParam{rr}.dt;
    % only use the first one.
    indUse(:,:,rr) = K2ToGlider_Untils_ConstructWindMask(dt(1),tMax,maxTau);
end
% you should plot the trace for 20 of them...
averageCorrValue = zeros(nCorrType,1);
individualCorrTrace = zeros(tMax,nCorrType);
for rr = 1:1:nCorrType
    indUseThis = indUse(:,:,rr);
    indUseThisVec = indUseThis(:);
    numEle = sum(indUseThisVec);
    
    individualCorrTrace(1:numEle,rr) = kernel(indUseThisVec == 1);
    averageCorrValue(rr) = sum(individualCorrTrace(:,rr))/numEle;
end
end