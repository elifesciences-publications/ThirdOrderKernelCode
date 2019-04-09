function [barPairSortingStructure, numPhases, epochsOfInterestFirst] = SortBarPairBarLocations(params, epochsOfInterestFirst)

if nargin<2
    epochNames = {params.epochName};
    epochsOfInterestFirstLeft = find(~cellfun('isempty', strfind(epochNames, 'L++')), 1, 'first');
    epochsOfInterestFirstRight = find(~cellfun('isempty', strfind(epochNames, 'R++')), 1, 'first');
    if epochsOfInterestFirstLeft < epochsOfInterestFirstRight
        epochsOfInterestFirst = epochsOfInterestFirstLeft;
    else
        epochsOfInterestFirst = epochsOfInterestFirstRight;
    end
end

epochPhases = [params(epochsOfInterestFirst:end).phase];
epochDirections = [params(epochsOfInterestFirst:end).direction];
epochContrastBar1 = [params(epochsOfInterestFirst:end).firstBarContrast];
epochContrastBar2 = [params(epochsOfInterestFirst:end).secondBarContrast];
epochDelayBar2 = [params(epochsOfInterestFirst:end).secondBarDelay];

barWidth = [params(epochsOfInterestFirst:end).barWd];
spaceWidth = [params(epochsOfInterestFirst:end).spaceWd];
if isfield(params, 'phaseShift')
    phaseWidth = [params(epochsOfInterestFirst:end).phaseShift];
else
    phaseWidth = [params(epochsOfInterestFirst:end).barWd];
end

if isfield(params, 'firstBarDelay')
    epochDelayBar1 = [params(epochsOfInterestFirst:end).firstBarDelay];
else
    epochDelayBar1 = zeros(size(epochDelayBar2)); % It was always 0 before this parameter was here...
end

if isfield(params, 'firstBarOff')
    epochBar1Off = [params(epochsOfInterestFirst:end).firstBarOff];
    epochBar2Off = [params(epochsOfInterestFirst:end).secondBarOff];
else
    epochBar1Off = [params(epochsOfInterestFirst:end).duration]/60; % They always turned off together, at the end, before there was a firstBarOff field
    epochBar2Off = [params(epochsOfInterestFirst:end).duration]/60;
end
    
phase = sort(unique(epochPhases));
numPhases = length(phase);

% On all but leftward directions, the first bar is at the phase
bar1Location = epochPhases;
bar1Location(epochDirections==-1) = mod(bar1Location(epochDirections==-1)+1, max(phase)+1);
bar2Location = mod(epochPhases+1, max(phase)+1);
% In leftward direction, bar2 is at the location of the phase
bar2Location(epochDirections==-1) = epochPhases(epochDirections==-1);
% When split is by 2, the bar2 location is one next to the previous bar 2
% location
bar2Location(epochDirections==2) = mod(bar2Location(epochDirections==2)+1, max(phase)+1);


barPairSortingStructure.description = sprintf(['The columns of the matrix are sequential epochs from interleave.\n'...
                        'The rows of the matrix are as follows:\n'...
                        'bar phase\n'...
                        'direction of motion\n'...
                        'bar 1 contrast\n'...
                        'bar 2 contrast\n'...
                        'bar 2 delay\n'...
                        'bar 1 location\n'...
                        'bar 2 location\n'...
                        'bar width\n'...
                        'space width\n'...
                        'phase width\n'...
                        'bar 1 delay\n'...
                        'bar 1 off\n'...
                        'bar 2 off']);
barPairSortingStructure.matrix = [epochPhases; epochDirections; epochContrastBar1; epochContrastBar2; epochDelayBar2; bar1Location; bar2Location; barWidth; spaceWidth; phaseWidth; epochDelayBar1; epochBar1Off; epochBar2Off];
barPairSortingStructure.phase = epochPhases;
barPairSortingStructure.direction = epochDirections;
barPairSortingStructure.bar1contrast = epochContrastBar1;
barPairSortingStructure.bar2contrast = epochContrastBar2;
barPairSortingStructure.bar1delay = epochDelayBar1;
barPairSortingStructure.bar2delay = epochDelayBar2;
barPairSortingStructure.bar1Location = bar1Location;
barPairSortingStructure.bar2Location = bar2Location;
barPairSortingStructure.barWidth = barWidth;
barPairSortingStructure.spaceWidth = spaceWidth;
barPairSortingStructure.phaseWidth = phaseWidth;
barPairSortingStructure.epochBar1Off = epochBar1Off;
barPairSortingStructure.epochBar2Off = epochBar2Off;