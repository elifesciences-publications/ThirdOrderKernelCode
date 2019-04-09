function kernelAll = tryOut_NotNextBarKernel(roi,barBank,varargin)
signConstrainFlag = false;
sign = 1;
maxTau = 50;

for ii = 1:2:length(varargin)
    eval([varargin{ii},'= varargin{',num2str(ii + 1),'};']);
end

firstKernelOLSMat = roi.stimInfo.firstKernelOLSMat;
roiNumFirst = roi.stimInfo.firstKernelRoiNum;
load(firstKernelOLSMat);
[respData,stimData,stimIndexes] = GetStimResp_OLS(firstKernelOLSMat, roiNumFirst);

respData = respData{1};
stimData = stimData;
stimIndexes = stimIndexes{1};
nBarBank = size(barBank,1);
kernelAll = zeros(2*maxTau^2,nBarBank);
titleStr =  cell(nBarBank,1);
for ii = 1:1:nBarBank
    barLeft = barBank(ii,1);
    barRight = barBank(ii,2);
    %
        kernel  = tp_Compute_2DKernel_TwoBarSepCorr(respData,stimData,stimIndexes,barLeft,barRight,varargin{:});
    
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