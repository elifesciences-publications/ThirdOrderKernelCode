function Xout = roiAnalysis_AverageFirstKernel_fbestRelativeTime(timeMat)
    % you need a vector..
    Xinit = timeMat(1,:);
    myNew = @(X)MyEqu(X,timeMat);
    tic
    Xout = fminsearch(myNew,Xinit);
    toc
    
end

