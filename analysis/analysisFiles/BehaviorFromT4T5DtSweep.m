function out = BehaviorFromT4T5DtSweep(positiveCorr, negativeCorr, progROIs, regROIs, dtVals)




% Preferred will be in relation to the progressive epochs
prefEpochs = positiveCorr.analysis{progROIs(1)}.prefEpochs;
nullEpochs = positiveCorr.analysis{progROIs(1)}.nullEpochs;
prefEpochs = prefEpochs(1:end-1);
selGroupings = [progROIs' regROIs'];

positiveCorr = [positiveCorr.analysis{:}];
negativeCorr = [negativeCorr.analysis{:}];

for i = 1:size(selGroupings, 1)
    respSel1 = positiveCorr(selGroupings(i, 1)).fliesUsed;
    respSel2 = positiveCorr(selGroupings(i, 2)).fliesUsed;
    fliesUsed = intersect(respSel1, respSel2);
    
    indSel1 = 1:length(respSel1);
    usedSel1 = indSel1(ismember(respSel1, fliesUsed));
    indSel2 = 1:length(respSel2);
    usedSel2 = indSel2(ismember(respSel2, fliesUsed));
    
    respSel1 = positiveCorr(selGroupings(i, 1)).respMatDiffIndPlot(prefEpochs, usedSel1);
    respSel2 = positiveCorr(selGroupings(i, 2)).respMatDiffIndPlot(prefEpochs, usedSel2);
    
    posBehCompResp(:, i) = mean(respSel1 - respSel2, 2);
    posBehCompSemResp(:, i) = std(respSel1 - respSel2, [], 2)./sqrt(length(usedSel2));
    
    respSel1 = negativeCorr(selGroupings(i, 1)).fliesUsed;
    respSel2 = negativeCorr(selGroupings(i, 2)).fliesUsed;
    fliesUsed = intersect(respSel1, respSel2);
    
    indSel1 = 1:length(respSel1);
    usedSel1 = indSel1(ismember(respSel1, fliesUsed));
    indSel2 = 1:length(respSel2);
    usedSel2 = indSel2(ismember(respSel2, fliesUsed));
    
    respSel1 = negativeCorr(selGroupings(i, 1)).respMatDiffIndPlot(prefEpochs, usedSel1);
    respSel2 = negativeCorr(selGroupings(i, 2)).respMatDiffIndPlot(prefEpochs, usedSel2);
    
    negBehCompResp(:, i) = mean(respSel1 - respSel2, 2);
    negBehCompSemResp(:, i) = std(respSel1 - respSel2, [], 2)./sqrt(length(usedSel2));
end

% posCorrDiffVals = [positiveCorr.respMatDiffPlot];
% negCorrDiffVals = [negativeCorr.respMatDiffPlot];
% posCorrDiffSemVals = [positiveCorr.respMatDiffSemPlot];
% negCorrDiffSemVals = [negativeCorr.respMatDiffSemPlot];
% 
% % We're assuming progROIs and regROIs are paired here
% % This implements (P_r - P_l) - (R_r - R_l), because DiffVals matrices
% % already have the subtraction included
% posBehCompResp = (posCorrDiffVals(prefEpochs, progROIs)) - (posCorrDiffVals(prefEpochs, regROIs));
% posBehCompSemResp = sqrt(posCorrDiffSemVals(prefEpochs, progROIs).^2 + posCorrDiffSemVals(prefEpochs, regROIs).^2);
% negBehCompResp = (negCorrDiffVals(prefEpochs, progROIs)) - (negCorrDiffVals(prefEpochs, regROIs));
% negBehCompSemResp = sqrt(negCorrDiffSemVals(prefEpochs, progROIs).^2 + negCorrDiffSemVals(prefEpochs, regROIs).^2);

MakeFigure;
PlotXvsY(dtVals',posBehCompResp,'error',posBehCompSemResp, 'color', [1 0 0; 0 0 1; 0 0 0]);
hold on;
PlotXvsY(dtVals',negBehCompResp,'error',negBehCompSemResp, 'color', [1 0 0; 0 0 1; 0 0 0]);
ConfAxis;
legend({'T4', 'T5', 'T4T5'})

out.posResponse = posBehCompResp;
out.posSemResponse = posBehCompSemResp;
out.negResponse = negBehCompResp;
out.negSemResponse = negBehCompSemResp;
out.colLabels = {'T4', 'T5', 'T4T5'};
out.rowLabels = dtVals;
out.description = sprintf(...
['(Prog_right-Prog_left) is done by ROI, and SEM is calculated for the fly\n'...
 'average; same with (Reg_right-Reg_left). The two fly averages are\n'...
 'subtracted and SEMs are calculated in quadrature.']);
end