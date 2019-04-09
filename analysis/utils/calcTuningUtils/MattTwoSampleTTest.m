function p = MattTwoSampleTTest(meanA,semA,nA,meanB,semB,nB)
    %% this code stolen from the statistics toolbox file ttest2

    s2A = (semA*sqrt(nA))^2;
    s2B = (semB*sqrt(nB))^2;
    difference = meanA - meanB;
    
    dfe = nA + nB - 2;
    sPooled = sqrt(((nA-1) .* s2A + (nB-1) .* s2B) ./ dfe);
    se = sPooled .* sqrt(1./nA + 1./nB);
    ratio = difference ./ se;

    p = 2 * tcdf(-abs(ratio),dfe);
end