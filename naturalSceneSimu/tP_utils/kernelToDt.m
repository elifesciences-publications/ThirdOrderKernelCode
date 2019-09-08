function sweep = kernelToDt( kernel, maxDt )
% Integrates along off-diagonals of a second-order kernel to predict dt
% sweep. Sums, not averages -- assume includes all power along these
% stripes.

    plotOn = 0;
    maxTau = size(kernel,1);
    sweep = zeros(maxDt*2+1,1);
    for e = 1:maxDt
        bgMask = zeros(maxTau);
        bgMask(e+1:end,1:end-e) = eye(maxTau-e);
        flipMask = bgMask';
        bgVect = bgMask(:);
        flipVect = flipMask(:);
        sweep(maxDt+1+e) = bgVect'*kernel(:);
        sweep(maxDt+1-e) = flipVect'*kernel(:);
    end
    sweep(maxDt+1) = sum(diag(kernel));
    
    if plotOn
        figure;
        plot(sweep);
        title('DT sweep');
    end

end

