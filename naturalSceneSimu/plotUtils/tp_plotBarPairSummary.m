function tp_plotBarPairSummary(Z, phase, barToCenter, pathString, connDb, chooseBestROI)
% plusEpochs and minusEpochs are defined by the first bar being positive or
% negative

epochNames = {Z.stimulus.params.epochName};
epochsOfInterestFirstLeft = find(~cellfun('isempty', strfind(epochNames, 'L++')), 1, 'first');
epochsOfInterestFirstRight = find(~cellfun('isempty', strfind(epochNames, 'R++')), 1, 'first');
if epochsOfInterestFirstLeft < epochsOfInterestFirstRight
    epochsOfInterestFirst = epochsOfInterestFirstLeft;
else
    epochsOfInterestFirst = epochsOfInterestFirstRight;
end
epochPhases = [Z.stimulus.params(epochsOfInterestFirst:end).phase];

epochsOfInterestNames = epochNames(epochsOfInterestFirst:end);
leftEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, 'L')))-1;
rightEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, 'R')))-1;
disp(['This analysis depends on whether the mirrors have been rotated or not!\n '...
    'Currently it''s being analyzed as if they have been rotated']);
if barToCenter == 2
    phaseProg = num2str(phase);
    phaseReg = num2str(mod(phase-1, 4));
elseif barToCenter==1
    phaseProg = num2str(phase);
    phaseReg = num2str(mod(phase+1, 4));
else
    phaseProg = num2str(phase);
    phaseReg = num2str(phase);
end

plotOverall = false;
flyData = fetch(connDb, sprintf('select eye from fly where relativePath = "%s"', pathString));
flyEye = flyData{1};
% stimulusFunction(stimulusFunction=='_') = ' ';
% titleText = [stimulusFunction ' ' flyEye ' eye'];

if strcmpi(flyEye, 'right')
    progEpochs = rightEpochs;
    regEpochs = leftEpochs;
    epochsForSelectivity = {'Square Right'; 'Square Left'};
else
    progEpochs = leftEpochs;
    regEpochs = rightEpochs;
    epochsForSelectivity = {'Square Left'; 'Square Right'};
end


posEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, ['++ P'])) | ~cellfun('isempty', strfind(epochsOfInterestNames, ['-- P'])))-1;
negEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, ['+- P'])) | ~cellfun('isempty', strfind(epochsOfInterestNames, ['-+ P'])))-1;

plusEpochs = epochsOfInterestFirst:2:length(epochNames);
minusEpochs = (epochsOfInterestFirst+1):2:length(epochNames);

epochOfInterestPhases = regexp(epochsOfInterestNames, '\s*(P\d)\s*', 'tokens');
epochOfInterestPhases = [epochOfInterestPhases{:}];
phaseProgCellStr = cellfun(@(x) num2str(x), num2cell(phaseProg), 'UniformOutput', false);
phaseRegCellStr = cellfun(@(x) num2str(x), num2cell(phaseReg), 'UniformOutput', false);
[a, b] = ismember([epochOfInterestPhases{:}], strcat('P', phaseProgCellStr));
[~, x] = sort(b(b~=0));
l = find(a);
phaseProgEpochs = epochsOfInterestFirst + l(x) -1;
[a, b] = ismember([epochOfInterestPhases{:}], strcat('P', phaseRegCellStr));
[~, x] = sort(b(b~=0));
l = find(a);
phaseRegEpochs = epochsOfInterestFirst + l(x) -1;

Z.params.epochsOfInterest = sort(unique([rightEpochs, leftEpochs, posEpochs, negEpochs]));
Z.params.epochsForSelectivity = epochsForSelectivity;
[Z.ROI.roiIndsOfInterest, pValsSum] = extractROIsBySelectivity(Z);
if chooseBestROI
    pValsSum(~Z.ROI.roiIndsOfInterest) = max(pValsSum);
    [~, ind] = min(pValsSum);
    Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    epochAvgAnalysisProg = Z.triggeredResponseAnalysis.triggeredIntensities;
else
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    epochAvgAnalysisProg = Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities;
end
stepsBack = Z.triggeredResponseAnalysis.stepsBack;
fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;

% First split for progressive/regressive epochs and positive/negative
% correlations
% if length(phase)==1
    % If we have one phase we want to find only those epochs that go in
    % that phase
    progEpochsPhased = intersect(phaseProgEpochs, progEpochs, 'stable');
    regEpochsPhased = intersect(phaseRegEpochs, regEpochs, 'stable');
% else
    % While for the moment, if we have more than one phase, we're honestly
    % just gonna pick out all the phases
%     progEpochsPhased = progEpochs;
%     regEpochsPhased = regEpochs;
% end
progPos = intersect(progEpochsPhased, posEpochs, 'stable');
progNeg = intersect(progEpochsPhased, negEpochs, 'stable');
regPos = intersect(regEpochsPhased, posEpochs, 'stable');
regNeg = intersect(regEpochsPhased, negEpochs, 'stable');

progPPlusNull = intersect(regPos, plusEpochs, 'stable');
progPPlusPref = intersect(progPos, plusEpochs, 'stable');
progPMinusNull = intersect(regPos, minusEpochs, 'stable');
progPMinusPref = intersect(progPos, minusEpochs, 'stable');
% It turns out we're only plotting preferred direction when plotting many
% phases, but experience would suggest that the 'preferred' direction
% switches
if true;%length(phase)==1
    progNPlusNull = intersect(regNeg, plusEpochs, 'stable');
    progNPlusPref = intersect(progNeg, plusEpochs, 'stable');
    progNMinusNull = intersect(regNeg, minusEpochs, 'stable');
    progNMinusPref = intersect(progNeg, minusEpochs, 'stable');
else
    progNPlusNull = intersect(progNeg, plusEpochs, 'stable');
    progNPlusPref = intersect(regNeg, plusEpochs, 'stable');
    progNMinusNull = intersect(progNeg, minusEpochs, 'stable');
    progNMinusPref = intersect(regNeg, minusEpochs, 'stable');
end

MakeFigure;
if ~isempty(epochAvgAnalysisProg)
    % Progressive side
    progHandles(1) = subplot(2, 4, 1);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, progPPlusPref, progPPlusNull, [1 0 0], [0 0 1])
    title('Progressive ++')
    text(-0.4, 3, flyEye);
    
    progHandles(2) = subplot(2, 4, 2);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, progPMinusPref, progPMinusNull, [1 0 0], [0 0 1])
    title('Progressive --')
    
    
    progHandles(3) = subplot(2, 4, 5);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, progNPlusPref, progNPlusNull, [1 0 0], [0 0 1])
    title('Progressive +-')
    
    progHandles(4) = subplot(2, 4, 6);
    tp_plotTraceAndAverage(epochAvgAnalysisProg, stepsBack, fsAligned, progNMinusPref, progNMinusNull, [1 0 0], [0 0 1])
    title('Progressive -+')
    text(0.75, 0, Z.ROI.typeFlagName(Z.ROI.roiIndsOfInterest));
end

yLims = [];
cLims = [];
if ~isempty(progHandles)
    for i = 1:length(progHandles)
        yLims = [yLims get(progHandles(i), 'YLim')'];
        potentialImage = findobj(progHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    secondBarDelay = Z.stimulus.params(end).secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = Z.stimulus.params(end).duration/60;
    for i = 1:length(progHandles)
        set(progHandles(i), 'YLim', [minY, maxY]);
        axes(progHandles(i));
        hold on
        potentialImage = findobj(progHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)%strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            minC = min(cLims(1, :));
            maxC = max(cLims(2, :));
            colormap(b2r(minC, maxC));
        end
        plot([barsOff barsOff], [minY maxY], '--k');
        plot([secondBarDelay secondBarDelay], [minY maxY], '--k');
        plot([0 0], [minY maxY], '--k');
        hold off
        
    end
end


% Regressive side
Z.params.epochsForSelectivity = [epochsForSelectivity(end:-1:1)];
Z.params.combinationMethod = 'any';
[Z.ROI.roiIndsOfInterest, pValsSum] = extractROIsBySelectivity(Z);
if chooseBestROI
    pValsSum(~Z.ROI.roiIndsOfInterest) = max(pValsSum);
    [~, ind] = min(pValsSum);
    Z.ROI.roiIndsOfInterest([1:ind-1 ind+1:end]) = false;
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    epochAvgAnalysisReg = Z.triggeredResponseAnalysis.triggeredIntensities;
else
    Z = triggeredResponseAnalysis(Z, 'Bar Pair Plots!');
    epochAvgAnalysisReg = Z.triggeredResponseAnalysis.epochAvgTriggeredIntensities;
end
stepsBack = Z.triggeredResponseAnalysis.stepsBack;
fsAligned = Z.params.fs*Z.triggeredResponseAnalysis.fsFactor;


regPPlusPref = intersect(regPos, plusEpochs, 'stable');
regPPlusNull = intersect(progPos, plusEpochs, 'stable');
regPMinusPref = intersect(regPos, minusEpochs, 'stable');
regPMinusNull = intersect(progPos, minusEpochs, 'stable');
% It turns out we're only plotting preferred direction when plotting many
% phases, but experience would suggest that the 'preferred' direction
% switches
if true;%length(phase)==1
    regNPlusPref = intersect(regNeg, plusEpochs, 'stable');
    regNPlusNull = intersect(progNeg, plusEpochs, 'stable');
    regNMinusPref = intersect(regNeg, minusEpochs, 'stable');
    regNMinusNull = intersect(progNeg, minusEpochs, 'stable');
else
    regNPlusPref = intersect(progNeg, plusEpochs, 'stable');
    regNPlusNull = intersect(regNeg, plusEpochs, 'stable');
    regNMinusPref = intersect(progNeg, minusEpochs, 'stable');
    regNMinusNull = intersect(regNeg, minusEpochs, 'stable');
end

regHandles = [];
if ~isempty(epochAvgAnalysisReg)
    regHandles(1) = subplot(2, 4, 3);
    tp_plotTraceAndAverage(epochAvgAnalysisReg, stepsBack, fsAligned, regPPlusPref, regPPlusNull, [1 0 0], [0 0 1])
    title('Regressive ++')
    
    regHandles(2) = subplot(2, 4, 4);
    tp_plotTraceAndAverage(epochAvgAnalysisReg, stepsBack, fsAligned, regPMinusPref, regPMinusNull, [1 0 0], [0 0 1])
    title('Regressive --')
    
    regHandles(3) = subplot(2, 4, 7);
    tp_plotTraceAndAverage(epochAvgAnalysisReg, stepsBack, fsAligned, regNPlusPref, regNPlusNull, [1 0 0], [0 0 1])
    title('Regressive +-')
    
    regHandles(4) = subplot(2, 4, 8);
    tp_plotTraceAndAverage(epochAvgAnalysisReg, stepsBack, fsAligned, regNMinusPref, regNMinusNull, [1 0 0], [0 0 1])
    title('Regressive -+')
    text(0.75, 0, Z.ROI.typeFlagName(Z.ROI.roiIndsOfInterest));
end

% figHandle = gcf;
% subplotHandles = get(figHandle, 'Children');
yLims = [];
cLims = [];
if ~isempty(regHandles)
    for i = 1:length(regHandles)
        yLims = [yLims get(regHandles(i), 'YLim')'];
        potentialImage = findobj(regHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    secondBarDelay = Z.stimulus.params(end).secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = Z.stimulus.params(end).duration/60;
    for i = 1:length(regHandles)
        set(regHandles(i), 'YLim', [minY, maxY]);
        axes(regHandles(i));
        hold on
        potentialImage = findobj(regHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)%strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            minC = min(cLims(1, :));
            maxC = max(cLims(2, :));
            colormap(b2r(minC, maxC));
        end
        plot([barsOff barsOff], [minY maxY], '--k');
        plot([secondBarDelay secondBarDelay], [minY maxY], '--k');
        plot([0 0], [minY maxY], '--k');
        hold off
        
    end
end
