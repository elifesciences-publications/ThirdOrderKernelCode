function PlotOneRoi_FS(roi,varargin)
% first, compare the difference between first order kernel
barUse = [1,2]; % for the second order kernel
nMultiBars = 20;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

firstKernel = roi.filterInfo.firstKernelOriginal;
firstKernelFast = roi.filterInfo_NoCal.first.kernel;

MakeFigure;
subplot(4,3,1);
quickViewOneKernel(firstKernel,1);
title('original one');
colorbar
subplot(4,3,2);
quickViewOneKernel(firstKernelFast,1);
title('fast');
colorbar
subplot(4,3,3)
kernelDiff = firstKernel - firstKernelFast;
quickViewOneKernel(kernelDiff,1);
colorbar
title('difference');
%%
% hopefully, there is only two barUse.
for ii = 1:1:length(barUse)
    qq = barUse(ii);
    secondKernel = roi.filterInfo.secondKernelOriginal(:,qq);
    secondKernelFast = roi.filterInfo_NoCal.second.kernel(:,qq);
    maxTauSquared = size(secondKernelFast,1);
    maxTau = round(sqrt(maxTauSquared));
    
    secondKernelShort = reshape(secondKernel,[64,64]);
    secondKernelShort = secondKernelShort(1:maxTau,1:maxTau);
    secondKernelShort = secondKernelShort(:);

    subplot(4,3,1 + ii * 3);
    quickViewOneKernel(secondKernelShort,2);
    title('original');
    colorbar
    subplot(4,3,2 + ii * 3);
    quickViewOneKernel(secondKernelFast,2)
    title('fast')
    colorbar
    subplot(4,3,3 + ii* 3);
    secKerDiff = secondKernelShort - secondKernelFast;
    quickViewOneKernel(secKerDiff,2);
    title('difference');
    colorbar
end

for ii = 1:1:length(barUse)
    qq = barUse(ii);
    secondKernel = roi.filterInfo.secondKernelOriginal(:,qq);
    secondKernelFast = roi.filterInfo_NoCal.second.kernel(:,qq);
    maxTauSquared = size(secondKernelFast,1);
    maxTau = round(sqrt(maxTauSquared));
    
    secondKernelShort = reshape(secondKernel,[64,64]);
    secondKernelShort = secondKernelShort(1:maxTau,1:maxTau);
    secondKernelShort = secondKernelShort(:);
    
    firstKernelFast = roi.filterInfo_NoCal.first.kernel;
    barLeft = qq;
    barRight = mod(qq + 1,nMultiBars) + 1;
    f1 = firstKernelFast(:,barLeft);
    f2 = firstKernelFast(:,barRight);
    secondKernelHat = f1 * f2';
    secondKernelHat = secondKernelHat(1:maxTau,1:maxTau);
    secondKernelHat = secondKernelHat(:);
    
    [U,S,V] = svd(reshape(secondKernelFast,[maxTau,maxTau]));
    firstComponent = U(:,1)*V(:,1)';
    
    MakeFigure;
    subplot(3,3,1);
    quickViewOneKernel(secondKernelFast,2);
    title('second order kernel');
    colorbar
    
    subplot(3,3,2)
    quickViewOneKernel(firstComponent(:),2);
    title('SVD -- first element U(1) * V(1)');
    colorbar
    
    subplot(3,3,3)
    plot(U(:,1),'r');
    hold on
    plot(V(:,1),'b');
    legend('left component','right component');
    hold off 
    
    subplot(3,3,5)
    quickViewOneKernel(secondKernelHat(:),2);
    title('LN -- f1 * f2');
    colorbar
    
    subplot(3,3,6)
    plot(f1(1:maxTau),'r');
    hold on
    plot(f2(1:maxTau),'b');
    hold off
    title('first order kernel');
    legend('left bar','right bar');

end