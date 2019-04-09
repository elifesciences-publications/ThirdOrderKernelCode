function kernelAll = tryOut_NotNextBarKernel_OnlyPositivePair(roi,barBank)

firstKernelOLSMat = roi.stimInfo.firstKernelOLSMat;
roiNumFirst = roi.stimInfo.firstKernelRoiNum;
load(firstKernelOLSMat);
[respData,stimData,stimIndexes] = GetStimResp_OLS(firstKernelOLSMat, roiNumFirst);

respData = respData{1};
stimData = stimData;
stimIndexes = stimIndexes{1};
nBarBank = size(barBank,1);
kernelAll = zeros(900,nBarBank);
titleStr =  cell(nBarBank,1);
for ii = 1:1:nBarBank
    barLeft = barBank(ii,1);
    barRight = barBank(ii,2);
    %
    %     kernel  = tp_Compute_2DKernel_TwoBar(respData,stimData,stimIndexes,barLeft,barRight);
    kernel  = tp_Compute_2DKernel_TwoBar_OnlyPositivePair(respData,stimData,stimIndexes,barLeft,barRight);
    
    kernelAll(:,ii) = kernel;
    titleStr{ii} = [num2str(barLeft),num2str(barRight)];
end

% MakeFigure;
% for ii = 1:1:nBarBank
%     subplot(2,4,ii);
%     quickViewOneKernel(kernelAll(:,ii),2);
%     title(titleStr{ii})
% end
% barLeft = 11;
% barRight = 13; % or 14?
%
% kernel  = tp_Compute_2DKernel_TwoBar(respData,stimData,stimIndexes,barLeft,barRight);
% quickViewOneKernel(kernel,2);
end