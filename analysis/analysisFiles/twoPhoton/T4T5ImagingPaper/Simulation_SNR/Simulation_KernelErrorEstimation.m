function Simulation_KernelErrorEstimation(roiData,roiStd)
nRoi = length(roiData);
% actually, it is easier to get matrix at first.
roi = roiData{1};
[maxTauFirst,nMultiBars] = size(roi.filterInfo.firstKernel.Original);
[maxTauSecondSquared,~] = size(roi.filterInfo.secondKernel.dx1.Original);

kernelSimu_first_full = zeros(maxTauFirst, nMultiBars,nRoi);
kernelSimu_second_full = zeros(maxTauSecondSquared, nMultiBars,nRoi);
kernelSimu_first = zeros(maxTauFirst, nMultiBars,nRoi);
kernelSimu_second = zeros(maxTauSecondSquared, nMultiBars,nRoi);
kernelSimu_first_optimalCV = zeros(maxTauFirst, nMultiBars,nRoi);
kernelSimu_second_optimalCV = zeros(maxTauSecondSquared, nMultiBars,nRoi);
kernelStd_first = roiStd.LM.firstOrder.kernel;
kernelStd_second = roiStd.LM.secondOrder.kernel;
% you should calculate the difference between them, or compare the ability
% to predict the response....
% diff_first_full = zeros(nRoi,1); % problem of overfitting
% diff_second_full = zeros(nRoi,1);
% diff_first = zeros(nRoi,1); % overfitting + error caused by correction of overfitting.
% diff_second= zeros(nRoi,1);
% first, compare the kernel? non sense? just plot them...
for rr = 1:1:nRoi
    roi = roiData{rr};
    kernelSimu_first(:,:,rr) = roi.LM.firstOrder.kernel;
    kernelSimu_second(:,:,rr) = roi.LM.secondOrder.kernel;
    kernelSimu_first_full(:,:,rr) = roi.filterInfo.firstKernel.Original;
    kernelSimu_second_full(:,:,rr) = roi.filterInfo.secondKernel.dx1.Original;
    kernelSimu_first_optimalCV(:,:,rr) =  Simulation_KernelErrorEstimation_Utils_GetOptimalCV(kernelSimu_first_full(:,:,rr),kernelStd_first);
    kernelSimu_second_optimalCV(:,:,rr) =  Simulation_KernelErrorEstimation_Utils_GetOptimalCV(kernelSimu_second_full(:,:,rr),kernelStd_second);
    
end

% calcualte the difference between a array of kernel and the stdard
% kernel...
diff_first_full = Simulation_KernelErrorEstimation_Utils_CalError(kernelSimu_first_full,kernelStd_first);
diff_second_full = Simulation_KernelErrorEstimation_Utils_CalError(kernelSimu_second_full,kernelStd_second);
diff_first = Simulation_KernelErrorEstimation_Utils_CalError(kernelSimu_first,kernelStd_first);
diff_second = Simulation_KernelErrorEstimation_Utils_CalError(kernelSimu_second,kernelStd_second);
diff_optimal_first = Simulation_KernelErrorEstimation_Utils_CalError(kernelSimu_first_optimalCV,kernelStd_first);
diff_optimal_second = Simulation_KernelErrorEstimation_Utils_CalError(kernelSimu_second_optimalCV,kernelStd_second);
% estimate the relationship between SNR and this...
reciprocalSNR = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    reciprocalSNR(rr) = roi.simuInfo.reciprocalSNR;
end


% also compare to the best possible CV contrained kernel.
% is that true?
MakeFigure;

subplot(211)
scatter(reciprocalSNR,diff_first_full,'filled');
hold on
scatter(reciprocalSNR,diff_first,'filled')
scatter(reciprocalSNR,diff_optimal_first,'filled');
set(gca,'xscale','log');set(gca,'yscale','log')
xlabel('NSR : std(noise)/std(signal)');
ylabel('mean((kernel - true kernel).^2)');
title('1o');
legend('reverse correlaion,full kerne','CV-contrained kernel','CV - optimal contrained kernel');



subplot(212)
scatter(reciprocalSNR,diff_second_full,'filled');
hold on
scatter(reciprocalSNR,diff_second,'filled')
scatter(reciprocalSNR,diff_optimal_second,'filled')
xlabel('NSR : std(noise)/std(signal)');
ylabel('mean((kernel - true kernel).^2)');
title('2o');
legend('reverse correlaion,full kerne','CV-contrained kernel','CV - optimal contrained kernel');
set(gca,'xscale','log');set(gca,'yscale','log')
end