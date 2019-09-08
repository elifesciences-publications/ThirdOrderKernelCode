function SS = OLSGenerationSS_OneDToThreeD(S1,S2,S3)
    maxTau = size(S1,2);
    nT = size(S1,1);
    SS = zeros(nT,maxTau^3);
    maxTauSquared = maxTau ^2;
    SS_twoD = OLSGenerationSS_OneDToTwoD(S1,S2);
    for ii = 1:1:maxTau
        SS(:,((ii - 1) * maxTauSquared + 1 : ii * maxTauSquared)) = bsxfun(@times,S3(:,ii),SS_twoD);
    end
end