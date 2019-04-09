% find the individual kernels you use the other day...

% first, you has already find the kernel you use to generate those figures.
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
dataLoadPath = [kernelFolder,'\T4T5_Imaging_Paper\IndividualFirstOrderKernel\individualSecondKernel.mat'];

load(dataLoadPath);
roiData = roiFigPlot2Individual;
saveFigFlag = false;
FigPlot2_IndividualKernelAndTrace(roiData,'saveFigFlag',saveFigFlag,'roiSelectionMethod','manual','MainName','Fig2_a_NoShift');
FigPlot2_IndividualKernelAndTrace(roiData,'saveFigFlag',saveFigFlag,'roiSelectionMethod','manual','MainName','Fig2_NoCLim','kernelOrZ','kernel','limPreSetFlag',false);


