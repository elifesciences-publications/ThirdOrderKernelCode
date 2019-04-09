function out = CalculatedBarPairResponseMatrix(roiAveragedResponses, plottingEpochs, optimalEpochField, timeShift, duration,barsOff,secondBarDelay)

PPlusPref = plottingEpochs.PPlusPref;
PPlusNull = plottingEpochs.PPlusNull;
PMinusPref = plottingEpochs.PMinusPref;
PMinusNull = plottingEpochs.PMinusNull;
NPlusPref = plottingEpochs.NPlusPref;
NPlusNull = plottingEpochs.NPlusNull;
NMinusPref = plottingEpochs.NMinusPref;
NMinusNull = plottingEpochs.NMinusNull;

PlusSingle = plottingEpochs.PlusSingle;
MinusSingle = plottingEpochs.MinusSingle;

PPlusDouble = plottingEpochs.PPlusDouble;
PMinusDouble = plottingEpochs.PMinusDouble;
NPlusDouble = plottingEpochs.NPlusDouble;
NMinusDouble = plottingEpochs.NMinusDouble;

optimalResponseBlock = plottingEpochs.(optimalEpochField);
if nargin<4
    timeShift = 0;
    % The key here is that duration and barsOff are equal so you're
    % grabbing all the responses--they could both be 1000 for all it
    % mattered.
    duration = 1;
    barsOff = 1;
    secondBarDelay = 0;
    tVals = linspace(timeShift, timeShift+duration, size([roiAveragedResponses{optimalResponseBlock, 1}], 1));
else
    tVals = linspace(timeShift, timeShift+duration, size([roiAveragedResponses{optimalResponseBlock, 1}], 1));
end

if nargin<3
    % We try to align them all to the 3rd bar, assuming that the preferred
    % direction positive correlations will have the maximum responses
    pplusPrefResp = cat(2, roiAveragedResponses{PPlusPref, 1});
    pminusPrefResp = cat(2, roiAveragedResponses{PMinusPref, 1});
    meanPPlusPref = mean(pplusPrefResp(tVals>=secondBarDelay & tVals<=barsOff, :)-pplusPrefResp(tVals>=0 & tVals<=secondBarDelay, :));
    meanPMinusPref = mean(pminusPrefResp(tVals>=secondBarDelay & tVals<=barsOff, :)-pminusPrefResp(tVals>=0 & tVals<=secondBarDelay, :));
    [maxPP, locMPP] = max(meanPPlusPref);
    [maxPM, locMPM] = max(meanPMinusPref);
    
    numPhases = length(PPlusPref);
    halfPoint = round(numPhases/2);
    if maxPP>=maxPM
        shift = halfPoint - locMPP;
    else
        shift = halfPoint - locMPM;
    end
    % shift
else
    % We try to align them all to the 3rd bar, using the selectivity based
    % block of responses to determine where the maximal response should be
    optimalBlockResponses = cat(2, roiAveragedResponses{optimalResponseBlock, 1});
    meanOptimalResponse = mean(optimalBlockResponses(tVals>=secondBarDelay&tVals<=barsOff, :))-mean(optimalBlockResponses(tVals>=0&tVals<=secondBarDelay, :));
    [~, locMOR] = max(meanOptimalResponse);
    
    numPhases = length(PPlusPref);
    halfPoint = round(numPhases/2);
    
    shift = halfPoint - locMOR;
    % shift
%     %**** JUST FOR NOW TRY TO BE BLIND ABOUT PLUS OR MINUS SINGLE ****%
%       % *** THIS DOESN'T WORK *** %
%      meanPlusSingle = mean(cat(2, roiAveragedResponses{PlusSingle, 1}));
%     meanMinusSingle = mean(cat(2, roiAveragedResponses{MinusSingle, 1}));
%     [maxPP, locMPP] = max(meanPlusSingle);
%     [maxPM, locMPM] = max(meanMinusSingle);
%     
%     numPhases = length(PPlusPref);
%     halfPoint = round(numPhases/2);
%     if maxPP>=maxPM
%         shift = halfPoint - locMPP;
%     else
%         shift = halfPoint - locMPM;
%     end
% 
% 
%     numPhases = length(PPlusPref);
%     halfPoint = round(numPhases/2);
%     
%     if maxPP>=maxPM
%         shift = halfPoint - locMPP;
%     else
%         shift = halfPoint - locMPM;
%     end
end


if ~isempty(roiAveragedResponses)
    pplusPrefResp = cat(2, roiAveragedResponses{PPlusPref, 1})';
    pplusPrefResp = circshift(pplusPrefResp, shift);
    
    pminusPrefResp = cat(2, roiAveragedResponses{PMinusPref, 1})';
    pminusPrefResp = circshift(pminusPrefResp, shift);
    
    nplusPrefResp = cat(2, roiAveragedResponses{NPlusPref, 1})';
    nplusPrefResp = circshift(nplusPrefResp, shift);
    
    nminusPrefResp = cat(2, roiAveragedResponses{NMinusPref, 1})';
    nminusPrefResp = circshift(nminusPrefResp, shift);
    
    pplusNullResp = cat(2, roiAveragedResponses{PPlusNull, 1})';
    pplusNullResp = circshift(pplusNullResp, shift);
    
    pminusNullResp = cat(2, roiAveragedResponses{PMinusNull, 1})';
    pminusNullResp = circshift(pminusNullResp, shift);
    
    nplusNullResp = cat(2, roiAveragedResponses{NPlusNull, 1})';
    nplusNullResp = circshift(nplusNullResp, shift);
    
    nminusNullResp = cat(2, roiAveragedResponses{NMinusNull, 1})';
    nminusNullResp = circshift(nminusNullResp, shift);
    
    pplusDoubleResp = cat(2, roiAveragedResponses{PPlusDouble, 1})';
    pplusDoubleResp = circshift(pplusDoubleResp, shift);
    
    pminusDoubleResp = cat(2, roiAveragedResponses{PMinusDouble, 1})';
    pminusDoubleResp = circshift(pminusDoubleResp, shift);
    
    nplusDoubleResp = cat(2, roiAveragedResponses{NPlusDouble, 1})';
    nplusDoubleResp = circshift(nplusDoubleResp, shift);
    
    nminusDoubleResp = cat(2, roiAveragedResponses{NMinusDouble, 1})';
    nminusDoubleResp = circshift(nminusDoubleResp, shift);

    
    singlePlusStillResp = cat(2, roiAveragedResponses{PlusSingle, 1})';
    singlePlusStillResp = circshift(singlePlusStillResp, shift);
    
    singleMinusStillResp = cat(2, roiAveragedResponses{MinusSingle, 1})';
    singleMinusStillResp = circshift(singleMinusStillResp, shift);
    
    out = [pplusPrefResp; pplusNullResp; pminusPrefResp;   pminusNullResp;   nplusPrefResp; nplusNullResp; nminusPrefResp;  nminusNullResp; pplusDoubleResp; pminusDoubleResp; nplusDoubleResp; nminusDoubleResp; singlePlusStillResp; singleMinusStillResp];
    
    
end