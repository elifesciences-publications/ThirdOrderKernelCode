function [out, outDesc] = ComputeBarPairResponseMatrix_catherine(roiAveragedResponses, barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, realDuration, initialDuration)
% We take in a mirrorCheck because everything gets mirrored for the left
% eye--we could foresee things getting mirrored for the regressive layer of
% the right eye as well, hence it's called 'mirror check'

sortingMatrix = barPairSortingStructure.matrix;
prefDir = 1;
nullDir = -1;
nextNearestDir = 2;
neighDir = 1;
% ['The columns of the matrix are sequential epochs from interleave.\n'...
%                         'The rows of the matrix are as follows:\n'...
%                         'bar phase\n'...
%                         'direction of motion\n'...
%                         'bar 1 contrast\n'...
%                         'bar 2 contrast\n'...
%                         'bar 2 delay\n'...
%                         'bar 1 location\n'...
%                         'bar 2 location']

numPhases = size(roiAveragedResponses, 1)/2;
if mirrorCheck 
    % This line serves to mirror the phases--when going to the left is
    % important, phases going to the right of 0,1,2,3 should become
    % phases 0,3,2,1
    sortingMatrix(1, :) = abs(mod(sortingMatrix(1, :), -numPhases));
    % This line serves to correctly define the phases for bars one
    % apart for the left-going epochs. Initially these bars were
    % defined so that the phase of their leftmost bar matched the phase
    % of the first bar appearing in a directional pairing. The same is
    % done here, but now their right most bar matches (because we've
    % mirrored)
    sortingMatrix(1, sortingMatrix(2, :)==2) = mod(sortingMatrix(1, sortingMatrix(2, :)==2)-1, numPhases);
    % This line serves to correctly define the phases for the single bar,
    % since it has to be aligned to the first bar but is aligned to the
    % second in leftward terms
    sortingMatrix(1, sortingMatrix(4, :)==0) = mod(sortingMatrix(1, sortingMatrix(4, :)==0)+1, numPhases);
    % These lines shift the bar locations to their correct location based
    % on leftwards movement (exactly what happened for the overall phases
    % in the first line, except you subtract one because the phases are
    % initially aligned to the first bar of the rightwards motion--so you
    % subtract one to align them to the first bar of the leftwards motion)
    sortingMatrix(6, :) = abs(mod(sortingMatrix(6, :)-1, -numPhases));
    sortingMatrix(7, :) = abs(mod(sortingMatrix(7, :)-1, -numPhases));
    % These lines switch the location of bar 1 & bar 2 for next-nearest
    % neighbor bars and nearest neighbor bars because when we're going
    % leftwards the first bar switches (same reason we had to change the
    % phase of these, and the same reason we'll be switching up the
    % contrast order below
    tempBar1Location = sortingMatrix(6, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0);
    tempBar2Location = sortingMatrix(7, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0);
    sortingMatrix(6, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0) = tempBar2Location;
    sortingMatrix(7, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0) = tempBar1Location;
    % These lines switch the contrast of bar 1 & bar 2 for next-nearest
    % neighbor bars because when we're going leftwards the first bar
    % switches (same reason we had to change the phase of these)
    tempBar1Contrast = sortingMatrix(3, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0);
    tempBar2Contrast = sortingMatrix(4, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0);
    sortingMatrix(3, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0) = tempBar2Contrast;
    sortingMatrix(4, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & sortingMatrix(3, :).*sortingMatrix(4, :)~=0) = tempBar1Contrast;
    
    prefDir = -1;
    nullDir = 1;
end

PPlusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)~=0);
PPlusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
PMinusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)~=0);
PMinusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
NPlusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)~=0);
NPlusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);
NMinusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)~=0);
NMinusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);


% TODO INVERT PHASE ORDER FOR MIRRORCHECK

PlusSingle = find(sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0);
MinusSingle = find(sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0);

PPlusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
PMinusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
NPlusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);
NMinusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);

PPlusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)==0);
PMinusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)==0);
NPlusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)==0);
NMinusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)==0);


if mirrorCheck
    % Use THE PPlusPref phases to reorder things in increasing order--gonna
    % be annoying cuz you have to do this for each one...
    [~, sortIndDir] = sort(sortingMatrix(1, PPlusPref));
    PPlusPref = PPlusPref(sortIndDir);
    PPlusNull = PPlusNull(sortIndDir);
    PMinusPref = PMinusPref(sortIndDir);
    PMinusNull = PMinusNull(sortIndDir);
    NPlusPref = NPlusPref(sortIndDir);
    NPlusNull = NPlusNull(sortIndDir);
    NMinusPref = NMinusPref(sortIndDir);
    NMinusNull = NMinusNull(sortIndDir);
    
    % Do the same for the singles--except use the PlusSingle
    [~, sortIndSing] = sort(sortingMatrix(1, PlusSingle));
    PlusSingle = PlusSingle(sortIndSing);
    MinusSingle = MinusSingle(sortIndSing);
    
    % Do the same for the doubles--again, use PPlusDouble this time
    [~, sortIndDoub] = sort(sortingMatrix(1, PPlusDouble));
    PPlusDouble = PPlusDouble(sortIndDoub);
    PMinusDouble = PMinusDouble(sortIndDoub);
    NPlusDouble = NPlusDouble(sortIndDoub);
    NMinusDouble = NMinusDouble(sortIndDoub);
    
    % Do the same for the neighboring bars--once again, use PPlusNeigh;
    % PPlusNeigh might be empty when we're doing the 40 degree bars and it
    % doesn't actually exist--in that case use NPlusNeigh
    if isempty(PPlusNeigh)
        [~, sortIndNeigh] = sort(sortingMatrix(1, NPlusNeigh));
        NPlusNeigh = NPlusNeigh(sortIndNeigh);
        NMinusNeigh = NMinusNeigh(sortIndNeigh);
    else
        [~, sortIndNeigh] = sort(sortingMatrix(1, PPlusNeigh));
        PPlusNeigh = PPlusNeigh(sortIndNeigh);
        PMinusNeigh = PMinusNeigh(sortIndNeigh);
        NPlusNeigh = NPlusNeigh(sortIndNeigh);
        NMinusNeigh = NMinusNeigh(sortIndNeigh);
    end
end

% barToCenter = 0 is default... for directional ones anyway; not really
% defined for next-nearest anyway...
if barToCenter == 2
    % If we center bar 2, we're going to put the middle space of the next
    % nearest bars at bar 2's location, and we're going to put the single
    % bar in the location of bar 2 as well.
    bar2LocNull = sortingMatrix(7, PPlusNull);
    bar2LocPref = sortingMatrix(7, PPlusPref);
    
    [~, bestAlign] = max(xcorr(bar2LocPref, bar2LocNull));
    nullShift = mod(bestAlign, length(PPlusNull));
    
    % Now to the nearest neighbor shift
    bar1LocNN = sortingMatrix(6, PPlusDouble);
    bar2LocNN = mod(bar1LocNN+1, length(PPlusDouble));
    [~, bestAlign] = max(xcorr(bar2LocPref, bar2LocNN));
    nnShift = mod(bestAlign, length(PPlusNull));
    
    % Now to single bar shift
    bar1LocS = sortingMatrix(6, PlusSingle);
    [~, bestAlign] = max(xcorr(bar2LocPref, bar1LocS));
    sShift = mod(bestAlign, length(PPlusNull));
elseif barToCenter == 1
    % If we center bar 1, we're also going to put the middle space of the
    % next nearest bars at bar 1's location, and we're going to put the
    % single bar in the location of bar 1 as well
    error('We''re not done with this yet!!');
end 

% We default these in case there are some epochs that are empty; this
% ensures that errors don't happen later on having to do with circshift and
% empty shifts
if isempty(nullShift)
    nullShift = 0;
end
if isempty(nnShift)
    nnShift = 0;
end
if isempty(sShift)
    sShift = 0;
end




shift = 0;
% NOTE this optimal phase has to be well aligned with the
% PlotBarPairROISummary has so that the plotted responses can be aligned
% with the bar pair xt plots
optimalPhase = 4; % This is phase 3 on the plot, because those are zero indexed

switch optimalBar
    case 'PlusSingle'
        singlePlusStillResp = cat(2, roiAveragedResponses{PlusSingle, 1})';
        singleChecker = circshift(singlePlusStillResp, sShift);
        meanPlusSingle = mean(singleChecker, 2);
        [~, maxLoc] = max(meanPlusSingle);
        shift = mod(optimalPhase - maxLoc, numPhases);
    case 'MinusSingle'
        singleMinusStillResp = cat(2, roiAveragedResponses{MinusSingle, 1})';
        singleChecker = circshift(singleMinusStillResp, sShift);
        meanMinusSingle = mean(singleChecker(:, initialDuration:initialDuration+realDuration), 2);
        [~, maxLoc] = max(meanMinusSingle);
        numPhases = size(meanMinusSingle, 1);
        shift = mod(optimalPhase - maxLoc, numPhases);
end

nullShift = nullShift + shift;
nnShift = nnShift + shift;
nShift = shift;
sShift = sShift + shift;

pplusPrefResp = cat(2, roiAveragedResponses{PPlusPref, 1})';
pplusPrefResp = circshift(pplusPrefResp, shift);

pminusPrefResp = cat(2, roiAveragedResponses{PMinusPref, 1})';
pminusPrefResp = circshift(pminusPrefResp, shift);

nplusPrefResp = cat(2, roiAveragedResponses{NPlusPref, 1})';
nplusPrefResp = circshift(nplusPrefResp, shift);

nminusPrefResp = cat(2, roiAveragedResponses{NMinusPref, 1})';
nminusPrefResp = circshift(nminusPrefResp, shift);

pplusNullResp = cat(2, roiAveragedResponses{PPlusNull, 1})';
pplusNullResp = circshift(pplusNullResp, nullShift);

pminusNullResp = cat(2, roiAveragedResponses{PMinusNull, 1})';
pminusNullResp = circshift(pminusNullResp, nullShift);

nplusNullResp = cat(2, roiAveragedResponses{NPlusNull, 1})';
nplusNullResp = circshift(nplusNullResp, nullShift);

nminusNullResp = cat(2, roiAveragedResponses{NMinusNull, 1})';
nminusNullResp = circshift(nminusNullResp, nullShift);

pplusDoubleResp = cat(2, roiAveragedResponses{PPlusDouble, 1})';
pplusDoubleResp = circshift(pplusDoubleResp, nnShift);

pminusDoubleResp = cat(2, roiAveragedResponses{PMinusDouble, 1})';
pminusDoubleResp = circshift(pminusDoubleResp, nnShift);

nplusDoubleResp = cat(2, roiAveragedResponses{NPlusDouble, 1})';
nplusDoubleResp = circshift(nplusDoubleResp, nnShift);

nminusDoubleResp = cat(2, roiAveragedResponses{NMinusDouble, 1})';
nminusDoubleResp = circshift(nminusDoubleResp, nnShift);

singlePlusStillResp = cat(2, roiAveragedResponses{PlusSingle, 1})';
singlePlusStillResp = circshift(singlePlusStillResp, sShift);

singleMinusStillResp = cat(2, roiAveragedResponses{MinusSingle, 1})';
singleMinusStillResp = circshift(singleMinusStillResp, sShift);

switch optimalBar
    case 'PlusSingle'
        pplusNeighResp = cat(2, roiAveragedResponses{PPlusNeigh, 1})';
        pplusNeighResp = circshift(pplusNeighResp, nShift);
        
        nminusNeighResp = cat(2, roiAveragedResponses{NMinusNeigh, 1})';
        nminusNeighResp = circshift(nminusNeighResp, nShift);
        
        % Dealing with the fact that neighboring bars have to be
        % differently shifted if they're to be offset
        nShift = shift - 1;        
        pminusNeighResp = cat(2, roiAveragedResponses{PMinusNeigh, 1})';
        pminusNeighResp = circshift(pminusNeighResp, nShift);
        
        nplusNeighResp = cat(2, roiAveragedResponses{NPlusNeigh, 1})';
        nplusNeighResp = circshift(nplusNeighResp, nShift);
    case 'MinusSingle'
        nplusNeighResp = cat(2, roiAveragedResponses{NPlusNeigh, 1})';
        nplusNeighResp = circshift(nplusNeighResp, nShift);
        
        pminusNeighResp = cat(2, roiAveragedResponses{PMinusNeigh, 1})';
        pminusNeighResp = circshift(pminusNeighResp, nShift);
        
        % Dealing with the fact that neighboring bars have to be
        % differently shifted if they're to be offset
        nShift = shift - 1;
        nminusNeighResp = cat(2, roiAveragedResponses{NMinusNeigh, 1})';
        nminusNeighResp = circshift(nminusNeighResp, nShift);
        
        pplusNeighResp = cat(2, roiAveragedResponses{PPlusNeigh, 1})';
        pplusNeighResp = circshift(pplusNeighResp, nShift);
end




out = [pplusPrefResp; pplusNullResp; pminusPrefResp;   pminusNullResp;   nplusPrefResp; nplusNullResp; nminusPrefResp;  nminusNullResp; pplusDoubleResp; pminusDoubleResp; nplusDoubleResp; nminusDoubleResp; pplusNeighResp; pminusNeighResp; nplusNeighResp; nminusNeighResp; singlePlusStillResp; singleMinusStillResp];
availableDescriptions = {'++ Pref Dir', '++ Null Dir', '-- Pref Dir', '-- Null Dir',...
    '+- Pref Dir', '+- Null Dir', '-+ Pref Dir', '-+ Null Dir',...
    '+ + Still', '- - Still', '+ - Still', '- + Still'...
    '++ Still', '-- Still', '+- Still', '-+ Still'...
    '+ Still', '- Still'}';
matsUsed = {pplusPrefResp; pplusNullResp; pminusPrefResp;   pminusNullResp;   nplusPrefResp; nplusNullResp; nminusPrefResp;  nminusNullResp; pplusDoubleResp; pminusDoubleResp; nplusDoubleResp; nminusDoubleResp; pplusNeighResp; pminusNeighResp; nplusNeighResp; nminusNeighResp; singlePlusStillResp; singleMinusStillResp};
descriptionsUsed = cellfun(@(respMat) ~isempty(respMat), matsUsed);
rowsPerMat = cellfun(@(respMat) size(respMat, 1), matsUsed);
startingRows = cumsum([0; rowsPerMat]);
startingRows = startingRows(1:end-1)+1;
descriptionCell = [availableDescriptions num2cell(rowsPerMat) num2cell(startingRows)];
outDesc = descriptionCell(descriptionsUsed, :);
