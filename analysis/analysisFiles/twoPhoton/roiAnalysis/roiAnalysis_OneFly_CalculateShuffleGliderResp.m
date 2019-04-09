function roiData = roiAnalysis_OneFly_CalculateShuffleGliderResp(roiData,varargin)
dt = -8:1:8;
tMax = 20;
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
    nShuffle = size(noiseKernelThisRoi,2);
    gliderResp = zeros(length(dt),nShuffle);
    for qq = 1:1:nShuffle
        gliderResp(:,qq) = roiAnalysis_OneKernel_dtSweep_SecondOrderKernel(noiseKernelThisRoi(:,qq),'dt',dt,'tMax',tMax);
    end
    roi.filterInfo.secondKernel.shuffle.gliderResp.resp = gliderResp;
    roi.filterInfo.secondKernel.shuffle.gliderResp.dt = dt;
    roi.filterInfo.secondKernel.shuffle.gliderResp.tMax = tMax;
    roiData{rr} = roi;
end
end