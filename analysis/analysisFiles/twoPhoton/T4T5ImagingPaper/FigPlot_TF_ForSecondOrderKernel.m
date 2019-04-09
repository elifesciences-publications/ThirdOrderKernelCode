function FigPlot_TF_ForSecondOrderKernel(meanKernelFourType)
nType = 4;
omegaTemp = [0.9375,1.875,3.75,7.5];
omegaBank = [-fliplr(omegaTemp),omegaTemp];
lambdaBank = [30,45,60]; % might be very slow...
omegaBank(omegaBank == 0) = [];
barWidth = 5;
dt = [-8:1:8]';
tMax = 20;
gliderResp = zeros(size(dt,1),4);
for tt = 1:1:nType
    gliderResp(:,tt) = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(meanKernelFourType(:,tt),'dt',dt,'tMax',tMax);
end

meanResp = cell(nType,1);
meanRespFromCRF = cell(nType,1);
% chop the kernel before put that into to match the glider prediction...
maxTauSquared = size(meanKernelFourType,1);
maxTau = round(sqrt(maxTauSquared));
windMask = GenKernelWindowMask_2o(maxTau,max(dt),tMax,0);
winMask = windMask(:);

for tt = 1:1:nType
    kernel = meanKernelFourType(:,tt);
    % can you sample those frequency? how do you determine your
    meanResp{tt} = FrequencyTuningCurveSecond(kernel .* winMask,omegaBank,lambdaBank,barWidth);
    meanRespFromCRF{tt} = FrequencyTuningCurveSecond_Analytical(gliderResp(:,tt),omegaBank,lambdaBank,dt,tMax,barWidth);

end

MakeFigure;
typeStr = {'T4 Pro','T4 Reg','T5 Pro','T5 Reg'};
for tt = 1:1:nType
    subplot(3,4,tt);
    PlotFTResponse(meanResp{tt},omegaBank,lambdaBank);
    ylabel('second order kernel convolve with stim');
    title(typeStr{tt})
    subplot(3,4,tt + 4);
    PlotFTResponse(meanRespFromCRF{tt},omegaBank,lambdaBank);
    ylabel('analytical response');
    title(typeStr{tt});
    subplot(3,4,tt + 8);
    PlotFTResponse(meanRespFromCRF{tt} - meanResp{tt},omegaBank,lambdaBank);
    ylabel('analytical response from CRF -  second order prediction');
    title(typeStr{tt});
end

end