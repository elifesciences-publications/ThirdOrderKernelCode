function tp_plotCorrDirSelStimuliSummary(Z, rightPosEpochs, leftPosEpochs, rightNegEpochs, leftNegEpochs, epochsUncorrelated, stimulusPresentationId, connDb, stimulusFunction, xAxisLabels)


functionToStringInfo.inputs = whos;
functionToStringInfo.functionName = mfilename;
functionToStringInfo.outputs = nargout;
functionCallString = eval(sprintf('functionCallAsString(functionToStringInfo%s)', sprintf(',%s', functionToStringInfo.inputs.name)));
stimulusPresentationInformation.params = rmfield(Z.params, 'trigger_inds');

if isempty(stimulusFunction)
    stimulusFunction = fetch(connDb, sprintf('select stimulusFunction from stimulusPresentation where stimulusPresentationId = %d', stimulusPresentationId));
    stimulusFunction = stimulusFunction{1};
end

% flyPath = fullfile('2015_03_17', 'w_+;UASGC6f_+;T4T5_+ - 1');
flyData = fetch(connDb, sprintf('select eye from fly join stimulusPresentation as sP on fly.flyId = sP.fly where sP.stimulusPresentationId=%d ', stimulusPresentationId));
flyEye = flyData{1};
stimulusFunction(stimulusFunction=='_') = ' ';
titleText = [stimulusFunction ' ' flyEye ' eye'];

% tp_plotVarDtStimuliSummary(outScint60Dt{1}, titleText, epochsForSelectivity, rightEpochs, leftEpochs, 'red')
prefColorString = 'red';
colorStrings = {'red', 'blue'};
colInd = strcmp(colorStrings, prefColorString);
if strcmpi(flyEye, 'right')
    epochsForSelectivity = {'Square Right'; 'Square Left'};
%     epochsForSelectivity = {'R+ dt=1'; 'L+ dt=1'};
    epochsPreferredPos = rightPosEpochs;
    epochsNullPos = leftPosEpochs;
    epochsPreferredNeg = rightNegEpochs;
    epochsNullNeg = leftNegEpochs;
else
    epochsForSelectivity = {'Square Left'; 'Square Right'};
%     epochsForSelectivity = {'L+ dt=1'; 'R+ dt=1'};
    epochsPreferredPos = leftPosEpochs;
    epochsNullPos = rightPosEpochs;
    epochsPreferredNeg = leftNegEpochs;
    epochsNullNeg = rightNegEpochs;
end

%     epochsForSelectivity = {'Square Right'; 'Square Left'};
tic
p = MakeFigure;
p.Name = Z.params.roiType;
Z.params.epochsForSelectivity = epochsForSelectivity;
roisBySelectivity = ExtractROIsByParams(Z);
roisBySize = ExtractRoisBySize(Z);
Z.ROI.roiIndsOfInterest = roisBySelectivity & roisBySize;

if ~any(Z.ROI.roiIndsOfInterest)
    warning('No ROIs of interest for comparison of %s to %s', epochsForSelectivity{1}, epochsForSelectivity{2})
else
    Z = averageEpochResponseAnalysis(Z);
    
    titleText = [stimulusFunction ' positive correlations ' flyEye ' eye'];
    axisObjects(1) = subplot(2, 3, 1);
    hold on
    tp_plotStimuliPDminusND(Z, titleText, epochsForSelectivity, epochsPreferredPos, epochsNullPos, epochsUncorrelated, prefColorString, xAxisLabels)
    legend({'Progressive Positive Preferred', 'Progressive Positive Null'});
    subplot(4, 6, 3)
    hold on
    tp_plotStimuliROIandAvgPerEpoch(Z, titleText, epochsForSelectivity, epochsPreferredPos, epochsNullPos, prefColorString)
    subplot(4, 6, 9)
    hold on
    tp_plotStimuliROIandAvgPerEpoch(Z, '', epochsForSelectivity, epochsNullPos, epochsPreferredPos, colorStrings{~colInd})
    titleText = [stimulusFunction ' negative correlations ' flyEye ' eye'];
    axisObjects(2) = subplot(2, 3, 4);
    hold on
    tp_plotStimuliPDminusND(Z, titleText, epochsForSelectivity, epochsPreferredNeg, epochsNullNeg, epochsUncorrelated, prefColorString, xAxisLabels)
    legend({'Progressive Negative Preferred', 'Progressive Negative Null'});
    subplot(4, 6, 15)
    hold on
    tp_plotStimuliROIandAvgPerEpoch(Z, '', epochsForSelectivity, epochsPreferredNeg, epochsNullNeg, prefColorString)
    subplot(4, 6, 21)
    hold on
    labelAxes = true;
    tp_plotStimuliROIandAvgPerEpoch(Z, '', epochsForSelectivity, epochsNullNeg, epochsPreferredNeg, colorStrings{~colInd}, labelAxes, xAxisLabels)
    % Switch up layers
end
epochsForSelectivity = epochsForSelectivity(end:-1:1, :);
Z.params.epochsForSelectivity = epochsForSelectivity;
roisBySelectivity = ExtractROIsByParams(Z);
% roisBySize = ExtractRoisBySize(Z);
Z.ROI.roiIndsOfInterest = roisBySelectivity;% & roisBySize;

if ~any(Z.ROI.roiIndsOfInterest)
    warning('No ROIs of interest for comparison of %s to %s', epochsForSelectivity{1}, epochsForSelectivity{2})
else
    Z = averageEpochResponseAnalysis(Z);
    
    titleText = [stimulusFunction ' positive correlations ' flyEye ' eye'];
    axisObjects(3) = subplot(2, 3, 3);
    hold on
    tp_plotStimuliPDminusND(Z, titleText, epochsForSelectivity, epochsNullPos, epochsPreferredPos, epochsUncorrelated, prefColorString, xAxisLabels)
    legend({'Regressive Positive Preferred', 'Regressive Positive Null'});
    subplot(4, 6, 4)
    hold on
    tp_plotStimuliROIandAvgPerEpoch(Z, titleText, epochsForSelectivity, epochsNullPos, epochsPreferredPos, prefColorString)
    subplot(4, 6, 10)
    hold on
    tp_plotStimuliROIandAvgPerEpoch(Z, '', epochsForSelectivity, epochsPreferredPos, epochsNullPos, colorStrings{~colInd})
    
    titleText = [stimulusFunction ' negative correlations ' flyEye ' eye'];
    axisObjects(4) = subplot(2, 3, 6);
    hold on
    tp_plotStimuliPDminusND(Z, titleText, epochsForSelectivity, epochsNullNeg, epochsPreferredNeg, epochsUncorrelated, prefColorString, xAxisLabels)
    legend({'Regressive Negative Preferred', 'Regressive Negative Null'});
    subplot(4, 6, 16)
    hold on
    tp_plotStimuliROIandAvgPerEpoch(Z, '', epochsForSelectivity, epochsNullNeg, epochsPreferredNeg, prefColorString)
    subplot(4, 6, 22)
    hold on
    labelAxes = true;
    tp_plotStimuliROIandAvgPerEpoch(Z, '', epochsForSelectivity, epochsPreferredNeg, epochsNullNeg, colorStrings{~colInd}, labelAxes, xAxisLabels)
    
end

yLims = cell2mat(get(axisObjects(isgraphics(axisObjects)), 'yLim'));
set(axisObjects(isgraphics(axisObjects)), 'yLim', [min(yLims(:, 1)) max(yLims(:, 2))])
%%
p = MakeFigure;
p.Name = Z.params.roiType;
Z.params.epochsForSelectivity = epochsForSelectivity;
roisBySelectivity = ExtractROIsByParams(Z);
roisBySize = ExtractRoisBySize(Z);
Z.ROI.roiIndsOfInterest = roisBySelectivity;% & roisBySize;
yLims = [];
if any(Z.ROI.roiIndsOfInterest)
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    epochAvgAnalysis = Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities;
    stepsBack = Z.triggeredResponseAnalysis.stepsBack;
    fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;
    % First split for progressive/regressive epochs and positive/negative
    % correlations
    
    
    % Regressive side
    % meanEpochAvgAnalysis = epochAvgAnalysis;
    for i = 1:length(epochsNullPos)
        subplot(2, 2, 2)
        hold on
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsPreferredPos(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsPreferredPos(i))]), 1);
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsNullPos(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsNullPos(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsNullPos(i), epochsPreferredPos(i), (1-(i-1)/length(epochsNullPos))*[1 0 0], (1-(i-1)/length(epochsNullPos))*[0 0 1])
        ylabel('Positive Correlations DF/F')
        title('Regressive ROI Responses')
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
    end
    % Separate for loop in case we only have one uncorrelated epoch
    for i = 1:length(epochsUncorrelated)
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsUncorrelated(i),[], (1-(i-1)/length(epochsUncorrelated))*[0 1 0], (1-(i-1)/length(epochsUncorrelated))*[0 1 0])
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
    end
    
    
    for i = 1:length(epochsNullNeg)
        subplot(2, 2, 4)
        hold on
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsPreferredNeg(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsPreferredNeg(i))]), 1);
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsNullNeg(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsNullNeg(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsNullNeg(i), epochsPreferredNeg(i), (1-(i-1)/length(epochsNullPos))*[1 0 0], (1-(i-1)/length(epochsNullPos))*[0 0 1])
        ylabel('Negative Correlations DF/F')
        title('Regressive ROI Responses')
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
        clear meanEpochAvgAnalysis;
    end
    % Separate for loop in case we only have one uncorrelated epoch
    for i = 1:length(epochsUncorrelated)
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsUncorrelated(i),[], (1-(i-1)/length(epochsUncorrelated))*[0 1 0], (1-(i-1)/length(epochsUncorrelated))*[0 1 0])
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
    end
end

Z.params.epochsForSelectivity = epochsForSelectivity(end:-1:1);
roisBySelectivity = ExtractROIsByParams(Z);
roisBySize = ExtractRoisBySize(Z);
Z.ROI.roiIndsOfInterest = roisBySelectivity;% & roisBySize;


if any(Z.ROI.roiIndsOfInterest)
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    epochAvgAnalysis = Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities;
    stepsBack = Z.triggeredResponseAnalysis.stepsBack;
    fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;
    % First split for progressive/regressive epochs and positive/negative
    % correlations
    
    
    % Progressive side
    for i = 1:length(epochsNullPos)
        subplot(2, 2, 1)
        hold on
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsPreferredPos(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsPreferredPos(i))]), 1);
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsNullPos(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsNullPos(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsPreferredPos(i), epochsNullPos(i), (1-(i-1)/length(epochsNullPos))*[1 0 0], (1-(i-1)/length(epochsNullPos))*[0 0 1])
        ylabel('Positive Correlations DF/F')
        title('Progressive ROI Responses')
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
    end
    % Separate for loop in case we only have one uncorrelated epoch
    for i = 1:length(epochsUncorrelated)
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsUncorrelated(i),[], (1-(i-1)/length(epochsUncorrelated))*[0 1 0], (1-(i-1)/length(epochsUncorrelated))*[0 1 0])
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
    end
    
    for i = 1:length(epochsNullNeg)
        subplot(2, 2, 3)
        hold on
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsPreferredNeg(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsPreferredNeg(i))]), 1);
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsNullNeg(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsNullNeg(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsPreferredNeg(i), epochsNullNeg(i), (1-(i-1)/length(epochsNullPos))*[1 0 0], (1-(i-1)/length(epochsNullPos))*[0 0 1])
        ylabel('Negative Correlations DF/F')
        title('Progressive ROI Responses')
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
    end
    % Separate for loop in case we only have one uncorrelated epoch
    for i = 1:length(epochsUncorrelated)
        meanEpochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]) = mean(epochAvgAnalysis.(['epoch_' num2str(epochsUncorrelated(i))]), 1);
        tp_plotTraceAndAverage(meanEpochAvgAnalysis, stepsBack, fsAligned, epochsUncorrelated(i),[], (1-(i-1)/length(epochsUncorrelated))*[0 1 0], (1-(i-1)/length(epochsUncorrelated))*[0 1 0])
        axLims = axis;
        yLims = [yLims axLims(3:4)'];
    end
end

minY = min(yLims(1, :));
maxY = max(yLims(2, :));

for i = 1:4
    subplot(2, 2, i)
    currLims = axis;
    axis([currLims(1:2) minY maxY]);
end
toc

stimulusPresentationInformation.stimulusPresentationId = stimulusPresentationId;
stimulusPresentationInformation.analysisFunction = mfilename;
stimulusPresentationInformation.functionCall = functionCallString;
% dataCommentRecorder(stimulusPresentationInformation);
% end
% epochsForSelectivity = [2;4];
% tp_plotVarDtStimuli(outScint60Dt{1}, titleText, epochsForSelectivity, leftEpochs, rightEpochs, 'blue', true)
% 
% 
% titleText = ['scint3 twop vardt 60Hz negative correlations ' flyEye ' eye'];
% rightNegativeEpochs = 14:4:34;
% leftNegativeEpochs = 13:4:34;
% epochsForSelectivity = [4;2];
% tp_plotVarDtStimuli(outScint60Dt{1}, titleText, epochsForSelectivity, rightNegativeEpochs, leftNegativeEpochs, 'red')
% 
% epochsForSelectivity = [2;4];
% tp_plotVarDtStimuli(outScint60Dt{1}, titleText, epochsForSelectivity, leftNegativeEpochs, rightNegativeEpochs, 'blue')

