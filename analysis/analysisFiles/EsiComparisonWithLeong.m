function analysis = EsiComparisonWithLeong(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
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
ignoreRoiIndsOfInterest = false;
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
dataPathsOut = cellfun(@(dpOut) dpOut{1}, dataPathsOut, 'UniformOutput', false);

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
    edgeEsiLeongAll = [];
    primCorrsAll = [];
    probeCorrAll = [ ];
    maxMeansLocAll = [ ];
    fliesAssoc = [];
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
        
        [~,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectResponsiveRois(flyResp{ff},roiMask{ff},epochStartTimes,epochDurations, epochsForSelectionForFly(selEpochs, :), params{ff}, [], varargin{:}, 'dataRate', dataRate, 'esiDsiMax', esiDsiMax);
%         flyRespRaw{ff} = LoadRawTraces( dataPathsOut{ff}, roiMask{ff}{1});

        if ~ignoreRoiIndsOfInterest % necessary for dendrite analyses
            if ~any(roiIndsOfInterest)
                roiSizes = valueStruct.roiSizes;
                numROIs(ff) = length(roiSizes);
                continue
            else
                fliesToUse = [fliesToUse ff];
            end
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
        edgeEsiLeong = valueStruct.edgeEsiLeong;
        juyueCorr = valueStruct.juyueCorr;
        maxMeansLoc = valueStruct.maxMeansLoc;
        meanMatrix = valueStruct.meanMatrix;
        maxPrimEdgeResp  = valueStruct.maxPrimEdgeResp;
        maxSecEdgeResp = valueStruct.maxSecEdgeResp;
        overallCorr = valueStruct.overallCorrelations;
        roiSizes = valueStruct.roiSizes;
        numROIs(ff) = length(roiSizes);
        flyAssoc = ff*ones(1, length(roiSizes));
        

 
        
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
        fliesAssoc = [fliesAssoc flyAssoc];
        
        
        edgeEsiAll = [edgeEsiAll edgeEsi];
        edgeEsiLeongAll = [edgeEsiLeongAll edgeEsiLeong];
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
    
    
end

%%
roiSizeThresh = 5;
if exist('overallCorrelationThreshMain', 'var')
    overallCorrelationThresh = overallCorrelationThreshMain;
    filteringCriteria = overallCorrAll>overallCorrelationThresh & roiSizesAll>roiSizeThresh;
    
    dsi = 0.4;
    t4Dsi = dsi;
    t5Dsi = dsi;
    t4Esi = 0.3;
    t5Esi = -0.4;
    markingCriteriaT4 = filteringCriteria & edgeEsiAll>t4Esi;% & abs(edgeDsiAll)>t4Dsi;
    markingCriteriaT5 = filteringCriteria & edgeEsiAll<t5Esi;% & abs(edgeDsiAll)>t5Dsi;
    
    edgeDsiAllAdj = edgeDsiAll;
    edgeDsiAllAdj(abs(edgeDsiAllAdj)>1) = sign(edgeDsiAllAdj(abs(edgeDsiAllAdj)>1));
    edgeDsiAllAdj = edgeDsiAllAdj(filteringCriteria);
    
    edgeEsiAllAdj = edgeEsiAll;
    edgeEsiAllAdj(abs(edgeEsiAllAdj)>1) = sign(edgeEsiAllAdj(abs(edgeEsiAllAdj)>1));
    edgeEsiAllAdj = edgeEsiAllAdj(filteringCriteria);
    
    edgeEsiLeongAllAdj = edgeEsiLeongAll;
    edgeEsiLeongAllAdj(abs(edgeEsiLeongAllAdj)>1) = sign(edgeEsiLeongAllAdj(abs(edgeEsiLeongAllAdj)>1));
    edgeEsiLeongAllAdj = edgeEsiLeongAllAdj(filteringCriteria);
    
    markingCriteriaT4Filt = markingCriteriaT4(filteringCriteria);
    markingCriteriaT5Filt = markingCriteriaT5(filteringCriteria);
    
    esiDsiFig = MakeFigure;
    esiDsiFig.Name = figureName;
    sctPlot = subplot(5,5,[6:9 11:14 16:19 21:24]);
    
    % Scatter
    overallCorrFlt = overallCorrAll(filteringCriteria);
    r = scatter(edgeDsiAllAdj, edgeEsiAllAdj, 10);
    r.MarkerEdgeColor = [0.5 0.5 0.5];
    r.MarkerFaceColor = r.MarkerEdgeColor;
    hold on
    % T4 left
    m = scatter(edgeDsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj<-0.4), edgeEsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj<-0.4), 10);
    m.MarkerEdgeColor = [1 0 1];
    m.MarkerFaceColor = m.MarkerEdgeColor;
    % T4 right
    m = scatter(edgeDsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj>0.4), edgeEsiAllAdj(markingCriteriaT4Filt & edgeDsiAllAdj>0.4), 10);
    m.MarkerEdgeColor = [1 0 0];
    m.MarkerFaceColor = m.MarkerEdgeColor;
    % T5 left
    m = scatter(edgeDsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj<-0.4), edgeEsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj<-0.4), 10);
    m.MarkerEdgeColor = [0 1 0];
    m.MarkerFaceColor = m.MarkerEdgeColor;
    % T5 right
    m = scatter(edgeDsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj>0.4), edgeEsiAllAdj(markingCriteriaT5Filt & edgeDsiAllAdj>0.4), 10);
    m.MarkerEdgeColor = [0 0 1];
    m.MarkerFaceColor = m.MarkerEdgeColor;
    
    axis([-1 1 -1 1]);
    xlabel('DSI');
    ylabel('ESI');
    hold on
    
    PlotConstLine(-0.4, 1);
    PlotConstLine(0.3, 1);
    PlotConstLine(-0.4, 2);
    PlotConstLine(0.4, 2);
    ConfAxis
    
    % Histograms
    binSplits = -1:0.1:1;
    
    % ESI histograms
    subplot(5,5,[10 15 20 25]);
    hEsi = histogram(edgeEsiAllAdj, binSplits);%, 'Normalization', 'pdf');
    hEsi.Orientation = 'horizontal';
    hEsi.Parent.YTickLabel = '';
    hold on;
    
    
    hEsi.FaceColor = [0.5 0.5 0.5];
    PlotConstLine(t5Esi, 1);
    PlotConstLine(t4Esi, 1);
    for i = 1:length(hEsi.BinEdges)-1
        mnCorrEsi(i) = mean(overallCorrFlt(edgeEsiAllAdj>hEsi.BinEdges(i) & edgeEsiAllAdj<=hEsi.BinEdges(i+1)));
        stdCorrEsi(i) = std(overallCorrFlt(edgeEsiAllAdj>hEsi.BinEdges(i) & edgeEsiAllAdj<=hEsi.BinEdges(i+1)));
    end
    ConfAxis
    
    % DSI histograms
    subplot(5,5,1:4);
    hDsi = histogram(edgeDsiAllAdj, binSplits);%, 'Normalization', 'pdf');
    hDsi.Parent.XTickLabel = '';
    hold on;
    
    hDsi.FaceColor = [0.5 0.5 0.5];
    PlotConstLine(-dsi, 2);
    PlotConstLine(dsi, 2);
    title(sprintf('Correlation thresh=%0.2f, ROI size thresh=%0.0f', overallCorrelationThresh, roiSizeThresh));
    
    for i = 1:length(hDsi.BinEdges)-1
        mnCorrDsi(i) = mean(overallCorrFlt(edgeDsiAllAdj>hDsi.BinEdges(i) & edgeDsiAllAdj<=hDsi.BinEdges(i+1)));
        stdCorrDsi(i) = std(overallCorrFlt(edgeDsiAllAdj>hDsi.BinEdges(i) & edgeDsiAllAdj<=hDsi.BinEdges(i+1)));
    end
    ConfAxis
end
%%
if exist('overallCorrelationThreshSupp', 'var')  
    overallCorrelationThresh = overallCorrelationThreshSupp;
    filteringCriteria = overallCorrAll>overallCorrelationThresh & roiSizesAll>roiSizeThresh;

    dsi = 0.4;
    t4Dsi = dsi;
    t5Dsi = dsi;
    t4Esi = 0.3;
    t5Esi = -0.4;
    markingCriteriaT4 = filteringCriteria & edgeEsiAll>t4Esi;% & abs(edgeDsiAll)>t4Dsi;
    markingCriteriaT5 = filteringCriteria & edgeEsiAll<t5Esi;% & abs(edgeDsiAll)>t5Dsi;

    edgeDsiAllAdj = edgeDsiAll;
    edgeDsiAllAdj(abs(edgeDsiAllAdj)>1) = sign(edgeDsiAllAdj(abs(edgeDsiAllAdj)>1));
    edgeDsiAllAdj = edgeDsiAllAdj(filteringCriteria);

    edgeEsiAllAdj = edgeEsiAll;
    edgeEsiAllAdj(abs(edgeEsiAllAdj)>1) = sign(edgeEsiAllAdj(abs(edgeEsiAllAdj)>1));
    edgeEsiAllAdj = edgeEsiAllAdj(filteringCriteria);
    
    edgeEsiLeongAllAdj = edgeEsiLeongAll;
    edgeEsiLeongAllAdj(abs(edgeEsiLeongAllAdj)>1) = sign(edgeEsiLeongAllAdj(abs(edgeEsiLeongAllAdj)>1));
    edgeEsiLeongAllAdj = edgeEsiLeongAllAdj(filteringCriteria);

    
    markingCriteriaT4Filt = markingCriteriaT4(filteringCriteria);
    markingCriteriaT5Filt = markingCriteriaT5(filteringCriteria);



    esiDsiFig = findobj('Type','Figure','Name',figureName);
    if isempty(esiDsiFig)
        esiDsiFig = MakeFigure;
        esiDsiFig.Name=figureName;
        firstTime = true;
        esiDsiFig.UserData = 1;
    else
        figure(esiDsiFig);
        esiDsiFig.UserData = esiDsiFig.UserData+1;
        firstTime = false;
        hold on
    end


    sctPlot = subplot(5,5,[11:13 16:18 21:23]);
    sctPlot.ColorOrderIndex = esiDsiFig.UserData;

    overallCorrFlt = overallCorrAll(filteringCriteria);
    if firstTime
        r = scatter(edgeDsiAllAdj, edgeEsiAllAdj, 10, overallCorrFlt);
        colormap(b2r(overallCorrelationThresh, 1, 0.4));
        r.MarkerFaceColor = r.MarkerEdgeColor;
        colorbar
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
        colorLines = lines(1);
        patch(errPatchPtsX, errPatchPtsY, colorLines, 'FaceAlpha', 0.25, 'EdgeColor', 'none')
        hold on;
        plot(mnCorrEsi, bE, 'color', colorLines)
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
        PlotConstLine(-dsi, 2);
        PlotConstLine(dsi, 2);
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

end



%% Do the Leong Checks
for ovCorrInd = 1:length(overallCorrelationThreshComparison)
    correlationThresh = overallCorrelationThreshComparison(ovCorrInd);
    filteringCriteria = overallCorrAll>correlationThresh & roiSizesAll>roiSizeThresh;
    
    edgeEsiAllAdj = edgeEsiAll;
    edgeEsiAllAdj(abs(edgeEsiAllAdj)>1) = sign(edgeEsiAllAdj(abs(edgeEsiAllAdj)>1));
    edgeEsiAllAdj = edgeEsiAllAdj(filteringCriteria);
    
    edgeEsiLeongAllAdj = edgeEsiLeongAll;
    edgeEsiLeongAllAdj(abs(edgeEsiLeongAllAdj)>1) = sign(edgeEsiLeongAllAdj(abs(edgeEsiLeongAllAdj)>1));
    edgeEsiLeongAllAdj = edgeEsiLeongAllAdj(filteringCriteria);
    %% Both unfolded
%     leongCheck = MakeFigure;
%     subplot(3, 1, 3)
%     binSplits = -1:0.1:1;
%     histogram(edgeEsiAllAdj, binSplits);
%     hold on
%     edgeEsiLeongPosNeg = edgeEsiLeongAllAdj;
%     edgeEsiLeongPosNeg(edgeEsiAllAdj<0) = -edgeEsiLeongPosNeg(edgeEsiAllAdj<0);
%     histogram(edgeEsiLeongPosNeg, binSplits);
%     legend('Salazar-Gatzimas ESI', 'Leong ESI unfolded');
%     xlabel('ESI (Leong or Salazar-Gatzimas)')
%     ylabel('Count');
%     ConfAxis;
%     
%     subplot (3, 1, [1 2])
%     scatter(edgeEsiAllAdj, edgeEsiLeongAllAdj, 50, 'k', 'filled');
%     xlabel('Salazar-Gatzimas ESI');
%     ylabel('Leong ESI');
%     title('Salazar-Gatzimas ESI vs Leong ESI Unfolded');
%     hold on;
%     plot([-1, 0, 1], [1, 0, 1], '--');
%     ConfAxis;
%     
%     leongCheck.Name = sprintf('ESILeongComp_unfold_r0-%d', 100*round(correlationThresh, 2));
    
    %% Both folded
    leongCheck = MakeFigure;
    binSplits = 0:0.05:1;
    histogram(abs(edgeEsiAllAdj), binSplits);
    hold on
    histogram(edgeEsiLeongAllAdj, binSplits);
    title(sprintf('Salazar-Gatzimas ESI vs Leong ESI in %s, r=%0.2f', figureName, correlationThresh));
    legend('Salazar-Gatzimas |ESI|', 'Leong ESI');
    xlabel('ESI (Leong or Salazar-Gatzimas)')
    ylabel('Count');
    ConfAxis;
    
%     leongCheck.Name = sprintf('ESILeongComp_fold_r0-%d', 100*round(correlationThresh, 2));
    
    %% Both as given
    leongCheck = MakeFigure;
    subplot(3, 3, [7 8])
    binSplits = -1:0.1:1;
    histogram(edgeEsiAllAdj, binSplits);
    xlabel('Salazar-Gatzimas ESI')
    ylabel('Count');
    ConfAxis
    subplot(3, 3, [3 6])
    binSplits = 0:0.1:1;
    hEsi = histogram(edgeEsiLeongAllAdj, binSplits);
    hEsi.Orientation = 'horizontal';
    ylabel('Leong ESI')
    xlabel('Count');
    ConfAxis;
    
    subplot (3, 3, [1 2 4 5])
    scatter(edgeEsiAllAdj, edgeEsiLeongAllAdj, 50, 'k', 'filled');
    xlabel('Salazar-Gatzimas ESI');
    ylabel('Leong ESI');
    title(sprintf('Salazar-Gatzimas ESI vs Leong ESI in %s, r=%0.2f', figureName, correlationThresh));
    hold on;
    plot([-1, 0, 1], [1, 0, 1], '--');
    ConfAxis;
    
%     leongCheck.Name = sprintf('ESILeongComp_orig_r0-%d', 100*round(correlationThresh, 2));
end


analysis.edgeEsiAdj = edgeEsiAllAdj;
% analysis.edgeDsiAdj = edgeDsiAllAdj;
analysis.numFliesUsed = length(unique(fliesAssoc(filteringCriteria)));
analysis.meanMaxLightEdgeResp = maxLightEdgeRespAll(overallCorrAll>overallCorrelationThresh);
analysis.meanMaxDarkEdgeRespAll = maxDarkEdgeRespAll(overallCorrAll>overallCorrelationThresh);
analysis.numROIsUsed = length(edgeEsiAllAdj);
% %%
% indsOfInt = 1:8669;
% fR2 = cellfun(@(f) f(indsOfInt, :), flyResp, 'UniformOutput', false);
% fR = cat(2, fR2{:});
% figure;hist3([nanmean(fR(:, filteringCriteria), 1)', edgeEsiLeongAllAdj'])
% figure;histogram(nanmean(fR(:, filteringCriteria), 1));



end
