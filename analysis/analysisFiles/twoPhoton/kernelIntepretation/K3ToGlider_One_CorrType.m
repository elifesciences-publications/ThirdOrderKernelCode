function [averageCorrValue, individualCorrTrace] = K3ToGlider_One_CorrType(kernel,corrParam, varargin)
% do you want to do a lot of corrType at the same time?
% yes...
nCorrType = length(corrParam);
maxTauCubed = length(kernel);
maxTau = round(nthroot(maxTauCubed,3));
tMax = 32;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

indUse = zeros(maxTau,maxTau,maxTau,nCorrType);
for rr = 1:1:nCorrType
    dt = corrParam{rr}.dt;
    indUse(:,:,:,rr) =  K3ToGlider_Untils_ConstructWindMask(dt(1),dt(2) ,tMax,maxTau);
end
% you should plot the trace for 20 of them...
averageCorrValue = zeros(nCorrType,1);
individualCorrTrace = zeros(tMax,nCorrType);
for rr = 1:1:nCorrType
    indUseThis = indUse(:,:,:,rr);
    indUseThisVec = indUseThis(:);
    numEle = sum( indUseThisVec);
    
    individualCorrTrace(1:numEle,rr) = kernel(indUseThisVec == 1);
    averageCorrValue(rr) = sum(individualCorrTrace(:,rr))/numEle;
end
end