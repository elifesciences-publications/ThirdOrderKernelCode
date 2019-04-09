function roi = roiAnalysis_OneRoi_KernelExtraction_WithoutCalcium(roi,varargin)

order = 1;
maxTau_r = 3;
barUse = 17;

flickpath = roi.stimInfo.flickPath;
roiNum = roi.stimInfo.roiNum;
[respData,stimData,stimIndexes] = GetStimResp_ReverseCorr(flickpath, roiNum);

% kernels = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'dx',2,'order',2);
% roi.filterInfo.secondKernelNotNearestOriginal = kernels;
switch order
    case 1

        [maxTau,nMultiBars] = size(roi.filterInfo.firstKernelOriginal);
        [OLSMat] = tp_Compute_OLSMat_ARMA(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'maxTau_r',maxTau_r,'nMultiBars', nMultiBars);
%         OLSMat = tp_Compute_OLSMat_ARMA(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
        SS = OLSMat.stim;
        RR = OLSMat.resp{1};
        RR_Shift = OLSMat.respSelf{1};
        
        % there are all cells...
        kernel_r = zeros(maxTau + maxTau_r,20);
        for qq = 1:1:nMultiBars
            SS_r = [SS{qq},RR_Shift];
            kernel_r(:,qq) = SS_r \ RR;
        end
        roi.filterInfo_NoCal.first.kernel = kernel_r(1:maxTau,:);
        roi.filterInfo_NoCal.first.kr = kernel_r(end - maxTau_r + 1 : end,:);
        
    case 2

        [maxTauSquared,nMultiBars] = size(roi.filterInfo.secondKernelOriginal);
        maxTau = round(sqrt(maxTauSquared));
        OLSMat = tp_Compute_OLSMat_ARMA(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'maxTau_r',maxTau_r,'nMultiBars', nMultiBars);
        SS = OLSMat.stim;
        RR = OLSMat.resp{1};
        RR_Shift = OLSMat.respSelf{1};
        
        % there are all cells...
        kernel_r = zeros(maxTauSquared + maxTau_r,nMultiBars);
        for ii = 1:1:length(barUse)
            qq = barUse(ii);
            SS_r = [SS{qq},RR_Shift];
            kernel_r(:,qq) = SS_r \ RR;
        end
        roi.filterInfo_NoCal.second.kernel = kernel_r(1:maxTauSquared,:);
        roi.filterInfo_NoCal.second.kr = kernel_r(end - maxTau_r + 1 : end,:);
        
end

%% look at the difference between the fast first order kernel and the slow one...
% MakeFigure;
% subplot(2,2,1);
% kernel = roi.filterInfo.firstKernelOriginal;
% quickViewOneKernel(kernel,1);
% colorbar
% subplot(2,2,2);
% kernel_Fast  = roi.filterInfo_NoCal.first.kernel;
% quickViewOneKernel(kernel_Fast,1)
% colorbar
% subplot(2,2,3)
% quickViewOneKernel(kernel - kernel_Fast,1);
% colorbar
% 
% 
% MakeFigure;
% subplot(2,2,1);
% kernel = roi.filterInfo.secondKernelOriginal(:,barUse);
% quickViewOneKernel(kernel,2);
% subplot(2,2,2);
% kernelFast = roi.filterInfo_NoCal.second.kernel(:,barUse);
% quickViewOneKernel(kernelFast,2);
% subplot(2,2,3);
% quickViewOneKernel(kernel - kernelFast,2);

% okay, it works pretty well. how are you going approach this?
% using 
% kr = mean(roi.filterInfo_NoCal.first.kr,2)
% 
% dt = 1/60;
% calSpeedEst1 =  dt/(1 - kr)
% calSpeedEst2 = (kr + 1)/(2 - 2 * kr) * dt
% 
% a = autocorr(RR)
% plot(a(2:end))
end