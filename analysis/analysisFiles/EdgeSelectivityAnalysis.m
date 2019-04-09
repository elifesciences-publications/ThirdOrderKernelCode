function analysis = EdgeSelectivityAnalysis(flyResp,epochs,params,~ ,dataRate,dataType,~,varargin)
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
barToCenter = 2;
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

% 
% esiDsiPlot = MakeFigure;

numROIs = zeros(1, numFlies);
% run the algorithm for each fly
for selEpochs = 1:size(epochsForSelectivity, 1)
    dsiAll = [];
    selIndAll = [];
    zValsAll = [];
    indsIntAll = true(0);
    roiChoicesAll = true(0);
    edgeDsiAll = [];
    primCorrsAll = [];
    for ff = 1:numFlies
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
        
        
        selIndThresh = 0.4;
        primCorrIndThresh = 0.4;
        dirSelThresh = 0.4;
        pValThresh = .05;
        
        [epochsForSelectionForFly, ~, ~] = AdjustEpochsForEye(dataPathsOut{ff}, varargin{:});
        
        [~,roiMaskOut, roiIndsOfInterest, pValsSum, valueStruct] = SelectResponsiveRois(flyResp{ff},roiMask{ff},epochStartTimes,epochDurations, epochsForSelectionForFly(selEpochs, :), params{ff},varargin{:}, 'dataRate', dataRate);
        if ~any(roiIndsOfInterest)
            continue
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
        juyueESI = valueStruct.juyueESI;
        juyueEdgeDsi = valueStruct.juyueEdgeDsi;
        juyueCorr = valueStruct.juyueCorr;
        maxMeansLoc = valueStruct.maxMeansLoc;
        

        % For the moment we consider that when testing Juyue's method
        % there's always the normal method right before
        if isempty(juyueESI)
            selEpochsHere = selEpochs;
            roiChoices{ff}(selEpochs, :) = pVals<(pValThresh/size(flyResp{ff}, 2))& (maxMeansLoc==1 | maxMeansLoc==2); % edgeSelInd>selIndThresh  & primCorr>primCorrIndThresh;%dsi>dirSelThresh;%
            epochNumPrimDir = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochs, 1});
            epochNumSecDir = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochs, 2});
            epochNumPrim = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochs, 3});
            epochNumSec = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochs, 4});
            dirPrimResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)), epochStartTimes, epochDurations, epochNumPrimDir);
            dirSecResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)), epochStartTimes, epochDurations, epochNumSecDir);
            dirPrimResp = cat(1, dirPrimResp{:});
            dirSecResp = cat(1, dirSecResp{:});
            lightEdges = [1 3];
            darkEdges = [2 4];
            if any(ismember(lightEdges, epochNumPrim))
                epochNumPrimEdges = [epochNumPrim lightEdges(~ismember(lightEdges, epochNumPrim))];
                epochNumSecEdges = [epochNumSec darkEdges(~ismember(darkEdges, epochNumSec))];
                
            else
                epochNumPrimEdges = [epochNumPrim darkEdges(~ismember(darkEdges, epochNumPrim))];
                epochNumSecEdges = [epochNumSec lightEdges(~ismember(lightEdges, epochNumSec))];
            end
            if ~isnan(epochNumPrimEdges(1))
                primaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumPrimEdges(1));
                primaryResponse = [primaryResponse; GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumPrimEdges(2))];
                secondaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumSecEdges(1));
                secondaryResponse = [secondaryResponse; GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumSecEdges(2))];
                primaryResponse = cat(1, primaryResponse{:});
                secondaryResponse = cat(1, secondaryResponse{:});
            else
                primaryResponse = 0;
                secondaryResponse = 0;
            end
        else
            selEpochsHere = selEpochs-1;
            roiChoices{ff}(selEpochs, :) =  juyueEdgeDsi > dirSelThresh & juyueCorr > 0.1 & (maxMeansLoc==1 | maxMeansLoc==2);% & juyueESI > selIndThresh;
            epochNumPrimDir = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochsHere, 1});
            epochNumSecDir = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochsHere, 2});
            epochNumPrim = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochsHere, 3});
            epochNumSec = ConvertEpochNameToIndex(params{ff}, epochsForSelectionForFly{selEpochsHere, 4});
            dirPrimResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)), epochStartTimes, epochDurations, epochNumPrimDir);
            dirSecResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)), epochStartTimes, epochDurations, epochNumSecDir);
            dirPrimResp = cat(1, dirPrimResp{:});
            dirSecResp = cat(1, dirSecResp{:});
            lightEdges = [1 3];
            darkEdges = [2 4];
            if any(ismember(lightEdges, epochNumPrim))
                epochNumPrimEdges = [epochNumPrim lightEdges(~ismember(lightEdges, epochNumPrim))];
                epochNumSecEdges = [epochNumSec darkEdges(~ismember(darkEdges, epochNumSec))];
            else
                epochNumPrimEdges = [epochNumPrim darkEdges(~ismember(darkEdges, epochNumPrim))];
                epochNumSecEdges = [epochNumSec lightEdges(~ismember(lightEdges, epochNumSec))];
            end
            if ~isnan(epochNumPrimEdges(1))
                primaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumPrimEdges(1));
                primaryResponse = [primaryResponse; GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumPrimEdges(2))];
                secondaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumSecEdges(1));
                secondaryResponse = [secondaryResponse; GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoices{ff}(selEpochs, :)),epochStartTimes,epochDurations,epochNumSecEdges(2))];
                primaryResponse = cat(1, primaryResponse{:});
                secondaryResponse = cat(1, secondaryResponse{:});
            else
                primaryResponse = 0;
                secondaryResponse = 0;
            end
        end
        
        numRois = sum(roiChoices{ff}(selEpochs, :));
        roiNumber = find(roiChoices{ff}(selEpochs, :));
        
        
        %% *** THIS IS TO CHECK VS JUYUE'S METHOD *** %%
        analysisChoice = [];
        if ~mod(selEpochs, 2)
            roiChoicesDifferent = xor(roiChoices{ff}(selEpochs, :), roiChoices{ff}(selEpochs-1, :));
            analysisChoice(roiChoicesDifferent) = 2*roiChoices{ff}(selEpochs, roiChoicesDifferent) + roiChoices{ff}(selEpochs-1, roiChoicesDifferent);
            dirPrimResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoicesDifferent), epochStartTimes, epochDurations, epochNumPrimDir);
            dirSecResp = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoicesDifferent), epochStartTimes, epochDurations, epochNumSecDir);
            dirPrimResp = cat(1, dirPrimResp{:});
            dirSecResp = cat(1, dirSecResp{:});
            lightEdges = [1 3];
            darkEdges = [2 4];
            if any(ismember(lightEdges, epochNumPrim))
                epochNumPrimEdges = [epochNumPrim lightEdges(~ismember(lightEdges, epochNumPrim))];
                epochNumSecEdges = [epochNumSec darkEdges(~ismember(darkEdges, epochNumSec))];
            else
                epochNumPrimEdges = [epochNumPrim darkEdges(~ismember(darkEdges, epochNumPrim))];
                epochNumSecEdges = [epochNumSec lightEdges(~ismember(lightEdges, epochNumSec))];
            end
            if ~isnan(epochNumPrimEdges(1))
                primaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:,roiChoicesDifferent),epochStartTimes,epochDurations,epochNumPrimEdges(1));
                primaryResponse = [primaryResponse; GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoicesDifferent),epochStartTimes,epochDurations,epochNumPrimEdges(2))];
                secondaryResponse = GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoicesDifferent),epochStartTimes,epochDurations,epochNumSecEdges(1));
                secondaryResponse = [secondaryResponse; GetRoiResponsesFromEpoch(flyResp{ff}(:, roiChoicesDifferent),epochStartTimes,epochDurations,epochNumSecEdges(2))];
                primaryResponse = cat(1, primaryResponse{:});
                secondaryResponse = cat(1, secondaryResponse{:});
            else
                primaryResponse = 0;
                secondaryResponse = 0;
            end
            moveOn=  true;
        else
            moveOn=true;
            continue
        end
        
        
        numRois = sum(roiChoicesDifferent);
        roiNumber = find(roiChoicesDifferent);
        
        if numRois<1
            fprintf('No differences between criteria %d and %d in fly %d!\n', selEpochs, selEpochs-1, ff)
        else
            fprintf('Number ROIs in fly %d from both criteria was %d\n', ff,  sum(any(roiChoices{ff}([selEpochs selEpochs-1], :))))
        end
        % ** DELETE ONCE YOU DON'T NEED IT ** %
        
        if true;% numFlies < 2
            subpltPerSide = 4;
            plotsPerFig = subpltPerSide^2;
            numPlotTypes = 2;
            numFigs = ceil(numPlotTypes*numRois/plotsPerFig);
            for fig = 1:numFigs
                MakeFigure;
                for subplt = 1:2:plotsPerFig
                    if (plotsPerFig*(fig-1)+subplt)>2*size(dirPrimResp, 2)
                        break
                    end
                    subplot(subpltPerSide, subpltPerSide, subplt);
                    pltInd = round((plotsPerFig*(fig-1)+subplt)/numPlotTypes);
                    if length(primaryResponse)>1
                        plot(primaryResponse(:, pltInd));hold on
                        plot(secondaryResponse(:, pltInd));hold off
                        if ~isempty(pVals)
                            text(0, 0, [num2str(pVals(roiNumber(pltInd))) ' - ' num2str(pValThresh/size(flyResp{ff}, 2))], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                        end
                        title(sprintf('Analysis %d; Fly %d - ROI %d', analysisChoice(roiNumber(pltInd)), ff, roiNumber(pltInd)));
                    end
                end
                legend([epochsForSelectionForFly{selEpochs, [1 3]}], [epochsForSelectionForFly{selEpochs, [1 4]}]);
                for subplt = 2:2:plotsPerFig
                    if (plotsPerFig*(fig-1)+subplt)>2*size(dirPrimResp, 2)
                        break
                    end
                    subplot(subpltPerSide, subpltPerSide, subplt);
                    pltInd = round((plotsPerFig*(fig-1)+subplt)/numPlotTypes);
                    plot(dirPrimResp(:, pltInd));hold on
                    plot(dirSecResp(:, pltInd));hold off
                    if ~isempty(pVals)
                        text(0, 0, num2str(pVals(roiNumber(pltInd))), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                    end
                    title(sprintf('Analysis %d; Fly %d - ROI %d', analysisChoice(roiNumber(pltInd)), ff, roiNumber(pltInd)));

                end
                legend([epochsForSelectionForFly{selEpochsHere, 1}], [epochsForSelectionForFly{selEpochsHere, 2}]);
            end
        end
        
        %             MakeFigure;
        %             title('Distributions')
        %             scatter(selInd,dsi);
        %             xlabel(['Edge Selectivity' epochsForSelectivity{selEpochs, 1} ' - ' epochsForSelectivity{selEpochs, 2}]);
        %             ylabel(['Direction Selectivity' epochsForSelectivity{selEpochs, 3} ' - ' epochsForSelectivity{selEpochs, 4}]);
        dsiAll = [dsiAll dsi];
        selIndAll = [selIndAll edgeSelInd];
        zValsAll = [zValsAll zVals];
        indsIntAll = [indsIntAll pVals < (pValThresh/size(flyResp{ff}, 2))];
        roiChoicesAll = [roiChoicesAll roiChoices{ff}(selEpochs, :)];
        edgeDsiAll = [edgeDsiAll edgeDsi];
        primCorrsAll = [primCorrsAll primCorr];
    end
    
    if ~moveOn
        figure(esiDsiPlot);
        if strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Left') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'light'))
            scatter(selIndAll(selIndAll>0 & dsiAll>0),dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-selIndThresh selIndThresh;-selIndThresh selIndThresh], [-1 -1; 1 1], 'k--');
            plot([-1 -1; 1 1], [-dirSelThresh dirSelThresh;-dirSelThresh dirSelThresh], 'k--');
            scatterAxis = gca;
            [scatterAxis.findobj('Type', 'Scatter').LineWidth] = deal(2);
            plot(selIndAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), dsiAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), 'g*');
        elseif strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Left') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'dark'))
            scatter(-selIndAll(selIndAll>0 & dsiAll>0),dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(-selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-selIndThresh selIndThresh;-selIndThresh selIndThresh], [-1 -1; 1 1], 'k--');
            plot([-1 -1; 1 1], [-dirSelThresh dirSelThresh;-dirSelThresh dirSelThresh], 'k--');
            scatterAxis = gca;
            [scatterAxis.findobj('Type', 'Scatter').LineWidth] = deal(2);
            plot(-selIndAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), dsiAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), 'g*');
        elseif strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Right') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'light'))
            scatter(selIndAll(selIndAll>0 & dsiAll>0),-dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), -dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-selIndThresh selIndThresh;-selIndThresh selIndThresh], [-1 -1; 1 1], 'k--');
            plot([-1 -1; 1 1], [-dirSelThresh dirSelThresh;-dirSelThresh dirSelThresh], 'k--');
            scatterAxis = gca;
            [scatterAxis.findobj('Type', 'Scatter').LineWidth] = deal(2);
            plot(selIndAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), -dsiAll(primCorrsAll>primCorrIndThresh & selIndAll>0 & dsiAll>0), 'g*');
        elseif strcmpi(epochsForSelectionForFly{selEpochs, 1}, 'Square Right') && ~isempty(strfind(lower(epochsForSelectionForFly{selEpochs, 3}), 'dark'))
            scatter(-selIndAll(selIndAll>0 & dsiAll>0),-dsiAll(selIndAll>0 & dsiAll>0), 36, [0 0 1]);
            hold on;
            scatter(-selIndAll(indsIntAll & selIndAll>0 & dsiAll>0), -dsiAll(indsIntAll & selIndAll>0 & dsiAll>0), 36, [1 0 0]);
            plot([-selIndThresh selIndThresh;-selIndThresh selIndThresh], [-1 -1; 1 1], 'k--');
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
analysis = [];




end
