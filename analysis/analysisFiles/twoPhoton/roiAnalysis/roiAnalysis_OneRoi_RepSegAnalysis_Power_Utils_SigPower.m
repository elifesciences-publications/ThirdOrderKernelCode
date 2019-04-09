function [estimatedPowerSignal,estimatedPowerNoise,V] = roiAnalysis_OneRoi_RepSegAnalysis_Power_Utils_SigPower(respByTrial,respRepByTrialTimeLag,respType)

switch respType
    case 'interp'
        nSeg = size(respByTrial,2);
        
        respPower = nanvar(respByTrial,1,1);
        meanResp = nanmean(respByTrial,2);
        meanRespPower = nanvar(meanResp,1);
        
        % try more trials...
        N = nSeg;
        estimatedPowerSignal = 1/(N - 1) * (N * meanRespPower - mean(respPower));
        estimatedPowerNoise = mean(respPower) - estimatedPowerSignal;
        
        T = size(respRepByTrialTimeLag,1); %
        noise = bsxfun(@minus,respFull ,meanResp);
        % it is impossible to calculate this in non repeated response....
        covNoise = nancov(noise');
        sigNoise = nanmean(covNoise(:));
        meanMeanResp = nanmean(meanResp);
        sigNoiseColum = mean(covNoise,1)';
        % how do you estimate this? response - estimt
        V = 4/N * (1/T^2 * meanResp' * covNoise * meanResp - 2/T * meanMeanResp * (sigNoiseColum') * meanResp + meanMeanResp * sigNoise * meanMeanResp)+...
            1/(N * (N - 1)) * (1/T^2 * trace(covNoise * covNoise) - 2/T * (sigNoiseColum') * sigNoiseColum +sigNoise  * sigNoise  );

    case 'nonInterp'
        nSeg = size(respRepByTrialTimeLag,2);
        respFull = nan(size(respRepByTrialTimeLag));
        
        for ss = 1:1:nSeg
            respFull(respRepByTrialTimeLag(:,ss),ss) = respByTrial{ss};
        end
        respPower = nanvar(respFull,0,1);
        meanResp = nanmean(respFull,2);
        meanRespPower = nanvar(meanResp,0);
        
        % how many trials()
        %         nSample = sum(~isnan(respFull),2);
        %         N =  mean(nSample);
        % try more trials...
        nSample = sum(~isnan(respFull),2); nSample(nSample == 0) = [];
        N =  1/mean(1./nSample);
        estimatedPowerSignal = 1/(N - 1) * (N * meanRespPower - mean(respPower));
        
        estimatedPowerNoise = mean(respPower) - estimatedPowerSignal;
       
        % you can even compute the error bar!
        T = size(respRepByTrialTimeLag,1); %
        noise = bsxfun(@minus,respFull ,meanResp);
        % it is impossible to calculate this in non repeated response....
        covNoise = nancov(noise');
        sigNoise = nanmean(covNoise(:));
        meanMeanResp = nanmean(meanResp);
        sigNoiseColum = mean(covNoise,1)';
        % how do you estimate this? response - estimt
        V = 4/N * (1/T^2 * meanResp' * covNoise * meanResp - 2/T * meanMeanResp * (sigNoiseColum') * meanResp + meanMeanResp * sigNoise * meanMeanResp)+...
            2/(N * (N - 1)) * (1/T^2 * trace(covNoise * covNoise) - 2/T * (sigNoiseColum') * sigNoiseColum +sigNoise  * sigNoise  );
end
end
