function FigPlot1_PlotScaleBar(Z,verInd,horInd)
imageDescriptionPath = fullfile(Z.params.filename,'imageDescription.mat');
imageDescription = load(imageDescriptionPath);
imageDescription = imageDescription.state;
dataRate = imageDescription.acq.frameRate; % imaging frequency
zoomLevel = imageDescription.acq.zoomFactor;
PixelPerMicron = zoomLevel * 0.4;
pixelPerScale = round(5 * PixelPerMicron); % 5 micron

startY = round(0.9 * length(verInd));
endY = startY ;
endX = round(0.9 * length(horInd));
startX  = endX -  pixelPerScale;
hold on
line([startX,endX],[startY,endY], 'LineWidth',10,'color',[1,1,1]);
hold off
end