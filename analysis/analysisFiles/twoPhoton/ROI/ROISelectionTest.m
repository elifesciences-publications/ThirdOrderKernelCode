function ROISelectionTest(Z,epochsForSelectivity, epochNameForComparison)

% MakeFigure;
Z.params.epochsForSelectivity = epochsForSelectivity;
[roiIndsIntFirst, ~, valueMatrix] = ExtractROIsTest(Z);

roiAvgIntensityFilteredNormalized = Z.filtered.roi_avg_intensity_filtered_normalized;

dirSel = valueMatrix(1, :);
dpr = valueMatrix(2, :);
rvals = valueMatrix(3, :);
pVTtest = valueMatrix(4, :);
mxP = max(pVTtest(roiIndsIntFirst));
roiSz = valueMatrix(7, :);

dirSelMin = 0.25;
dirSelCrit = dirSel > dirSelMin;
dprMin = 1;
dprCrit = dpr > dprMin;
rValMin = .5;
rValCrit = rvals > rValMin;
roiIndsInt = roiIndsIntFirst';
roiSzMin = 10;
roiSzCrit = roiSz > roiSzMin;



allROIs = any([roiIndsInt; dirSelCrit; dprCrit; rValCrit]);

% % Look at dirSel
% sp(1) = subplot(2, 4, 1);
% Z.filtered.roi_avg_intensity_filtered_normalized(:, ~dirSelCrit) = 0;
% tp_plotROITraces(Z, allROIs, 'Square Right', sp(1));
% title(sprintf('Direction Selectivity > %d', dirSelMin))
% sp(5) = subplot(2, 4, 5);
% tp_plotROITraces(Z, allROIs, 'Square Left', sp(5));
% Z.filtered.roi_avg_intensity_filtered_normalized = roiAvgIntensityFilteredNormalized;
% 
% % Look at dprimish
% sp(2) = subplot(2, 4, 2);
% Z.filtered.roi_avg_intensity_filtered_normalized(:, ~dprCrit) = 0;
% tp_plotROITraces(Z, allROIs, 'Square Right', sp(2));
% title(sprintf('D-Prime on 2 responses > %d', dprMin))
% sp(6) = subplot(2, 4,6);
% tp_plotROITraces(Z, allROIs, 'Square Left', sp(6));
% Z.filtered.roi_avg_intensity_filtered_normalized = roiAvgIntensityFilteredNormalized;
% 
% % Look at diffHzPower
% sp(3) = subplot(2, 4, 3);
% Z.filtered.roi_avg_intensity_filtered_normalized(:, ~dHPCrit) = 0;
% tp_plotROITraces(Z, allROIs, 'Square Right', sp(3));
% title(sprintf('1Hz power above %d std', dHPmult))
% sp(7) = subplot(2, 4,7);
% tp_plotROITraces(Z, allROIs, 'Square Left', sp(7));
% Z.filtered.roi_avg_intensity_filtered_normalized = roiAvgIntensityFilteredNormalized;
% 
% % Look at pVals
% sp(4) = subplot(2, 4, 4);
% Z.filtered.roi_avg_intensity_filtered_normalized(:, ~roiIndsInt) = 0;
% tp_plotROITraces(Z, allROIs, 'Square Right',sp(4));
% title(sprintf('t-test max p = %d', mxP))
% sp(8) = subplot(2, 4,8);
% tp_plotROITraces(Z, allROIs, 'Square Left', sp(8));
% Z.filtered.roi_avg_intensity_filtered_normalized = roiAvgIntensityFilteredNormalized;
% 
% cLims = [];
% for i = 1:length(sp)
%     spImg = findobj(sp(i), 'Type', 'Image');
%     if ~isempty(spImg)
%         cLims = [cLims [min(spImg.CData(:)) max(spImg.CData(:))]'];
%     end
% end
% 
% for i = 1:length(sp)
%     axes(sp(i)); 
%     minC = min(cLims(1, :));
%     maxC = max(cLims(2, :));
%     colormap(b2r(minC, maxC));
% end

%%
MakeFigure
spW(1) = subplot(1, 2, 1);
tp_plotROITraces(Z, allROIs, epochsForSelectivity{1}, spW(1));

spW(2) = subplot(1, 4, 4);
tp_plotROITraces(Z, allROIs, epochsForSelectivity{2}, spW(2));


% cLims = [];
% for i = 1:length(spW)
%     spImg = findobj(spW(i), 'Type', 'Image');
%     if ~isempty(spImg)
%         cLims = [cLims [min(spImg.CData(:)) max(spImg.CData(:))]'];
%     end
% end
% 
% for i = 1:length(spW)
%     axes(spW(i)); 
%     minC = min(cLims(1, :));
%     maxC = max(cLims(2, :));
%     colormap(b2r(minC, maxC));
% end
%% Plot responses to given epoch, say
    lineColors = lines(5);
spLines(1) = subplot(5, 4, 3);
 dirSelMinVals = linspace(0.15, 4*std(dirSel), 10);
  plotParameterRange(Z, dirSelMinVals, dirSel, 'Direction Selectivity Index', 'Index',epochNameForComparison, lineColors(1, :))


spLines(2) = subplot(5, 4, 7);
dprMinVals = linspace(1, 4*std(dpr), 10);
plotParameterRange(Z, dprMinVals, dpr, 'D-prime between presentations', 'd-prime',epochNameForComparison, lineColors(2, :))

spLines(3) = subplot(5, 4, 11);
rValVals = linspace(.1, 1, 10);
plotParameterRange(Z, rValVals, rvals, 'R Values', 'R Value',epochNameForComparison, lineColors(3, :))


spLines(4) = subplot(5, 4, 15);
    pVTtMinVals = logspace(log(0.1*mxP), log(1000*mxP), 10);
     plotParameterRange(Z, pVTtMinVals, pVTtest, 't-test', 'p-value',epochNameForComparison, lineColors(4, :), true, 'semilogx', 'loglog')
ln2.LineStyle = 'none';
    ln2.Marker = '*';
hold on;
Z.ROI.roiIndsOfInterest = roiIndsInt;
Z = averageEpochResponseAnalysis(Z);

 epochNum = EpochNumsFromName(epochNameForComparison, {Z.stimulus.params.epochName});
meanResp = nanmean(nanmean(Z.averageEpochResponseAnalysis.dFFEpochValues(:, :, epochNum), 2));
semResp = nanstd(nanmean(Z.averageEpochResponseAnalysis.dFFEpochValues(:, :, epochNum), 2))/sqrt(sum(roiIndsInt));
PlotErrorPatch(mxP, meanResp, semResp, [0 0 0]);
% ax2.XScale = 'log';
spLines(4).XScale = 'log';
hold off

spLines(5) = subplot(5, 4, 19);
roiSzMinVals = 5:5:50;
plotParameterRange(Z, roiSzMinVals, roiSz, 'ROI size', 'Size (pixels)',epochNameForComparison, lineColors(5, :), true)

    
    mxY = [];
    mnY = [];
    for plts = 1:length(spLines);
        mxY = [mxY max(spLines(plts).Children(end-1).YData)];
        mnY = [mnY min(spLines(plts).Children(end-1).YData)];
    end
    mxY = max(mxY);
    mnY = min(mnY);
    yTicks = [mnY (mxY+mnY)/2 mxY];
    for plts = 1:length(spLines);
        spLines(plts).YLim = [mnY mxY];
        spLines(plts).YTick = yTicks;
    end
%%
dirSel(allROIs==0) = [];
dpr(allROIs==0) = [];
rvals(allROIs==0) = [];
roiIndsInt(allROIs==0) = [];
pVTtest(allROIs==0) = [];
%%
    lineColors = lines(5);
for i = 1:length(spW)
    axes(spW(i)); hold on
    % dirSelMin = 0.25;
    % dirSelCrit = dirSel > dirSelMin;
    % dprMin = 1;
    % dprCrit = dpr > dprMin;
    % dHPmult = 1;
    % dHPCrit = dHP > dHPmult*std(dHP);
    % roiIndsInt = roiIndsInt';
    start = 0.25;
    spacing = 0.25;
    
    dirSelMinVals = linspace(0.15, 3*std(dirSel));
    for i = 1:length(dirSelMinVals)
        dirSelCrit = dirSel > dirSelMinVals(i);
        plotYDirSelCrit = [find(dirSelCrit)-0.5; find(dirSelCrit)+0.5];
        %     plotYDirSelCrit = plotYDirSelCrit(:);
        xVector = start*ones(2, length(plotYDirSelCrit));
        plot(xVector, plotYDirSelCrit, 'color', (length(dirSelMinVals) - i)/(length(dirSelMinVals))*lineColors(1, :), 'LineWidth', 10);
    end
    
    dprMinVals = linspace(1, 3*std(dpr));
    for i = 1:length(dprMinVals)
        dprCrit = dpr > dprMinVals(i);
        plotYDprCrit = [find(dprCrit)-0.5; find(dprCrit)+0.5];
        %     plotYDirSelCrit = plotYDirSelCrit(:);
        xVector = (start+spacing)*ones(2, length(plotYDprCrit));
        plot(xVector, plotYDprCrit, 'color', (length(dprMinVals) - i)/(length(dprMinVals))*lineColors(2, :), 'LineWidth', 10);
    end
    % plotYDprCrit = [find(dprCrit)-0.5; find(dprCrit)+0.5];
    % plotYDprCrit = plotYDprCrit(:);
    
    rValVals = linspace(.1, 3*std(rvals));
    for i = 1:length(rValVals)
        rValCrit = rvals > rValVals(i)*std(rvals);
        plotYDhpCrit = [find(rValCrit)-0.5; find(rValCrit)+0.5];
        %     plotYDirSelCrit = plotYDirSelCrit(:);
        xVector = (start+2*spacing)*ones(2, length(plotYDhpCrit));
        plot(xVector, plotYDhpCrit, 'color', (length(rValVals) - i)/(length(rValVals))*lineColors(3, :), 'LineWidth', 10);
    end
    % plotYDHPCrit = [find(dHPCrit)-0.5; find(dHPCrit)+0.5];
    % plotYDHPCrit = plotYDHPCrit(:);
    
    prevSum = length(pVTtest);
    pVTtMinVals = logspace(log(0.1*mxP), log(1000*mxP));
    for i = length(pVTtMinVals):-1:1
        pVTtCrit = pVTtest < pVTtMinVals(i);
        plotPVTtCrit = [find(pVTtCrit)-0.5; find(pVTtCrit)+0.5];
        if sum(pVTtCrit)< prevSum
            %     plotYDirSelCrit = plotYDirSelCrit(:);
            xVector = (start+3*spacing)*ones(2, length(plotPVTtCrit));
            plot(xVector, plotPVTtCrit, 'color', (i)/(length(pVTtMinVals))*lineColors(4, :), 'LineWidth', 10);
        end
        prevSum = sum(pVTtCrit);
    end
    
    plotYRoiIndsInt = [find(roiIndsInt)-0.5; find(roiIndsInt)+0.5];
    xVector = (start+4*spacing)*ones(2, length(plotYRoiIndsInt));
    plot(xVector, plotYRoiIndsInt, 'color', lineColors(4, :), 'LineWidth', 10);
    
    roiSzMinVals = 5:40;
    for i = 1:length(roiSzMinVals)
        roiSzCrit = roiSz > roiSzMinVals(i);
        plotYRoiSzCrit = [find(roiSzCrit)-0.5; find(roiSzCrit)+0.5];
        %     plotYDirSelCrit = plotYDirSelCrit(:);
        xVector = (start+5*spacing)*ones(2, length(plotYRoiSzCrit));
        plot(xVector, plotYRoiSzCrit, 'color', (length(roiSzMinVals) - i)/(length(roiSzMinVals))*lineColors(5, :), 'LineWidth', 10);
    end
    
    
end

function ln2 = plotParameterRange(Z, parameterRange, paramValPerRoi, parameterTitle, parameterXLabel,epochNameForComparison, lineColor, lt, firstPlot, secondPlot)

if nargin<10
    lt = false;
    firstPlot = 'plot';
    secondPlot = 'semilogy';
end

meanResp = zeros(size(parameterRange));
 semResp = zeros(size(parameterRange));
 numROIs = zeros(size(parameterRange));
 
 epochNum = EpochNumsFromName(epochNameForComparison, {Z.stimulus.params.epochName});
 for i = length(parameterRange):-1:1
     disp(i)
     if lt
         roisPassingTest = paramValPerRoi < parameterRange(i);
     else
         roisPassingTest = paramValPerRoi > parameterRange(i);
     end
     Z.ROI.roiIndsOfInterest = roisPassingTest;
        numROIs(i) = sum(roisPassingTest);
     Z = averageEpochResponseAnalysis(Z);
     %         if sum(pVTtCrit)< prevSum
     %             %     plotYDirSelCrit = plotYDirSelCrit(:);
     %             xVector = 5*ones(2, length(plotPVTtCrit));
     %             plot(xVector, plotPVTtCrit, 'color', (i)/(length(pVTtMinVals))*lineColors(4, :), 'LineWidth', 10);
     %         end
     %         prevSum = sum(pVTtCrit);
     if ~isempty(Z.averageEpochResponseAnalysis.dFFEpochValues) && ~size(Z.averageEpochResponseAnalysis.dFFEpochValues, 1) ~= sum(roisPassingTest);
         meanResp(i) = nanmean(nanmean(Z.averageEpochResponseAnalysis.dFFEpochValues(:, :, epochNum), 2));
         semResp(i) = nanstd(nanmean(Z.averageEpochResponseAnalysis.dFFEpochValues(:, :, epochNum), 2))/sqrt(sum(roisPassingTest));
     else
         meanResp(i) = nan;
         semResp(i) = nan;
     end
 end
    hold on;
    [~, ~, ln2] = plotyy(parameterRange, meanResp, parameterRange, numROIs, firstPlot, secondPlot);
 PlotErrorPatch(parameterRange, meanResp, semResp, lineColor);
    ln2.LineStyle = 'none';
    ln2.Marker = '*';
    title(parameterTitle);
    xlabel(parameterXLabel);
    ylabel(['\Delta F/F ' epochNameForComparison]);