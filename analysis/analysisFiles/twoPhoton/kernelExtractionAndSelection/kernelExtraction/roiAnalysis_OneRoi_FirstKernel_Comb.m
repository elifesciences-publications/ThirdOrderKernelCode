function roi = roiAnalysis_OneRoi_FirstKernel_Comb(roi,varargin)
order = 1;
maxTau = 30;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
flickpath = roi.stimInfo.flickPath;
roiNum = roi.stimInfo.roiNum;
k = roi.filterInfo.firstKernel.Original;

[respData,stimData,stimIndexes] = GetStimResp_ReverseCorr(flickpath, roiNum);

[OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'order',1,'maxTau',maxTau,'nMultiBars',20,'reverseKernelFlag',false);
[kernel] = tp_kernels_OLS_Comb(OLSMat.resp,OLSMat.stim);
kernelComb = squeeze(kernel);
% show the result 

MakeFigure;
subplot(2,2,1)
quickViewOneKernel(roi.filterInfo.firstKernel.Original(1:maxTau,:),1);
title('sep')
colorbar

subplot(2,2,2)
quickViewOneKernel(kernelComb,1);
title('comb')
colorbar

subplot(2,2,3)
kernelDiff = kernelComb - roi.filterInfo.firstKernel.Original(1:maxTau,:);
quickViewOneKernel(kernelDiff,1);
title('difference');
colorbar

subplot(2,2,4)
kernelDiffRel = kernelDiff.^2./kernelComb.^2;
quickViewOneKernel(kernelDiffRel,1);
colorbar
end