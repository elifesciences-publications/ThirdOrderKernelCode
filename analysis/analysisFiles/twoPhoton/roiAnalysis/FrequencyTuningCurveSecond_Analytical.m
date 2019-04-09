function resp = FrequencyTuningCurveSecond_Analytical(CRF,omegaBank,lambdaBank,dt,tMax,barWidth)
stimHz = 60;
nf = length(omegaBank);
nl = length(lambdaBank);
resp = zeros(nf,nl);

for ff = 1:1:nf
    for ll = 1:1:nl
        omega = omegaBank(ff) * 2 * pi;
        lambda = lambdaBank(ll);
        phi = barWidth / lambda * 2 * pi;
        resp(ff,ll) = sum(1/2 * cos(omega * dt/stimHz +  phi) .* CRF * tMax);
    end
end  
end