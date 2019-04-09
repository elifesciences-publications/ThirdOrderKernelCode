function analysis = ROIParameterSelectionTest(flyResp,epochs,params,stim,varargin)%(Z,epochsForSelectivity, epochNameForComparison)

epochsForSelectionTest = {'Square Left', 'Square Right'};

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% MakeFigure;

numFlies = length(flyResp);

for ff = 1:numFlies
 
    
    [roiIndsIntFirst, ~, valueMatrix] = SelectResponsiveRois([flyResp{ff};roiSizes{ff}], epochsForSelectionTest, epochs{ff}(:, 1), params);
    
    comparisonEpochNum = ConvertEpochNameToIndex(params,epochNameForComparison);
    
    dirSel = valueMatrix(1, :);
    dpr = valueMatrix(2, :);
    rvals = valueMatrix(3, :);
    pVTtest = valueMatrix(4, :);
    zVals = -norminv(pVTtest);
    mxP = max(pVTtest(roiIndsIntFirst));
    mnZ = min(zVals(roiIndsIntFirst));
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
    
    flyRespInfo.flyResp = flyResp{ff};
    flyRespInfo.epochs = epochs{ff};
    flyRespInfo.params = params;
    flyRespInfo.varargsOrig = varargin;
    
    
    allROIs = any([roiIndsInt; dirSelCrit; dprCrit; rValCrit]);
    
    
    %%
    MakeFigure;
    spW(1) = subplot(1, 2, 1);
    PlotROITraces( flyResp{ff}(:, allROIs), params, epochs{ff}(:, 1), epochsForSelectionTest(1), spW(1), fps )
    
    spW(2) = subplot(1, 4, 4);
    PlotROITraces( flyResp{ff}(:, allROIs), params, epochs{ff}(:, 1), epochsForSelectionTest(2), spW(2), fps )
    
    %% Plot responses to given epoch, say
    lineColors = lines(5);
    spLines(1) = subplot(5, 4, 3);
    dirSelMinVals = linspace(0.15, 4*std(dirSel), 10);
    plotParameterRange(flyRespInfo, dirSelMinVals, dirSel, 'Direction Selectivity Index', 'Index',comparisonEpochNum, epochNameForComparison, lineColors(1, :));
    
    
    spLines(2) = subplot(5, 4, 7);
    dprMinVals = linspace(1, 4*std(dpr), 10);
    plotParameterRange(flyRespInfo, dprMinVals, dpr, 'D-prime between presentations', 'd-prime',comparisonEpochNum,epochNameForComparison, lineColors(2, :));
    
    spLines(3) = subplot(5, 4, 11);
    rValVals = linspace(.1, 1, 10);
    plotParameterRange(flyRespInfo, rValVals, rvals, 'R Values', 'R Value',comparisonEpochNum,epochNameForComparison, lineColors(3, :));
    
    
%     spLines(4) = subplot(5, 4, 15);
%     pVTtMinVals = logspace(log(0.1*mxP), log(1000*mxP), 10);
%     plotParameterRange(flyRespInfo, pVTtMinVals, pVTtest, 't-test', 'p-value',comparisonEpochNum,epochNameForComparison, lineColors(4, :), true, 'semilogx', 'loglog');
%     ln2.LineStyle = 'none';
%     ln2.Marker = '*';
%     hold on;

    spLines(4) = subplot(5, 4, 15);
    zMinVals = linspace(3, 8*std(zVals(~isinf(zVals))), 10);
    plotParameterRange(flyRespInfo, zMinVals, zVals, 't-test', 'z-value',comparisonEpochNum,epochNameForComparison, lineColors(4, :));
    ln2.LineStyle = 'none';
    ln2.Marker = '*';
    hold on;

    flyRespZVals = flyResp{ff}(:, roiIndsInt);
    epochsZVals = epochs{ff}(:, roiIndsInt);
    flyRespsProcessed = GetProcessedTrials(flyRespZVals,epochsZVals,params,varargin{:});

    timeAveraged = ReduceDimension(flyRespsProcessed{end}.snipMat, 'time');
    trialAveraged = ReduceDimension(timeAveraged, 'trials', @nanmean);
    roiAveragedMean = ReduceDimension(trialAveraged,'Rois',@nanmean);
    roiAveragedSem = ReduceDimension(trialAveraged,'Rois',@NanSem);

    PlotErrorPatch(mnZ, [roiAveragedMean{comparisonEpochNum}], [roiAveragedSem{comparisonEpochNum}], [0 0 0]);
    % ax2.XScale = 'log';
%     spLines(4).XScale = 'log';
    hold off
    
    spLines(5) = subplot(5, 4, 19);
    roiSzMinVals = 5:5:50;
    plotParameterRange(flyRespInfo, roiSzMinVals, roiSz, 'ROI size', 'Size (pixels)',comparisonEpochNum,epochNameForComparison, lineColors(5, :), true);
    
    
    mxY = [];
    mnY = [];
    for plts = 1:length(spLines);
        mxY = [mxY max(spLines(plts).Children(end).YData)];
        mnY = [mnY min(spLines(plts).Children(end).YData)];
    end
    mxY = max(mxY);
    mnY = min(mnY);
    yTicks = [mnY (mxY+mnY)/2 mxY];
    for plts = 1:length(spLines);
        spLines(plts).YLim = [mnY mxY];
        spLines(plts).YTick = yTicks;
    end

    mxC = [];
    mnC = [];
    for trcs = 1:length(spW)
        mnC = [mnC min(spW(trcs).Children(end).CData(:))];
        mxC = [mxC max(spW(trcs).Children(end).CData(:))];
    end
    
    for trcs = 1:length(spW)
        axes(spW(trcs));
        colormap(b2r(min(mnC), max(mxC)))
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
end

analysis = [];

function ln2 = plotParameterRange(flyRespInfo, parameterRange, paramValPerRoi, parameterTitle, parameterXLabel, epochNum, epochNameForComparison, lineColor, lt, firstPlot, secondPlot)

if nargin<11
    lt = false;
    firstPlot = 'plot';
    secondPlot = 'semilogy';
end

meanResp = zeros(size(parameterRange)-1);
semResp = zeros(size(meanResp));
numROIs = zeros(size(meanResp));

flyResp = flyRespInfo.flyResp;
epochs = flyRespInfo.epochs;
params = flyRespInfo.params;
varargsOrig = flyRespInfo.varargsOrig;


if lt
    roisPassingLaxestTest = paramValPerRoi < parameterRange(end);
else
    roisPassingLaxestTest = paramValPerRoi > parameterRange(1);
end
paramValPerRoi = paramValPerRoi(roisPassingLaxestTest);
flyRespCycle = flyResp(:, roisPassingLaxestTest);
epochsCycle = epochs(:, roisPassingLaxestTest);
flyRespsProcessed = GetProcessedTrials(flyRespCycle,epochsCycle,params,varargsOrig{:});

timeAveraged = ReduceDimension(flyRespsProcessed{end}.snipMat, 'time');
trialAveraged = ReduceDimension(timeAveraged, 'trials', @nanmean);

for i = 1:length(parameterRange)-1
    disp(i)
    if lt
        roisPassingTest =  paramValPerRoi > parameterRange(i) & paramValPerRoi < parameterRange(i+1);
    else
        roisPassingTest = paramValPerRoi > parameterRange(i) & paramValPerRoi < parameterRange(i+1) ;
    end
    
    numROIs(i) = sum(roisPassingTest);
    roiAveragedMean = ReduceDimension(trialAveraged(:,roisPassingTest),'Rois',@nanmean);
    roiAveragedSem = ReduceDimension(trialAveraged(:,roisPassingTest),'Rois',@NanSem);
    %         if sum(pVTtCrit)< prevSum
    %             %     plotYDirSelCrit = plotYDirSelCrit(:);
    %             xVector = 5*ones(2, length(plotPVTtCrit));
    %             plot(xVector, plotPVTtCrit, 'color', (i)/(length(pVTtMinVals))*lineColors(4, :), 'LineWidth', 10);
    %         end
    %         prevSum = sum(pVTtCrit);
    if ~isempty(roiAveragedMean{epochNum})
        meanResp(i) = roiAveragedMean{ epochNum};
        semResp(i) = roiAveragedSem{ epochNum};
    else
        meanResp(i) = nan;
        semResp(i) = nan;
    end
end
hold on;
if strcmp(firstPlot, 'plot')
    parameterRangePlot = (parameterRange(1:end-1)+parameterRange(2:end))/2;
else
    parameterRangePlot = 10.^((log10(parameterRange(1:end-1))+log10(parameterRange(2:end)))/2);
end
[~, ~, ln2] = plotyy(parameterRangePlot, meanResp, parameterRangePlot, numROIs, firstPlot, secondPlot);
PlotErrorPatch(parameterRangePlot, meanResp, semResp, lineColor);
ln2.LineStyle = 'none';
ln2.Marker = '*';
title(parameterTitle);
xlabel(parameterXLabel);
ylabel(['\Delta F/F ' epochNameForComparison]);