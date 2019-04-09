analysis.GS_T = grabSnipsDiffInter(analysis.OD,D.data.params,varargin{:},'limits',TTlimits);
analysis.CI3_T = combineInput(analysis.GS_T.comb,3);

for tt = 1:sqrt(analysis.CI3_T.numEpochs):analysis.CI3_T.numEpochs
    makeFigure;
    plotXvsY((1:analysis.CI3_T.numData)'/60,analysis.CI3_T.turn(:,tt:tt+sqrt(analysis.CI3_T.numEpochs)-1),xLabel,yLabel,'error',analysis.CI3_T.semTurn(:,tt:tt+sqrt(analysis.CI3_T.numEpochs)-1));
end

for tt = 1:sqrt(analysis.CI3_T.numEpochs):analysis.CI3_T.numEpochs
    makeFigure;
    plotXvsY((1:analysis.CI3_T.numData)'/60,analysis.CI3_T.walk(:,tt:tt+sqrt(analysis.CI3_T.numEpochs)-1),xLabel,yLabel,'error',analysis.CI3_T.semWalk(:,tt:tt+sqrt(analysis.CI3_T.numEpochs)-1));
end