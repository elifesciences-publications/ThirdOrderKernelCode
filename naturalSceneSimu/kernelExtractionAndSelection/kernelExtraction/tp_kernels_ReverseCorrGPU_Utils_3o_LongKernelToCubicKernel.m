function  kernel = tp_kernels_ReverseCorrGPU_Utils_3o_LongKernelToCubicKernel(kernelLong,offsetBank)
% for a lot of qq and rr. think of it later.
% check the
[maxTau,~,maxTauTimes2Minus1,nMultiBar,nRoi] = size(kernelLong);
if maxTau * 2 - 1 ~= maxTauTimes2Minus1
    error('Dimension Of Long Kernel is not correct');
end
kernel = zeros(maxTau,maxTau,maxTau,nMultiBar,nRoi);

for ii = 1:1:length(offsetBank)
    tt = offsetBank(ii);
    
    % position in the kernel
    
    windKernel2DThisSlice = triu(true(maxTau,maxTau),tt) & tril(true(maxTau,maxTau),tt);
    wind5DThisSlice = permute(repmat(windKernel2DThisSlice,[1,1,maxTau,nMultiBar, nRoi ]),[3,1,2,4,5]);
    % position in the kernellong.
    if tt >= 0
        kernelLongThisSlice = kernelLong(:,1:(maxTau - abs(tt)),ii, :,:);
    else
        kernelLongThisSlice = kernelLong(:,abs(tt) + 1:end,ii, :,:);  
    end
    kernel(wind5DThisSlice) = kernelLongThisSlice;
    
end

% build a window mask first.

% you will know, which elements of kernelThis to use, and where to put those elements in the third order kernel.
end

% % test function of this function .
% % first get two kernels.
% maxTau = 3;
% offsetBank = -(maxTau - 1): 1: (maxTau - 1);
% nMultiBar = 20;
% nRoi = 17;
%
% K1 = false(maxTau,maxTau,maxTau);
% K2 = false(maxTau,maxTau,maxTau);
% K1(1,1,1) = 1;K1(1,3,1) = 1;
% K2(2,2,2) = 5;
%
% % tranfer it into long format.
% K1Long = zeros(maxTau,maxTau,maxTau * 2 - 1,1,1);
% K2Long = zeros(maxTau,maxTau,maxTau * 2 - 1,1,1);
% %% K1 and K2. find Ge and practice with her once before I do it.
% K1Long(1,1,1,1,1) = 1;
% K1Long(1,1,3,1,1) = 1;
% K2Long(2,2,3,1,1) = 5;
%
%
% k1ShortCompure = tp_kernels_ReverseCorrGPU_Utils_3o_LongKernelToCubicKernel(K1Long,offsetBank);
% k2ShortCompure = tp_kernels_ReverseCorrGPU_Utils_3o_LongKernelToCubicKernel(K2Long,offsetBank);
%
% % first, try the non nMultiBar version.
% KLongFull = zeros(maxTau,maxTau,maxTau * 2 - 1,nMultiBar,nRoi);
% KLongFull(:,:,:,5,3) = K1Long;
% KLongFull(:,:,:,20,17) = K2Long;
% kShortCompute = tp_kernels_ReverseCorrGPU_Utils_3o_LongKernelToCubicKernel(KLongFull,offsetBank);

