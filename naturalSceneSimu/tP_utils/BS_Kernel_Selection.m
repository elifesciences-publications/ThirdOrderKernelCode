function roiBarPicked = BS_Kernel_Selection(kernels,noiseKernels,whichKernels,alpha,minPixel,plotFlag)
% first, construct the distribution.

[nEle,nBoot,nBar,nRoi] = size(noiseKernels);
nk.values = reshape(noiseKernels,[nEle, nBoot * nBar, nRoi]);

%%
nk.distribution.mean =squeeze(mean(nk.values,2));
nk.distribution.std = squeeze(sqrt(var(nk.values,0,2)));
nk.distribution.p = zeros(size(kernels));
nk.distribution.h = zeros(size(kernels));

%% calculate the p value and h, thr h is selected by the significance alpha we set.
% alpha = 1e-4;
for q = 1:1:nBar
    % choose one bar from the data.
    xVec = squeeze(kernels(:,q,:));
    meanVec = nk.distribution.mean;
    stdVec = nk.distribution.std;
    % calculate things for that bar.
    [h,p] = MyZTest(xVec, meanVec,stdVec,alpha);
    
    % store the data.
    nk.distribution.h(:,q,:) = h;
    nk.distribution.p(:,q,:) = p;
    %
    %     quickViewKernels(h,1);
end
% for each roi, view the first order kernel.p
if plotFlag
    switch whichKernels
        case 1
            MakeFigure;
            subplotHt = floor(sqrt(nRoi));
            subplotWd = ceil(nRoi/subplotHt);
            for r = 1:1:nRoi
                subplot(subplotHt,subplotWd,r);
                quickViewOneKernel(squeeze(nk.distribution.h(:,:,r)),whichKernels);
                title(['roi : ', num2str(r)]);
                xlabel('bar');
                ylabel('time [1/60hz]')
            end
            
            MakeFigure;
            for r = 1:1:nRoi
                subplot(subplotHt,subplotWd,r);
                quickViewOneKernel(squeeze(nk.distribution.p(:,:,r)),whichKernels);
                title(['roi : ', num2str(r)]);
                    xlabel('bar');
                ylabel('time [1/60hz]')
            end
        case 2
            quickViewKernels(nk.distribution.h,2);
    end
end
%quickViewKernels(noiseKernels.distribution.p,1);

%% select a roi and bar based on how many dots are significant in the kernel.
roiBarPicked = PickRoiBarOnP(nk.distribution.h,minPixel);
