function roiData = roiAnalysis_OneFly_KernelSelectoin_MultiD_1o(roiData,varargin)
plotFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
noiseKernelPath = roiData{1}.stimInfo.firstNoisePath;
noiseKernelPath = [kernelFolder,noiseKernelPath];

load(noiseKernelPath);
noiseKernel = saveKernels.kernels;

nRoi = length(roiData);
[maxTau,nMultiBars] = size(roiData{1}.filterInfo.firstKernel.Original);

for rr = 1:1:nRoi
    roi = roiData{rr};
    kernelThis = roi.filterInfo.firstKernel.Original;
    roiNum = roi.stimInfo.roiNum;
    noiseKernelThisRoi = noiseKernel(:,:,:,roiNum);
    noiseKernelThisRoi = reshape(noiseKernelThisRoi,maxTau,[]);
    %     covKernel = cov(noiseKernelThisRoi');
    nShuffle = size(noiseKernelThisRoi,2);
    D = mahal([kernelThis';noiseKernelThisRoi'],noiseKernelThisRoi');
    kernelD_Bar = D(1:nMultiBars); kernelD_Sum = sum(kernelD_Bar);
    kernelShuffleD_Bar = D(nMultiBars+1:end);
    
    nShuffleSum = 10000;
    kernelShuffleD_Sum = zeros(nShuffleSum,1);
    for ii = 1:1:nShuffleSum
        kernelShuffleD_Sum(ii) = sum(kernelShuffleD_Bar(randi([1 nShuffle],[1,nMultiBars])));
    end
    
    meanD = mean(kernelShuffleD_Sum);
    stdD = std( kernelShuffleD_Sum);
    zD = (kernelD_Sum - meanD)./stdD;
    pOnetailed = 1-normcdf(abs(zD),0,1);
    pTwotailed = 2* pOnetailed;
    
    ana.z = zD;
    ana.p = pTwotailed;
    ana.kernelD_Bar = kernelD_Bar;
    ana.kernelShuffleD_Bar =  kernelShuffleD_Bar;
    covKernel = cov(noiseKernelThisRoi');
    ana.covKernel = covKernel;
    roi.filterInfo.firstKernel.ZTest = ana;
    roiData{rr} = roi;
    
    if plotFlag
        MakeFigure;
        subplot(221)
        h{1} = histogram(kernelShuffleD_Bar); 
        hold on;
        h{2} = histogram(kernelD_Bar);
        Histogram_Untils_SetBinWidthLimitsTheSame(h,'normByProbabilityFlag',true);
        legend('shuttle','kernel(20bars)');
        xlabel('M distance');
        subplot(222)
        histogram(kernelShuffleD_Sum);hold on;
        yLim = get(gca,'YLim');
        plot([sum(kernelD_Bar),sum(kernelD_Bar)] ,yLim)
        legend('sum of 20 shuttle','sum of kernel(20bars)');
        xlabel('M distance');
        subplot(223)
        quickViewOneKernel(kernelThis,1);
        subplot(224)
        
        covKernel(eye(size(kernelThis,1)) == 1) = 0;
        imagesc(covKernel);colorbar
        title('covariance matrix');
    end
    
    
end


end