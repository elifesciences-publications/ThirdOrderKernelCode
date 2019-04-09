function [respFromCRF] = FigPlot_PaperRevision_TF_ForSecondOrderKernel(meanKernelFourType)
nType = 4;
omegaTemp = [0.25,0.375,0.5,0.75,1,1.5,2,3,4,6,8,12,16,24,32,48,64];
omegaBank = [-fliplr(omegaTemp),omegaTemp];
lambdaBank = [30]; % might be very slow...
omegaBank(omegaBank == 0) = [];
barWidth = 5;
dt = [-8:1:8]';
tMax = 20;
gliderResp = zeros(size(dt,1),4);
for tt = 1:1:nType
    gliderResp(:,tt) = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(meanKernelFourType(:,tt),'dt',dt,'tMax',tMax);
end

respFromCRF = cell(nType,1);
for tt = 1:1:nType
    respFromCRF{tt} = FrequencyTuningCurveSecond_Analytical(gliderResp(:,tt),omegaBank,lambdaBank,dt,tMax,barWidth);
end

MakeFigure;
typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
for tt = 1:1:nType
    subplot(4,1,tt);
    PlotFTResponse(respFromCRF{tt},omegaBank,lambdaBank);
    ylabel('second kernel prediction');
    title(typeStr{tt});
end

end