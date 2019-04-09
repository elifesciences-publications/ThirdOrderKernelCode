function meanResp = FrequencyTuningCurveSecond(kernel,omegaBank,lambdaBank,barWidth)
% This is just near by kernels. 
T = 1e+4; % points, not time. calculate how many points should you calculate.
T_transient = 100;
nOmega = length(omegaBank);
nLambda = length(lambdaBank);
nBarUse = 2;
% response;
resp = zeros(T,nOmega,nLambda);
stimMat = zeros(T,nBarUse,nOmega,nLambda);
meanResp = zeros(1,nOmega,nLambda);
for jj = 1:1:nLambda
    for ii = 1:1:nOmega
        lambda = lambdaBank(jj);
        omega = omegaBank(ii);
        
        if omega == 0
            % there are two ways to do the omega is zero.
            % analytical way.
            cKernel = sum(kernel(:));
            cSinCos = 1/2 * cos(2 * pi * barWidth/lambda);
            meanResp(:,ii,jj) = cSinCos * cKernel; 
            
            % simulation. 
            % integration of kernel 
        else
            %     omega = 1;
            xt = SineWaveGeneration_Juyue(lambda,omega,T,nBarUse,barWidth);
            % try the first order kernel.
            % the unit of the kernel should be taken into acount, however, for the
            % calculation of stimulus, it cancels out.
            % did holly cancel that in his stimulus?
            resp(:,ii,jj) = ARMA2D_Pred_Stim(xt(:,1),xt(:,2),kernel);
            stimMat(:,:,ii,jj) = xt;
            resp(1:T_transient,ii,jj) = 0;
            % for different omegas, to make sure that you are integrating over period.
            
            % calculate reasonable calculating points.
            T_period = 1/abs(omega) * 60; % simulation on time...% in second
            % get the longest long you have, from T_Transient
            nPeriod = floor((T - T_transient)/T_period);
            % try to make sure that after the thing, you could
            inteTime = T_transient + 1 : T_transient + nPeriod * T_period;
            meanResp(:,ii,jj) = mean(resp(inteTime,ii,jj),1);
        end
    end
end
meanResp = squeeze(meanResp);
end