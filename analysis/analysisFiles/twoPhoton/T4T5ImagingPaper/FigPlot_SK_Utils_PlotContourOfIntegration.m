function FigPlot_SK_Utils_PlotContourOfIntegration(maxTau,dtMax,tMax,direction)
kernelWindow = GenKernelWindowMask_2o(maxTau,dtMax,tMax,direction);
roiBoundaries = bwboundaries(kernelWindow,8,'noholes');
plot( roiBoundaries{1}(:,2),roiBoundaries{1}(:,1),'lineWidth',2,'color',[0,0,0]);
hold off
end