function [barPairEpochsPhaseAndPolaritySorted, barPairSortingStructure] = SortBarPairPhaseResponse(params, flyEye, barToCenter, regCheck)


epochNames = {params.epochName};
epochsOfInterestFirstLeft = find(~cellfun('isempty', strfind(epochNames, 'L++')), 1, 'first');
epochsOfInterestFirstRight = find(~cellfun('isempty', strfind(epochNames, 'R++')), 1, 'first');
if epochsOfInterestFirstLeft < epochsOfInterestFirstRight
    epochsOfInterestFirst = epochsOfInterestFirstLeft;
else
    epochsOfInterestFirst = epochsOfInterestFirstRight;
end

epochPhases = [params(epochsOfInterestFirst:end).phase];

phase = sort(unique(epochPhases));




epochsOfInterestNames = epochNames(epochsOfInterestFirst:end);
leftEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, 'L')))-1;
rightEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, 'R')))-1;
stillEpochs = epochsOfInterestFirst + find(~cellfun('isempty', strfind(epochsOfInterestNames, 'S')))-1;
fprintf(['This analysis depends on whether the mirrors have been rotated or not!\n '...
    'Currently it''s being analyzed as if they have been rotated']);

% stimulusFunction(stimulusFunction=='_') = ' ';
% titleText = [stimulusFunction ' ' flyEye ' eye'];

if (strcmpi(flyEye, 'right') && ~regCheck) || (strcmpi(flyEye, 'left') && regCheck)
    progEpochs = rightEpochs;
    regEpochs = leftEpochs;
    if barToCenter==2
        phaseProg = num2str(phase);
        doubleBarPhase = 'prog';
        doubleBarNegOrder = 'norm';
        phaseReg = num2str(mod(phase+1, length(phase)));
        singleBarPhase = 'reg';
    elseif barToCenter == 1
        phaseProg = num2str(phase);
        phaseReg = num2str(mod(phase-1, length(phase)));
    else
        phaseProg = num2str(phase);
        phaseReg = num2str(phase);
    end
elseif (strcmpi(flyEye, 'left') && ~regCheck) || (strcmpi(flyEye, 'right') && regCheck)
    progEpochs = leftEpochs;
    regEpochs = rightEpochs;
    if barToCenter==2
        phaseProg = num2str(phase);
        singleBarPhase = 'prog';
        phaseReg = num2str(mod(phase-1, length(phase)));
        doubleBarPhase = 'reg';
        doubleBarNegOrder = 'opp';
    elseif barToCenter == 1
        phaseProg = num2str(phase);
        phaseReg = num2str(mod(phase+1, length(phase)));
    else
        phaseProg = num2str(phase);
        phaseReg = num2str(phase);
    end
else
    error('derp coculdn''t figure out progressive bar pair for ROI')
end

% if (barToCenter == 2 && strcmpi(flyEye, 'left')) || (barToCenter== 1 && strcmpi(flyEye, 'right'))
%     phaseProg = num2str(phase);
%     phaseReg = num2str(mod(phase-1, length(phase)));
% elseif (barToCenter== 1 && strcmpi(flyEye, 'left')) || (barToCenter== 2 && strcmpi(flyEye, 'right'))
%     phaseProg = num2str(phase);
%     phaseReg = num2str(mod(phase+1, length(phase)));
% else
%     phaseProg = num2str(phase);
%     phaseReg = num2str(phase);
% end

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
phaseProgOrderedEpochs = epochsOfInterestFirst + l(x) -1;
[a, b] = ismember([epochOfInterestPhases{:}], strcat('P', phaseRegCellStr));
[~, x] = sort(b(b~=0));
l = find(a);
phaseRegOrderedEpochs = epochsOfInterestFirst + l(x) -1;

stillEpochsPhasedReg = intersect(phaseRegOrderedEpochs, stillEpochs, 'stable');
stillEpochsPhasedProg = intersect(phaseProgOrderedEpochs, stillEpochs, 'stable');
switch singleBarPhase
    case 'reg'
        singleStill = setdiff(stillEpochsPhasedReg, [posEpochs negEpochs], 'stable');
    case 'prog'
        singleStill = setdiff(stillEpochsPhasedProg, [posEpochs negEpochs], 'stable');
end

switch doubleBarPhase
    case 'prog'
        pdoubleStill = intersect(stillEpochsPhasedProg, posEpochs, 'stable');
        ndoubleStill = intersect(stillEpochsPhasedProg, negEpochs, 'stable');
    case 'reg'
        pdoubleStill = intersect(stillEpochsPhasedReg, posEpochs, 'stable');
        ndoubleStill = intersect(stillEpochsPhasedReg, negEpochs, 'stable');
end


% First split for progressive/regressive epochs and positive/negative
% correlations
% if length(phase)==1
    % If we have one phase we want to find only those epochs that go in
    % that phase
    progEpochsPhased = intersect(phaseProgOrderedEpochs, progEpochs, 'stable');
    regEpochsPhased = intersect(phaseRegOrderedEpochs, regEpochs, 'stable');
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
    
    pplusDoubleStill = intersect(pdoubleStill, plusEpochs, 'stable');
    pminusDoubleStill = intersect(pdoubleStill, minusEpochs, 'stable');
    nplusDoubleStill = intersect(ndoubleStill, plusEpochs, 'stable');
    nminusDoubleStill = intersect(ndoubleStill, minusEpochs, 'stable');
    singlePlusStill = intersect(singleStill, plusEpochs, 'stable');
    singleMinusStill = intersect(singleStill, minusEpochs, 'stable');
else
    progNPlusNull = intersect(progNeg, plusEpochs, 'stable');
    progNPlusPref = intersect(regNeg, plusEpochs, 'stable');
    progNMinusNull = intersect(progNeg, minusEpochs, 'stable');
    progNMinusPref = intersect(regNeg, minusEpochs, 'stable');
end

a = dbstack;
warning(['\nThis function has been changed to account for the fact that\n'...
    'consecutively numbered phases in left vs. right bar pairs mean\n'...
    'visual combinations. Specifically, the first bar of R++ P1 will be\n'...
    'at the location of the second bar of R++ P0. This is not true of\n'...
    'the combination of L++ P1 and L++ P0, where in that case the\n'...
    'first bar of L++ *P0* corresponds to the second bar of L++ *P1*.\n'...
    'In order to have the order of the phases reflect the same thing\n'...
    'for both left and right, this has been corrected by inverting the\n'...
    'order of the left phases. This has been checked with BarPairAnalysis.\n'...
    'Calling function is %s.'], a(2).name)

% Turns out that even +- and -+ still are different depending on which
% direction you're preferring--if you want consecutive epochs to
% proceed as usual (look at warning above for an idea of what this
% means)
switch doubleBarNegOrder
    case 'norm'
        % If it's normal we don't have to change anything
    case 'opp'
        tempNMinusDoubleStill = nminusDoubleStill;
        nminusDoubleStill = nplusDoubleStill;
        nplusDoubleStill = tempNMinusDoubleStill;
end

if (strcmpi(flyEye, 'right') && ~regCheck) || (strcmpi(flyEye, 'left') && regCheck)
    % If the preferred direction is right then we don't change anything
elseif (strcmpi(flyEye, 'left') && ~regCheck) || (strcmpi(flyEye, 'right') && regCheck)
    % If preferred
    progPPlusPref = progPPlusPref([1 end:-1:2]);
    progPMinusPref = progPMinusPref([1 end:-1:2]);
    progNPlusPref = progNPlusPref([1 end:-1:2]);
    progNMinusPref = progNMinusPref([1 end:-1:2]);
    progPPlusNull = progPPlusNull([1 end:-1:2]);
    progPMinusNull = progPMinusNull([1 end:-1:2]);
    progNPlusNull = progNPlusNull([1 end:-1:2]);
    progNMinusNull = progNMinusNull([1 end:-1:2]);

    pplusDoubleStill = pplusDoubleStill([1 end:-1:2]);
    pminusDoubleStill = pminusDoubleStill([1 end:-1:2]);
    nplusDoubleStill = nplusDoubleStill([1 end:-1:2]);
    nminusDoubleStill = nminusDoubleStill([1 end:-1:2]);
    singlePlusStill = singlePlusStill([1 end:-1:2]);
    singleMinusStill = singleMinusStill([1 end:-1:2]);
else
    error('I''m confused as to how I got here because this error should''ve been caught earlier, but there you have it');
end

barPairEpochsPhaseAndPolaritySorted.PPlusPref = progPPlusPref;
barPairEpochsPhaseAndPolaritySorted.PMinusPref = progPMinusPref;
barPairEpochsPhaseAndPolaritySorted.NPlusPref = progNPlusPref;
barPairEpochsPhaseAndPolaritySorted.NMinusPref = progNMinusPref;
barPairEpochsPhaseAndPolaritySorted.PPlusNull = progPPlusNull;
barPairEpochsPhaseAndPolaritySorted.PMinusNull = progPMinusNull;
barPairEpochsPhaseAndPolaritySorted.NPlusNull = progNPlusNull;
barPairEpochsPhaseAndPolaritySorted.NMinusNull = progNMinusNull;

barPairEpochsPhaseAndPolaritySorted.PlusSingle = singlePlusStill;
barPairEpochsPhaseAndPolaritySorted.MinusSingle = singleMinusStill;
barPairEpochsPhaseAndPolaritySorted.PPlusDouble = pplusDoubleStill;
barPairEpochsPhaseAndPolaritySorted.PMinusDouble = pminusDoubleStill;
barPairEpochsPhaseAndPolaritySorted.NPlusDouble = nplusDoubleStill;
barPairEpochsPhaseAndPolaritySorted.NMinusDouble = nminusDoubleStill;