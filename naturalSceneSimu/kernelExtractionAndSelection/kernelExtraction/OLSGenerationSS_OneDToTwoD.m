function SS = OLSGenerationSS_OneDToTwoD(S1,S2)
    maxTau = size(S1,2);
    nT = size(S1,1);
    SS = zeros(nT,maxTau^2);
    
    for ii = 1:1:maxTau
        SS(:,(ii - 1) * maxTau + 1 : ii * maxTau) = bsxfun(@times,S1,S2(:,ii));
    end

end