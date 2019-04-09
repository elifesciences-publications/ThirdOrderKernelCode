function roi = roiAnalysis_OneRoi_SecondSineWave(roi,varargin)
omegaTemp = 2.^(-3:1/3:3);
omegaBank = [-fliplr(omegaTemp),0,omegaTemp]; % do the analysis for the 
lambdaBank = [30]; % might be very slow...

normKernelFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

secondKernel = cat(3,roi.filterInfo.secondKernel.dx1.Adjusted,roi.filterInfo.secondKernel.dx2.Adjusted);
barSelected = cat(2,roi.filterInfo.secondKernel.dx1.barSelected,roi.filterInfo.secondKernel.dx2.barSelected);
[~,nMultiBars,nDx] = size(secondKernel);

% omegaBank(omegaBank == 0) = [];
barWidth = roi.stimInfo.barWidth;
nOmegaBank = length(omegaBank);
nLambdaBank = length(lambdaBank);

if normKernelFlag 
    A = sqrt(sum(secondKernel.^2,1));
    A(A == 0) = 100000;
    secondKernel = secondKernel./repmat(A,[size(secondKernel,1),1]);
end


sineResp = zeros(nOmegaBank,nLambdaBank,nMultiBars,nDx);
for dx = 1:1:nDx
    for qq = 1:1:nMultiBars
        if barSelected(qq,dx)
        respMeanSec = FrequencyTuningCurveSecond(secondKernel(:,qq,dx),omegaBank,lambdaBank,barWidth);
        sineResp(:,:,qq,dx) = respMeanSec;
        end
    end
end

sr.dx1 = squeeze(sineResp(:,:,:,1));
sr.dx2 = squeeze(sineResp(:,:,:,2));

sine.resp = sr;
sine.stim.omega = omegaBank;
sine.stim.lambda = lambdaBank;
roi.simu.sK.sine = sine;

end