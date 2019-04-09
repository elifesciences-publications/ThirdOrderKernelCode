% predict frequency tuning curve from second order kernel.
% [meanKernel]= roiAnalysis_AverageSecondKernel(roiData,'dx',dx,'meanMethod',meanMethod);

[meanKernel]= roiAnalysis_AverageSecondKernel(roiDataUseEdge,'dx',1);
omegaTemp = 2.^(-3:1/3:3);
% omegaTemp = (1.3).^(-6:7);
omegaBank = [-fliplr(omegaTemp),omegaTemp];
lambdaBank = [30]; % might be very slow...
omegaBank(omegaBank == 0) = [];
barWidth = 10;
%
% if filterType >= 2
%     you can not run this with your current data...
respMeanSec = zeros(length(omegaBank),length(lambdaBank),4);
for tt = 1:1:4
    secondFilter = meanKernel(:,tt);
    respMeanSec(:,:,tt) = FrequencyTuningCurveSecond(secondFilter,omegaBank,lambdaBank,barWidth);
end
%    PlotFTResponse(meanResp,omega,lambda);
titleStr = {'T4Pro','T4Reg','T5Pro','T5Red'};
for tt = 1:1:4
    MakeFigure;
    subplot(2,2,1);
    quickViewOneKernel(meanKernel(:,tt),2);
    subplot(2,1,2);
    PlotFTResponse(respMeanSec(:,:,tt),omegaBank,lambdaBank);
    
%     MySaveFig_Juyue(gcf,'FrequencyTuning',['5',titleStr{tt}],'nFigSave',1,'fileType',{'fig'});
    %     quadKernels = meanKernel(:,tt);
    %     HollyTuning;
end
addpath(genpath('C:\Users\Clark Lab\Documents\modeling\Holly\modelResp\predictionFunctions'));