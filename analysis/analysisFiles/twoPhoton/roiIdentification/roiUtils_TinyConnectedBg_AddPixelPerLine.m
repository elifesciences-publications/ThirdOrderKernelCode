function numPixelPerRegion = roiUtils_TinyConnectedBg_AddPixelPerLine(numPixelPerLine,numLines)
% shift them and add them together...
startInd = 1:1:numLines;
endInd = length(numPixelPerLine) - numLines : 1:length(numPixelPerLine);
numPixelPerLinMat_Shift = zeros( length(numPixelPerLine) - numLines,numLines);
for ii = 1:1:numLines
numPixelPerLinMat_Shift(:,ii) = numPixelPerLine(startInd(ii):endInd(ii));
end
numPixelPerRegion = sum(numPixelPerLinMat_Shift,2);
end
