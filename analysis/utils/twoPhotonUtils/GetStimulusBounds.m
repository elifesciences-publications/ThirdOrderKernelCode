function [epochBegin, epochEnd, endFlash, flashBeginInd] = GetStimulusBounds(photoDiode, highResLinesPerFrame, dataRate, linescan)
% Grabs the beginning and end of the stimulus presentation given a
% photodiode stream, as well as the location of the end flash, which may
% sometimes be ambiguous and can thus be stated when new ROIs are forced by
% checking whether this output is a vector or not

maxPD = max(photoDiode);
maxPDPerc = 0.2;
photoDiodeClean = zeros(size(photoDiode));
photoDiodeClean(photoDiode>maxPD*maxPDPerc) = 1;
photoDiodeDiff = diff(photoDiodeClean);
%             maxDiff = max(photoDiodeDiff);
%             maxFrac = 10;
flashBegin = photoDiodeDiff>0;
flashEnd = photoDiodeDiff<0;

flashBeginInd = find(flashBegin);
flashEndInd = find(flashEnd);

flashDiffs = flashEndInd-flashBeginInd;
projectorFramesPerFlash = flashDiffs/highResLinesPerFrame/dataRate*60; %60Hz is projector rate
[endFlash, indOccur] = find(projectorFramesPerFlash>20);
%             flashBegin = diff(flashes)==1;
% continue
epochBegin = (find(flashBegin,1,'first'));
if length(endFlash)==2 && diff(endFlash)>3
    epochEnd = flashBeginInd(endFlash(2));
elseif length(endFlash)>2
    warning('There are more than two epochs where there were more than 20 flashes; not sure what to do here');
    keyboard
else
    epochEnd = flashBeginInd(endFlash(1));
end

if ~linescan
    epochBegin = epochBegin/highResLinesPerFrame;
    epochEnd = epochEnd/highResLinesPerFrame;
end