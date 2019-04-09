function roiData = roiAnalysis_OneFly_KernelSelectoin_MultiD_2o(roiData,varargin)
plotFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;
noiseKernelPath = roiData{1}.stimInfo.secondNoisePath;
noiseKernelPath = [kernelFolder,noiseKernelPath];
load(noiseKernelPath);
noiseKernel = saveKernels.kernels;

nRoi = length(roiData);
[maxTauSquare,nMultiBars] = size(roiData{1}.filterInfo.secondKernel.dx1.Original);
maxTau = round(sqrt(maxTauSquare));

for rr = 1:1:nRoi
    roi = roiData{rr};
    %     kernelThis = roi.filterInfo.firstKernel.Original;
    roiNum = roi.stimInfo.roiNum;
    noiseKernelThisRoi = noiseKernel(:,:,:,roiNum);
    noiseKernelThisRoi = reshape(noiseKernelThisRoi,maxTauSquare,[]);

    % compute covariance matrix.
    covFunction = CovEstimation_SecondOrderKernel(noiseKernelThisRoi);
    covKernel = CovEstimation_SecondOrderKernel_Utils_CovFunToCovMat(covFunction,maxTau);
    
    % compute the multidimensional distance
    nShuffle = size(noiseKernelThisRoi,2);
    kernelD_Bar = zeros(nMultiBars,1);
    kernelShuffleD_Bar = zeros(nShuffle,1);
    covKernelInv = inv(covKernel); 
    kernelThis = cat(2, roi.filterInfo.secondKernel.dx1.Original, roi.filterInfo.secondKernel.dx2.Original);
    for qq = 1:1:nMultiBars * 2
        kernelD_Bar(qq) = kernelThis(:,qq)' * covKernelInv * kernelThis(:,qq);
    end
    for qq = 1:1:nShuffle
        kernelShuffleD_Bar(qq) = noiseKernelThisRoi(:,qq)' * covKernelInv * noiseKernelThisRoi(:,qq);
    end % ignore the warning . it takes 500 seconds to compute one roi if I use (A\b);
    
    % compute z and p
    meanD = mean(kernelShuffleD_Bar);
    stdD = std(kernelShuffleD_Bar);
    zD = (kernelD_Bar - meanD)./stdD;
    pOnetailed = 1-normcdf(abs(zD),0,1);
    pTwotailed = 2* pOnetailed;
    
    % organize data.
    ana.kernelShuffleD_Bar =  kernelShuffleD_Bar;
    ana.covKernel = covKernel;
    ana.covFunction = covFunction;
    roi.filterInfo.secondKernel.shuffle = ana;
    
    anaDx1.z = zD(1:nMultiBars);
    anaDx1.p = pTwotailed(1:nMultiBars); 
    anaDx1.d = kernelD_Bar(1:nMultiBars);
    anaDx2.z = zD(nMultiBars + 1: 2 * nMultiBars);
    anaDx2.p = pTwotailed(nMultiBars + 1: 2 * nMultiBars); 
    anaDx2.d = kernelD_Bar(nMultiBars + 1: 2 * nMultiBars);
    roi.filterInfo.secondKernel.dx1.ZTest = anaDx1;
    roi.filterInfo.secondKernel.dx2.ZTest = anaDx2;
    
    roiData{rr} = roi;
    
    if plotFlag
        MakeFigure;
        subplot(221)
        h{1} = histogram(kernelShuffleD_Bar);hold on;
        h{2} = histogram(kernelD_Bar);
        Histogram_Untils_SetBinWidthLimitsTheSame(h,'normByProbabilityFlag',true);
        legend('shuttle','kernel(20bars)');
        xlabel('M distance');
        subplot(222)  
        covKernel(eye(size(kernelThis,1)) == 1) = 0;
        imagesc(covKernel);colorbar
        title('covariance matrix');
        subplot(223)
        plot(covFunction);
        title('"covariance Function"');   
        xlabel('time [frame in 60Hz]');
        subplot(224)
        plot([0;covFunction(2:end)]);
          title('"covariance Function"');
        xlabel('time [frame in 60Hz]');
        quickViewKernelsSecond(kernelThis,'subplotHt',4,'subplotWd',5);
    end
end
end