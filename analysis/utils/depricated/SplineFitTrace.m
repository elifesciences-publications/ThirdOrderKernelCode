
D.analysis.splineFit.traceFit = zeros(length(dataX)*fitRes,size(D.analysis.pTraces,2),size(D.analysis.pTraces,3),size(D.analysis.pTraces,4),size(D.analysis.pTraces,5));
D.analysis.splineFit.traceFitError = zeros(length(dataX)*fitRes,size(D.analysis.pTraces,2),size(D.analysis.pTraces,3),size(D.analysis.pTraces,4),size(D.analysis.pTraces,5));

for ii = 1:numSep
    for tt = 1:2 % do both walk and turn
        fitX = linspace(dataX(1),dataX(end),length(dataX)*fitRes)';
        D.analysis.splineFit.traceFit(:,ii,tt) = interp1(dataX,traces(:,:,:,tt,ii),fitX,'interp');
    end

    % find the maximum of turning fit and minimum of walking fit
    [~,D.analysis.splineFit.turnMax(ii)] = max(D.analysis.splineFit.traceFit(:,ii,1));
    [~,D.analysis.splineFit.walkMin(ii)] = min(D.analysis.splineFit.traceFit(:,ii,2));
end