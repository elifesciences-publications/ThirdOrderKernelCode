function [ kernel ] = oneD_filter( stimulus,response,maxTau )

    inVar = var(stimulus);
    trialLen = length(stimulus);
    normConst = (trialLen - (maxTau - 1)) * inVar;
    stimulusRoll = rollup(stimulus,maxTau);        
    respCut = response(maxTau:end,:);
    kernel = stimulusRoll * respCut / normConst;
%     kernel = xcorr(response,stimulus,maxTau)/normConst;
%     kernel = kernel(maxTau+1:end-1);

end
