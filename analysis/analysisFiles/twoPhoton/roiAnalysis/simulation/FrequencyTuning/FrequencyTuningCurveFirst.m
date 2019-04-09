function [meanResp,respLinear,respNonLinear,stimMat] = FrequencyTuningCurveFirst(kernel,doLN,poly2Coe,lookUpTable,softRectificationCoe,LNType,nBarUse,omegaBank,lambdaBank,contrastBank,barWidth)

% this is the largest number.
T_max = 1e+3; % T is the total length of the stimulus, not the second... you have to makesure that you are calculating the right length... T = 1e+3 would be a
stimHz = 60;
T_transient_max = 100;% least time of T_trasient subtracted from the trace.
% you should make sure the T_transient is just one period.
nContrast = length(contrastBank);
nOmega = length(omegaBank);
nLambda = length(lambdaBank);
% response;
firstResp = zeros(T_max,nBarUse,nOmega,nLambda,nContrast);
firstRespSum = zeros(T_max,1,nOmega,nLambda,nContrast);
stimMat = zeros(T_max,nBarUse,nOmega,nLambda,nContrast);
T_simu = zeros(nOmega,1);
T_trans = zeros(nOmega,1); % used for average.
for cc = 1:1:nContrast
    for jj = 1:1:nLambda
        for ii = 1:1:nOmega
            contrast = contrastBank(cc);
            omega = omegaBank(ii);
            lambda = lambdaBank(jj);
            % compute the right length for it.
            
            T_period = abs(1/omega * stimHz); % it might not be a good number...
            
            nPeriod = floor(T_max/T_period); % in second.
            T_simu(ii) = round(nPeriod * T_period);
            
            nPeriod_transient = ceil(T_transient_max/T_period);
            T_trans(ii) = round(nPeriod_transient * T_period);
            
            xt = SineWaveGeneration_Juyue(lambda, omega, contrast, T_max, nBarUse, barWidth);
           
            for q = 1:1:nBarUse
                [firstResp(:,q,ii,jj,cc)] = ARMA1D_Pred_Stim(xt(:,q),kernel(:,q));
            end
            stimMat(:,:,ii,jj,cc) = xt;
            % instead of calculating the mean response, calculate the power...
            firstRespSum(:,1,ii,jj,cc) = sum(firstResp(:,:,ii,jj,cc),2);
            
        end
    end
end
if doLN
    % there are three ways to do this nonlinearity.
    switch LNType
        case 'rectification'
            respRec = MyRectification(firstRespSum);
            respNonLinear = squeeze(respRec);
        case 'square'
            respSqu = firstRespSum.^2;
            respNonLinear = squeeze(respSqu);
        case 'coe'
            respCoe = MyLN_Coe(firstRespSum,poly2Coe,lookUpTable);
            respNonLinear = squeeze(respCoe);
        case 'nonp'
            respNonParametric = MyLN_LookUpTable(firstRespSum,lookUpTable);
            respNonLinear = squeeze(respNonParametric);
        case 'softRectification'
            respSoftRec = MyLN_SoftRectification(firstRespSum,softRectificationCoe);
            respNonLinear =  squeeze(respSoftRec);
    end
else
    respNonLinear = squeeze(firstRespSum);
end

respLinear = squeeze(firstRespSum);
% when you are calculating the mean response. do it for different omega.
meanResp = zeros(nOmega,nLambda,nContrast);
for ii = 1:1:nOmega
    respNonLinearThis = respNonLinear(T_trans(ii) + 1:T_simu(ii),ii,:,:);
    % using squeeze might influence your result.
    % because it would no 
    meanResp(ii,:,:) = squeeze(mean(respNonLinearThis,1))';
end
stimMat = squeeze(stimMat);


end