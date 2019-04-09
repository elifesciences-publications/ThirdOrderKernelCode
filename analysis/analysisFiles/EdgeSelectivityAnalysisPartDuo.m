function analysis = EdgeSelectivityAnalysisPartDuo(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
combOpp = 1; % logical for combining symmetic epochs such as left and right
numIgnore = 0; % number of epochs to ignore
numSep = 1; % number of different traces in the paramter file
dataX = [];
labelX = '';
fTitle = '';
flyEyes = [];
epochsForSelectionForFly = {'' ''};
timeShift = 0;
duration = 2000;
fps = 1;
overallCorrelationThresh = 0.1;
esiDsiMax = false;
% Can't instantiate this as empty because plenty of figures will have
% empty names as the default
figureName = 'omgIHopeNoFigureIsEverNamedThis';

% Gotta unwrap the eyes because of how they're put in here
%     params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);

fprintf('Two plots this time\n');
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%     epochNames = {params.epochName};
% Gotta unwrap these because of how they're put in here
flyEyes = cellfun(@(flEye) flEye{1}, flyEyes, 'UniformOutput', false);

if any(cellfun('isempty', flyResp))
    nonResponsiveFlies = cellfun('isempty', flyResp);
    fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
    flyResp(nonResponsiveFlies) = [];
    epochs(nonResponsiveFlies) = [];
    roiMask(nonResponsiveFlies) = [];
else
    nonResponsiveFlies = [];
end

numFlies = length(flyResp);
averagedROIs = cell(1,numFlies);

if numFlies==0
    analysis = [];
    return
end


esiDsiPlot = MakeFigure;

numROIs = zeros(1, numFlies);
% run the algorithm for each fly
    meanMatrixAll = [];
    roiChoicesAll = true(0);
    edgeEsiAll = [ ];
    edgeDsiAll = [ ];
    maxLightEdgeRespAll = [];
    maxDarkEdgeRespAll = [];
    overallCorrAll = [];
    roiSizesAll = [];
    fliesToUse = [];
for selEpochs = 1:size(epochsForSelectivity, 1)
    dsiAll = [];
    selIndAll = [];
    zValsAll = [];
    indsIntAll = true(0);
    edgeDsiAll = [];
    primCorrsAll = [];
    probeCorrAll = [ ];
    maxMeansLocAll = [ ];
    moveOn = true;
    %%
    for ff = 1:numFlies
        fprintf('Fly %d, selectivity %d\n', ff, selEpochs);
        %% Get epoch start times/durations for SelectResponsiveRois function
        numEpochs = length(params{ff});
        epochList = epochs{ff}(:, 1);
        epochStartTimes = cell(numEpochs,1);
        epochDurations = cell(numEpochs,1);
        
        for ee = 1:length(epochStartTimes)
            chosenEpochs = [0; epochList==ee; 0];
            startTimes = find(diff(chosenEpochs)==1);
            endTimes = find(diff(chosenEpochs)==-1)-1;
            
            epochStartTimes{ee} = startTimes;
            epochDurations{ee} = endTimes-startTimes+1;
        end
        
        
        esiThresh = 0.4;
        primCorrIndThresh = 0.4;
        dirSelThresh = 0.4;
        pValThresh = .05;
        
        colonLoc = find(dataPathsOut{ff}==':');
        if length(colonLoc)>1
            dataPathsOut{ff} = dataPathsOut{ff}(1:colonLoc(2)-2);
        end
        [epochsForSelectionForFly, ~, ~] = AdjustEpochsForEye(dataPathsOut{ff},epochsForSelectivity, epochsForIdentification, varargin{:});
        
        [~,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectResponsiveRois(flyResp{ff},roiMask{ff},epochStartTimes,epochDurations, epochsForSelectionForFly(selEpochs, :), params{ff},varargin{:}, 'dataRate', dataRate, 'esiDsiMax', esiDsiMax);
        flyRespRaw{ff} = LoadRawTraces( dataPathsOut{ff}, roiMask{ff}{1});

        if ~any(roiIndsOfInterest)
            roiSizes = valueStruct.roiSizes;
            numROIs(ff) = length(roiSizes);
            continue
        else
            fliesToUse = [fliesToUse ff];
        end
        
       
        
        valuesCell = struct2cell(valueStruct);
        valuesMatrix = cat(1, valuesCell{:});
        
        primCorr = valueStruct.primaryCorrelations;
        valueStruct.secondaryCorrelations;
        dsi = valueStruct.dirSel;
        edgeSelInd = valueStruct.edgeSelectivityIndex;
        pVals = valueStruct.pVals;
        zVals = norminv(pVals);
        edgeDsi = valueStruct.edgeDsi;
        edgeEsi = valueStruct.edgeEsi;
        juyueCorr = valueStruct.juyueCorr;
        maxMeansLoc = valueStruct.maxMeansLoc;
        meanMatrix = valueStruct.meanMatrix;
        maxPrimEdgeResp  = valueStruct.maxPrimEdgeResp;
        maxSecEdgeResp = valueStruct.maxSecEdgeResp;
        overallCorr = valueStruct.overallCorrelations;
        roiSizes = valueStruct.roiSizes;
        numROIs(ff) = length(roiSizes);

 
        
        %             MakeFigure;
        %             title('Distributions')
        %             scatter(selInd,dsi);
        %             xlabel(['Edge Selectivity' epochsForSelectivity{selEpochs, 1} ' - ' epochsForSelectivity{selEpochs, 2}]);
        %             ylabel(['Direction Selectivity' epochsForSelectivity{selEpochs, 3} ' - ' epochsForSelectivity{selEpochs, 4}]);
        dsiAll = [dsiAll dsi];
        selIndAll = [selIndAll edgeSelInd];
        zValsAll = [zValsAll zVals];
        indsIntAll = [indsIntAll pVals < (pValThresh/size(flyResp{ff}, 2))];
        roiChoicesAll = [roiChoicesAll roiIndsOfInterest'];
        primCorrsAll = [primCorrsAll primCorr];
        meanMatrixAll = [meanMatrixAll meanMatrix];
        overallCorrAll = [overallCorrAll overallCorr];
        roiSizesAll = [roiSizesAll roiSizes];
        
        
        edgeEsiAll = [edgeEsiAll edgeEsi];
        edgeDsiAll = [edgeDsiAll edgeDsi];
        probeCorrAll = [probeCorrAll juyueCorr];
        maxMeansLocAll = [maxMeansLocAll maxMeansLoc];
        if any(strfind(lower(epochsForSelectionForFly{selEpochs, 1}), 'light'))
            maxLightEdgeRespAll = [maxLightEdgeRespAll maxPrimEdgeResp];
            maxDarkEdgeRespAll = [maxDarkEdgeRespAll maxSecEdgeResp];
        elseif any(strfind(lower(epochsForSelectionForFly{selEpochs, 1}), 'dark'))
            maxDarkEdgeRespAll = [maxDarkEdgeRespAll maxPrimEdgeResp];
            maxLightEdgeRespAll = [maxLightEdgeRespAll maxSecEdgeResp];
        end
    end
    disp(['We skipped flies ' num2str(find(~ismember(1:numFlies, fliesToUse)))])
    
    if ~moveOn
        figure(esiDsiPlot);
        if strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Left') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'light'))
            scatter(selIndAll(selIndAll>0 & dsiAll>0),dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-esiThresh esiThresh;-esiThresh esiThresh], [-1 -1; 1 1], 'k--');
            plot([-1 -1; 1 1], [-dirSelThresh dirSelThresh;-dirSelThresh dirSelThresh], 'k--');
            scatterAxis = gca;
            [scatterAxis.findobj('Type', 'Scatter').LineWidth] = deal(2);
            plot(selIndAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), dsiAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), 'g*');
        elseif strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Left') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'dark'))
            scatter(-selIndAll(selIndAll>0 & dsiAll>0),dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(-selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-esiThresh esiThresh;-esiThresh esiThresh], [-1 -1; 1 1], 'k--');
            plot([-1 -1; 1 1], [-dirSelThresh dirSelThresh;-dirSelThresh dirSelThresh], 'k--');
            scatterAxis = gca;
            [scatterAxis.findobj('Type', 'Scatter').LineWidth] = deal(2);
            plot(-selIndAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), dsiAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), 'g*');
        elseif strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Right') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'light'))
            scatter(selIndAll(selIndAll>0 & dsiAll>0),-dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), -dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-esiThresh esiThresh;-esiThresh esiThresh], [-1 -1; 1 1], 'k--');
            plot([-1 -1; 1 1], [-dirSelThresh dirSelThresh;-dirSelThresh dirSelThresh], 'k--');
            scatterAxis = gca;
            [scatterAxis.findobj('Type', 'Scatter').LineWidth] = deal(2);
            plot(selIndAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), -dsiAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), 'g*');
        elseif strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Right') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'dark'))
            scatter(-selIndAll(selIndAll>0 & dsiAll>0),-dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(-selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), -dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-esiThresh esiThresh;-esiThresh esiThresh], [-1 -1; 1 1], 'k--');
            plot([-1 -1; 1 1], [-dirSelThresh dirSelThresh;-dirSelThresh dirSelThresh], 'k--');
            scatterAxis = gca;
            [scatterAxis.findobj('Type', 'Scatter').LineWidth] = deal(2);
            plot(-selIndAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), -dsiAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), 'g*');
        end
        %     ConfAxis;
        title('Distributions ESI vs DSI')
        xlabel('Edge Selectivity Light - Dark');
        ylabel('Direction Selectivity Prog - Reg');
        
        MakeFigure;
        scatter(dsiAll,zValsAll);
        hold on;
        scatter(dsiAll(indsIntAll), zValsAll(indsIntAll));
        title('Distributions DSI vs Z')
        xlabel(['DSI ' epochsForSelectionForFly{selEpochs, 1} ' - ' epochsForSelectionForFly{selEpochs, 2}]);
        ylabel(['Z Vals Selectivity ' epochsForSelectionForFly{selEpochs, 1} ' - ' epochsForSelectionForFly{selEpochs, 2}]);
        
        MakeFigure;
        scatter(dsiAll,edgeDsiAll);
        hold on;
        scatter(dsiAll(indsIntAll), edgeDsiAll(indsIntAll));
        title('Distributions DSI vs Edge DSI')
        xlabel(['DSI ' epochsForSelectionForFly{selEpochs, 1} ' - ' epochsForSelectionForFly{selEpochs, 2}]);
        ylabel(['Edge Selectivity Max of Light/Dark Comparison of Edges ' epochsForSelectionForFly{selEpochs, 1} ' - ' epochsForSelectionForFly{selEpochs, 2}]);
    end
    
end
meanMatrixTemp = meanMatrixAll;




roiChoicesAllRep = repmat(roiChoicesAll, 4, 1);

MakeFigure;
meanMatrixAll(meanMatrixTemp>0 & roiChoicesAllRep) = (1+meanMatrixTemp(meanMatrixTemp>0 & roiChoicesAllRep))-1;
meanMatrixAll(meanMatrixTemp<0 & roiChoicesAllRep) = -1./(1+meanMatrixTemp(meanMatrixTemp<0 & roiChoicesAllRep))+1;
meanMatrixAll = reshape(meanMatrixAll(roiChoicesAllRep), [4, sum(roiChoicesAll)]);
subplot(3, 3, 1)
scatter(meanMatrixAll(1, :), meanMatrixAll(2, :));
xlabel('Left Mean');
ylabel('Right Mean');
title('ALL THE DIRECTION SCATTERS')

subplot(3, 3, 4)
scatter(meanMatrixAll(1, :), meanMatrixAll(3, :));
xlabel('Left Mean');
ylabel('Up Mean');

subplot(3, 3, 7)
scatter(meanMatrixAll(1, :), meanMatrixAll(4, :));
xlabel('Left Mean');
ylabel('Down Mean');

subplot(3, 3, 5)
scatter(meanMatrixAll(2, :), meanMatrixAll(3, :));
xlabel('Right Mean');
ylabel('Up Mean');

subplot(3, 3, 8)
scatter(meanMatrixAll(2, :), meanMatrixAll(4, :));
xlabel('Right Mean');
ylabel('Down Mean');

subplot(3, 3, 9)
scatter(meanMatrixAll(3, :), meanMatrixAll(4, :));
xlabel('Up Mean');
ylabel('Down Mean');
analysis = [];

%%
roiSizeThresh = 5;
overallCorrelationThresh = 0.4;
filteringCriteria = overallCorrAll>overallCorrelationThresh & roiSizesAll>roiSizeThresh;

dsi = 0.4;
t4Dsi = dsi;
t5Dsi = dsi;
t4Esi = 0;
t5Esi = -0;
markingCriteriaT4 = filteringCriteria & edgeEsiAll>t4Esi;% & abs(edgeDsiAll)>t4Dsi;
markingCriteriaT5 = filteringCriteria & edgeEsiAll<t5Esi;% & abs(edgeDsiAll)>t5Dsi;




if false
MakeFigure;
sctPltT4 = scatter(maxLightEdgeRespAll(markingCriteriaT4), maxDarkEdgeRespAll(markingCriteriaT4), .1, 'k', '*');
sctPltT4.HitTest = 'off';
hold on;
sctPltT5 = scatter(maxLightEdgeRespAll(markingCriteriaT5), maxDarkEdgeRespAll(markingCriteriaT5), .1, 'r', '*');
sctPltT5.HitTest = 'off';
sctPlt = scatter(maxLightEdgeRespAll(filteringCriteria), maxDarkEdgeRespAll(filteringCriteria), 40, roiSizesAll(filteringCriteria));
sctPlt.ButtonDownFcn = {@ScatterPlotCallback, flyResp(fliesToUse), numROIs(fliesToUse), filteringCriteria, dataPathsOut(fliesToUse), varargin};
title(sprintf('Correlation thresh=%0.2f, ROI size thresh=%0.0f', overallCorrelationThresh, roiSizeThresh));
xlabel('99th Percentile Light Edge Response');
ylabel('99th Percentile Dark Edge Response');

xVecLight = [0 max(maxLightEdgeRespAll)];
yVecLight = (1-esiThresh)/(1+esiThresh)*xVecLight;

yVecDark = [0 max(maxDarkEdgeRespAll)];
xVecDark = (1-esiThresh)/(1+esiThresh)*yVecDark;
hold on;

plot(xVecLight, yVecLight, '--')
plot(xVecDark, yVecDark, '--')
legend({'T4', 'T5', 'Points',  'Light Edge Threshold', 'Dark Edge Threshold'});
ConfAxis
l = gcf;
l.Name = sprintf('MaxResp_C%0.0f_RS%0.0f', 10*overallCorrelationThresh, roiSizeThresh);

MakeFigure;
[~, edgesOverallCorrAll] =histcounts(overallCorrAll);
% histogram(overallCorrAll, edgesOverallCorrAll)
hold on;histogram(overallCorrAll(filteringCriteria), edgesOverallCorrAll);
noCorrFilterT4 = abs(edgeDsiAll)>0.4 & abs(edgeEsiAll)>t4Esi & roiSizesAll>roiSizeThresh;
noCorrFilterT5 = abs(edgeDsiAll)>0.4 & abs(edgeEsiAll)>t5Esi & roiSizesAll>roiSizeThresh;
hold on;histogram(overallCorrAll(noCorrFilterT4), edgesOverallCorrAll);
hold on;histogram(overallCorrAll(noCorrFilterT5), edgesOverallCorrAll);
% hold on;histogram(overallCorrAll(markingCriteriaT4 | markingCriteriaT5), edgesOverallCorrAll);
title(sprintf('Correlation thresh=%0.2f, ROI size thresh=%0.0f, T4 ESI = %0.2f, T5 ESI = %0.2f', overallCorrelationThresh, roiSizeThresh, t4Esi, t5Esi));
xlabel('Correlation Value')
ylabel('Number of ROIs')
% legend({'All Correlations', 'Filter Corr, ROI Size', 'Filter ESI, DSI, ROI Size', 'T4 & T5 correlations'})
legend({'Filter Corr, ROI Size', 'T4 Filt w/o corr', 'T5 Filt w/o corr'})
l = axis;
l(1:2) = [-1 1];
axis(l);
ConfAxis
l = gcf;
l.Name = sprintf('Corr_C%0.0f_RS%0.0f_T4E%0.0f_T5E%0.0f', 10*overallCorrelationThresh, roiSizeThresh, 10*t4Esi, 10*t5Esi);

MakeFigure;
[~, edgesEdgeDsiAll] = histcounts(edgeDsiAll);
% histogram(edgeDsiAll, edgesEdgeDsiAll)
hold on;histogram(edgeDsiAll(filteringCriteria), edgesEdgeDsiAll);
noDsiFilter = overallCorrAll>overallCorrelationThresh & abs(edgeEsiAll)>0.4 & roiSizesAll>roiSizeThresh;
hold on;histogram(edgeDsiAll(noDsiFilter), edgesEdgeDsiAll);
hold on;histogram(edgeDsiAll(markingCriteriaT4 | markingCriteriaT5), edgesEdgeDsiAll);
title(sprintf('Correlation thresh=%0.2f, ROI size thresh=%0.0f, T4 ESI = %0.2f, T5 ESI = %0.2f', overallCorrelationThresh, roiSizeThresh, t4Esi, t5Esi));
xlabel('Edge DSI Value')
ylabel('Number of ROIs')
% legend({'All DSI', 'Filter Corr, ROI Size', 'Filter ESI, Corr, ROI Size', 'T4 & T5 DSI'})
legend({'Filter Corr, ROI Size', 'Filter ESI, Corr, ROI Size', 'T4 & T5 DSI'})
l = axis;
l(1:2) = [-1 1];
axis(l);
ConfAxis
l = gcf;
l.Name = sprintf('DSI_C%0.0f_RS%0.0f_T4E%0.0f_T5E%0.0f', 10*overallCorrelationThresh, roiSizeThresh, 10*t4Esi, 10*t5Esi);

MakeFigure;
[~, edgesEdgeEsiAll] = histcounts(edgeEsiAll);
% histogram(edgeEsiAll, edgesEdgeEsiAll)
hold on;histogram(edgeEsiAll(filteringCriteria), edgesEdgeEsiAll);
noEsiFilter = overallCorrAll>overallCorrelationThresh & abs(edgeDsiAll)>0.4 & roiSizesAll>roiSizeThresh;
hold on;histogram(edgeEsiAll(noEsiFilter), edgesEdgeEsiAll);
hold on;histogram(edgeEsiAll(markingCriteriaT4 | markingCriteriaT5), edgesEdgeEsiAll);
title(sprintf('Correlation thresh=%0.2f, ROI size thresh=%0.0f, T4 ESI = %0.2f, T5 ESI = %0.2f', overallCorrelationThresh, roiSizeThresh, t4Esi, t5Esi));
xlabel('Edge ESI Value')
ylabel('Number of ROIs')
% legend({'All ESI', 'Filter Corr, ROI Size', 'Filter Corr, DSI, ROI Size', 'T4 & T5 ESI'})
legend({'Filter Corr, ROI Size', 'Filter Corr, DSI, ROI Size', 'T4 & T5 ESI'})
l = axis;
l(1:2) = [-1 1];
axis(l);
ConfAxis
l = gcf;
l.Name = sprintf('ESI_C%0.0f_RS%0.0f_T4E%0.0f_T5E%0.0f', 10*overallCorrelationThresh, roiSizeThresh, 10*t4Esi, 10*t5Esi);
end

esiDsiFig = findobj('Type','Figure','Name','esiDsiFig');
if isempty(esiDsiFig)
    esiDsiFig = MakeFigure;
    esiDsiFig.Name='esiDsiFig';
    firstTime = true;
    esiDsiFig.UserData = 1;
else
    figure(esiDsiFig);
    esiDsiFig.UserData = esiDsiFig.UserData+1;
    firstTime = false;
    hold on
end
    
edgeDsiAllAdj = edgeDsiAll;
edgeDsiAllAdj(abs(edgeDsiAllAdj)>1) = sign(edgeDsiAllAdj(abs(edgeDsiAllAdj)>1));
edgeDsiAllAdj = edgeDsiAllAdj(filteringCriteria);

edgeEsiAllAdj = edgeEsiAll;
edgeEsiAllAdj(abs(edgeEsiAllAdj)>1) = sign(edgeEsiAllAdj(abs(edgeEsiAllAdj)>1));
edgeEsiAllAdj = edgeEsiAllAdj(filteringCriteria);

markingCriteriaT4Filt = markingCriteriaT4(filteringCriteria);
markingCriteriaT5Filt = markingCriteriaT5(filteringCriteria);

sctPlot = subplot(5,5,[11:13 16:18 21:23]);
sctPlot.ColorOrderIndex = esiDsiFig.UserData;

overallCorrFlt = overallCorrAll(filteringCriteria);
if firstTime
    r = scatter(edgeDsiAllAdj, edgeEsiAllAdj, 10, overallCorrFlt);
    colormap(b2r(overallCorrelationThresh, 1, 0.4));
%     r = scatter(edgeDsiAllAdj, edgeEsiAllAdj, 10);
%     r.MarkerEdgeColor = [0.5 0.5 0.5];
    r.MarkerFaceColor = r.MarkerEdgeColor;
%     hold on
%     % T4 left
%     m = scatter(edgeDsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj<-0.4), edgeEsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj<-0.4), 10);
%     m.MarkerEdgeColor = [1 0 1];
%     m.MarkerFaceColor = m.MarkerEdgeColor;
%     % T4 right
%     m = scatter(edgeDsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj>0.4), edgeEsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj>0.4), 10);
%     m.MarkerEdgeColor = [1 0 0];
%     m.MarkerFaceColor = m.MarkerEdgeColor;
%     % T5 left
%     m = scatter(edgeDsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj<-0.4), edgeEsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj<-0.4), 10);
%     m.MarkerEdgeColor = [0 1 0];
%     m.MarkerFaceColor = m.MarkerEdgeColor;
%     % T5 right
%     m = scatter(edgeDsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj>0.4), edgeEsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj>0.4), 10);
%     m.MarkerEdgeColor = [0 0 1];
%     m.MarkerFaceColor = m.MarkerEdgeColor;
else
    m = scatter(edgeDsiAllAdj, edgeEsiAllAdj, 20);
    if sum(markingCriteriaT4Filt) > sum(markingCriteriaT5Filt) % using an assumption that T4 cell dendrites will be more T4 than T5... <.<
        m.MarkerEdgeColor = [1 0 0.5];
    else
        m.MarkerEdgeColor = [0 1 1];
    end
    m.MarkerFaceColor = m.MarkerEdgeColor;
    
end
axis([-1 1 -1 1]);
xlabel('DSI');
ylabel('ESI');
hold on

if firstTime
    PlotConstLine(-0.4, 1);
    PlotConstLine(0.3, 1);
    PlotConstLine(-0.4, 2);
    PlotConstLine(0.4, 2);
end
ConfAxis

binSplits = -1:0.1:1;

subplot(5,5,[14 19 24]);
hEsi = histogram(edgeEsiAllAdj, binSplits);%, 'Normalization', 'pdf');
hEsi.Orientation = 'horizontal';
hEsi.Parent.YTickLabel = '';
hold on;


if firstTime
    hEsi.FaceColor = [0.5 0.5 0.5];
    PlotConstLine(t5Esi, 1);
    PlotConstLine(t4Esi, 1);
    for i = 1:length(hEsi.BinEdges)-1
        mnCorrEsi(i) = mean(overallCorrFlt(edgeEsiAllAdj>hEsi.BinEdges(i) & edgeEsiAllAdj<=hEsi.BinEdges(i+1)));
        stdCorrEsi(i) = std(overallCorrFlt(edgeEsiAllAdj>hEsi.BinEdges(i) & edgeEsiAllAdj<=hEsi.BinEdges(i+1)));
    end
    ConfAxis
    subplot(5,5,[15 20 25]);
    bE = hEsi.BinEdges;
    bE = bE(1:end-1);
    bE = bE(~isnan(mnCorrEsi));
    stdCorrEsi = stdCorrEsi(~isnan(mnCorrEsi));
    mnCorrEsi = mnCorrEsi(~isnan(mnCorrEsi));
    errPatchPtsY =  [bE(1:end) bE(end:-1:1)];
    errPatchPtsX = [mnCorrEsi+stdCorrEsi mnCorrEsi(end:-1:1)-stdCorrEsi(end:-1:1)];
    patch(errPatchPtsX, errPatchPtsY, [0 0 .8])
    hold on;
    plot(mnCorrEsi, bE)
    PlotConstLine(t5Esi, 1);
    PlotConstLine(t4Esi, 1);
else
    if sum(markingCriteriaT4Filt) > sum(markingCriteriaT5Filt) % using an assumption that T4 cells will be more T4 than T5... <.<
        hEsi.FaceColor = [1 0 0.5];
    else
        hEsi.FaceColor =  [0 1 1];
    end
end
ConfAxis

subplot(5,5,6:8);
hDsi = histogram(edgeDsiAllAdj, binSplits);%, 'Normalization', 'pdf');
hDsi.Parent.XTickLabel = '';
hold on;

if firstTime
    hDsi.FaceColor = [0.5 0.5 0.5];
    PlotConstLine(t5Dsi, 2);
    PlotConstLine(t4Dsi, 2);
    title(sprintf('Correlation thresh=%0.2f, ROI size thresh=%0.0f', overallCorrelationThresh, roiSizeThresh));
    
    for i = 1:length(hDsi.BinEdges)-1
        mnCorrDsi(i) = mean(overallCorrFlt(edgeDsiAllAdj>hDsi.BinEdges(i) & edgeDsiAllAdj<=hDsi.BinEdges(i+1)));
        stdCorrDsi(i) = std(overallCorrFlt(edgeDsiAllAdj>hDsi.BinEdges(i) & edgeDsiAllAdj<=hDsi.BinEdges(i+1)));
    end
    ConfAxis
    subplot(5,5,1:3);
     bE = hDsi.BinEdges;
    bE = bE(1:end-1);
    bE = bE(~isnan(mnCorrDsi));
    stdCorrDsi = stdCorrDsi(~isnan(mnCorrDsi));
    mnCorrDsi = mnCorrDsi(~isnan(mnCorrDsi));
    PlotXvsY(bE', mnCorrDsi', 'error', stdCorrDsi')
    hold on;
    PlotConstLine(t5Dsi, 2);
    PlotConstLine(t5Dsi, 2);
else
    if sum(markingCriteriaT4Filt) > sum(markingCriteriaT5Filt) % using an assumption that T4 cells will be more T4 than T5... <.<
        hDsi.FaceColor = [1 0 0.5];
    else
        hDsi.FaceColor =  [0 1 1];
    end
end

ConfAxis


% Now let's look at that third probe
edgeRespsInit = cell(1, length(fliesToUse));
edgeRespsRawInit = cell(1, length(fliesToUse));
startInd = 1;
numROIsUsed = numROIs(fliesToUse);
flyRespUsed = flyResp(fliesToUse);
flyRespRawUsed = flyRespRaw(fliesToUse);
epochsUsed = epochs(fliesToUse);
roisActuallyUsedT4 = [];
roisActuallyUsedT5 = [];
roisActuallyUsed = [];
numROIsActuallyUsedT4 = [];
numROIsActuallyUsedT5 = [];
numRepeats = [];
markingCriteriaT4Strict = markingCriteriaT4;% &  edgeEsiAll<=0.3;
markingCriteriaT4FiltStrict = markingCriteriaT4Filt;% & edgeEsiAll(filteringCriteria)<=0.3;
markingCriteriaT4T5 = markingCriteriaT4Strict | markingCriteriaT5;
numFliesUsed = 0;
for ff = 1:length(fliesToUse)
    endInd = startInd + numROIsUsed(ff)-1;
    if any(markingCriteriaT4T5(startInd:endInd))
        splitEpochsFlyT4T5{ff} = GetProcessedTrials(flyRespUsed{ff}(:, markingCriteriaT4T5(startInd:endInd)),epochsUsed{ff}(:, markingCriteriaT4T5(startInd:endInd)),params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);
        splitEpochsRawFlyT4T5{ff} = GetProcessedTrials(flyRespRawUsed{ff}(:, markingCriteriaT4T5(startInd:endInd)),epochsUsed{ff}(:, markingCriteriaT4T5(startInd:endInd)),params{ff},dataRate,dataType,varargin{:},'snipShift', 0, 'duration', []);
        roisActuallyUsedT4 = [roisActuallyUsedT4 (markingCriteriaT4Strict(startInd:endInd) & markingCriteriaT4T5(startInd:endInd))];
        roisActuallyUsedT5 = [roisActuallyUsedT5 (markingCriteriaT5(startInd:endInd) & markingCriteriaT4T5(startInd:endInd))];
        numROIsActuallyUsedT4(ff) = sum(markingCriteriaT4Strict(startInd:endInd));
        numROIsActuallyUsedT5(ff) = sum(markingCriteriaT5(startInd:endInd));

        if ~isempty(splitEpochsFlyT4T5{ff})
            edgeRespsInit{ff} = splitEpochsFlyT4T5{ff}{end}.snipMat(1:4, :);
            edgeRespsRawInit{ff} = splitEpochsRawFlyT4T5{ff}{end}.snipMat(1:4, :);
            numRepeats{ff} = cellfun(@(x) size(x,2), edgeRespsInit{ff});
%             if ~any(numRepeats(:, 1)==3)
%                 edgeRespsInit{ff} = [];
%             end
        end
    end
    if any(filteringCriteria(startInd:endInd))
        numFliesUsed = numFliesUsed+1;
    end
    startInd = endInd+1;
end

stimsWithThirdProbe = cellfun(@(repNum) ~isempty(repNum) && any(repNum(:, 1)==3), numRepeats);
firstFlyWithThirdProbe = find(stimsWithThirdProbe, 1, 'first');
edgeResps = edgeRespsInit(stimsWithThirdProbe);
threshedEdgeResps = cellfun(@(edgeOneResp) cellfun(@(x) percentileThresh(x(:, 3), .99), edgeOneResp), edgeResps, 'UniformOutput', false);
allEdgeThreshedResps = cat(2, threshedEdgeResps{:});

flyEyesUsed = flyEyes(fliesToUse);
leftEyedFlies = strcmp(flyEyesUsed, 'left');
roisWithLeftEye = cellfun(@(flEye, numRoi) repmat(flEye, [1, numRoi]), num2cell(leftEyedFlies), num2cell(numROIsActuallyUsedT4 + numROIsActuallyUsedT5), 'UniformOutput', false);
roisWithLeftEyeAll = [roisWithLeftEye{:}];

combEdgeResp = [edgeRespsRawInit{:}];
combEdgeRespProgRegOrder = combEdgeResp;
combEdgeRespProgRegOrder([1 2], roisWithLeftEyeAll) = combEdgeResp([3 4], roisWithLeftEyeAll);
combEdgeRespProgRegOrder([3 4], roisWithLeftEyeAll) = combEdgeResp([1 2], roisWithLeftEyeAll);
avgEdgeResp = cellfun(@(PL, PD, RL, RD) [mean(PL, 2); mean(PD, 2); mean(RL, 2); mean(RD, 2)], combEdgeRespProgRegOrder(1, :), combEdgeRespProgRegOrder(2, :), combEdgeRespProgRegOrder(3, :), combEdgeRespProgRegOrder(4,:), 'UniformOutput', false);
avgEdgeRespMat = cat(2,avgEdgeResp{:});

roisActuallyUsed(logical(roisActuallyUsedT5))  = 5;
roisActuallyUsed(logical(roisActuallyUsedT4))  = 4;
roisActuallyUsed(~roisActuallyUsed) = [];

MakeFigure;
plot(linspace(0, 48, size(avgEdgeRespMat, 1)), avgEdgeRespMat(:,roisActuallyUsed==4));
hold on;
PlotConstLine(12, 2)
PlotConstLine(24, 2)
PlotConstLine(36, 2)

medVals = nanmedian(avgEdgeRespMat);
for i = 1:length(roisActuallyUsed)
medVals(i) = percentileThresh(avgEdgeRespMat(:, i), .5);
end
rawTrDist = MakeFigure;r = histogram(medVals);
hold on;histogram(medVals(roisActuallyUsed==4),r.BinEdges);
hold on;histogram(medVals(roisActuallyUsed==5),r.BinEdges);
title('Median (baseline) response to average edge presentations')
ylabel('Count')
xlabel('Median raw signal')
legend({'All', 'ESI>0', 'ESI<0'});
text(1500, 200, sprintf('Median for ESI>0 = %0.2f\n Median for ESI<0 = %0.2f', nanmedian(medVals(roisActuallyUsed==4)), nanmedian(medVals(roisActuallyUsed==5))), 'HorizontalAlignment', 'right', 'FontSize', 15);
ConfAxis
rawTrDist.Name = 'T4 and T5 raw baseline';

rawTrDistSmall = MakeFigure;r = histogram(medVals(medVals<300));
hold on;histogram(medVals(roisActuallyUsed==4 & medVals<300),r.BinEdges);
hold on;histogram(medVals(roisActuallyUsed==5 & medVals<300),r.BinEdges);
title('Median (baseline) response to average edge presentations')
ylabel('Count')
xlabel('Median raw signal')
legend({'All', 'ESI>0', 'ESI<0'});
text(200, 50, sprintf('Median for ESI>0 = %0.2f\n Median for ESI<0 = %0.2f', nanmedian(medVals(roisActuallyUsed==4 & medVals<300)), nanmedian(medVals(roisActuallyUsed==5 & medVals<300))), 'HorizontalAlignment', 'right', 'FontSize', 15);
ConfAxis
rawTrDistSmall.Name = 'T4 and T5 raw baseline small vals';

roisWithThreeProbes = false(1, sum(numROIsActuallyUsedT4) + sum(numROIsActuallyUsedT5));
roisWithThreeProbes(sum(numROIsActuallyUsedT4(1:firstFlyWithThirdProbe-1))+sum(numROIsActuallyUsedT5(1:firstFlyWithThirdProbe-1))+1:end) = true;
roisWithThreeProbesT4 = roisWithThreeProbes & roisActuallyUsed==4;
roisWithThreeProbesT5 = roisWithThreeProbes & roisActuallyUsed==5;

for ff = 1:length(stimsWithThirdProbe)
    if stimsWithThirdProbe
        switch flyEyesUsed{ff}
            case 'left'
            case 'right'
        end
    end
end



roisWithLeftEyeThirdProbe = roisWithLeftEye(stimsWithThirdProbe);
roisWithLeftEyeThirdProbe = [roisWithLeftEyeThirdProbe{:}];
% roisWithLeftEyeThirdProbe = roisWithLeftEyeThirdProbe(roisWithThreeProbes);
dsiEdgeThreshedResps = allEdgeThreshedResps;
dsiEdgeThreshedResps([1 2], roisWithLeftEyeThirdProbe) = allEdgeThreshedResps([3 4], roisWithLeftEyeThirdProbe);
dsiEdgeThreshedResps([3 4], roisWithLeftEyeThirdProbe) = allEdgeThreshedResps([1 2], roisWithLeftEyeThirdProbe);


MakeFigure
progEdgeRespThird = mean([dsiEdgeThreshedResps(1, :); dsiEdgeThreshedResps(2, :)]);
regEdgeRespThird = mean([dsiEdgeThreshedResps(3, :); dsiEdgeThreshedResps(4, :)]);

dsiThirdProbe = (regEdgeRespThird-progEdgeRespThird)./(regEdgeRespThird+progEdgeRespThird);
edgeDsiAllAdjT4T5 = edgeDsiAllAdj(markingCriteriaT4FiltStrict | markingCriteriaT5Filt);
edgeDsiAllAdjT4T5 = edgeDsiAllAdjT4T5(roisWithThreeProbes);
dsiChange = scatter(edgeDsiAllAdjT4T5, dsiThirdProbe);
dsiChange.MarkerFaceColor = 'flat';
linCoeff = polyfit(edgeDsiAllAdjT4T5, dsiThirdProbe, 1);
axis equal tight
ax = axis;
linVals = polyval(linCoeff, ax(1:2));
hold on;
plot(ax(1:2), linVals);
plot([-1 1], [-1 1]);
xlabel('DSI first two presentations')
ylabel('DSI third presentation');
legend({'DSI of chosen T4/T5', 'Best fit line', 'y=x line'}, 'Location', 'Northwest');
ConfAxis

MakeFigure
lightEdgeRespThird = mean([allEdgeThreshedResps(1, :); allEdgeThreshedResps(3, :)]);
darkEdgeRespThird = mean([allEdgeThreshedResps(2, :); allEdgeThreshedResps(4, :)]);

esiThirdProbe = (lightEdgeRespThird-darkEdgeRespThird)./(lightEdgeRespThird+darkEdgeRespThird);
edgeEsiAllAdjT4T5 = edgeEsiAllAdj(markingCriteriaT4FiltStrict | markingCriteriaT5Filt);
edgeEsiAllAdjT4T5 = edgeEsiAllAdjT4T5(roisWithThreeProbes);
esiChange = scatter(edgeEsiAllAdjT4T5, esiThirdProbe);
esiChange.MarkerFaceColor = 'flat';
linCoeff = polyfit(edgeEsiAllAdjT4T5, esiThirdProbe, 1);
axis equal tight
ax = axis;
linVals = polyval(linCoeff, ax(1:2));
hold on;
plot(ax(1:2), linVals);
plot([-1 1], [-1 1]);
xlabel('ESI first two presentations')
ylabel('ESI third presentation');
legend({'ESI of chosen T4/T5', 'Best fit line', 'y=x line'}, 'Location', 'Northwest');
ConfAxis


analysis.edgeEsiAdj = edgeEsiAllAdj;
analysis.edgeDsiAdj = edgeDsiAllAdj;
analysis.meanMaxLightEdgeResp = maxLightEdgeRespAll(overallCorrAll>overallCorrelationThresh);
analysis.meanMaxDarkEdgeRespAll = maxDarkEdgeRespAll(overallCorrAll>overallCorrelationThresh);

end
