function roi = roiAnalysis_OneRoi_KernelExtraction_WithoutCalcium(roi,varargin)

order = 1;
maxTau_r = 3;
barUse = 17;
maxTauUpLim = 30; % for first and second...
dx = 1;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{',num2str(ii + 1),'};']);
end

flickpath = roi.stimInfo.flickPath;
roiNum = roi.stimInfo.roiNum;
[respData,stimData,stimIndexes] = GetStimResp_ReverseCorr(flickpath, roiNum);

% kernels = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'dx',2,'order',2);
% roi.filterInfo.secondKernelNotNearestOriginal = kernels;
switch order
    case 1

        [maxTau,nMultiBars] = size(roi.filterInfo.firstKernelOriginal);
%         maxTau = min([maxTauUpLim,maxTau]);
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
        % for second order kernel, confine the max length to 30;;
        maxTau = min([maxTauUpLim,maxTau]);
        maxTauSquared = maxTau^2;
        OLSMat = tp_Compute_OLSMat_ARMA(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'maxTau_r',maxTau_r,'nMultiBars', nMultiBars,'dx',dx);
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


% okay, it works pretty well. how are you going approach this?
% using 
% kr = mean(roi.filterInfo_NoCal.first.kr,2)
% 
% dt = 1/60;
% calSpeedEst1 =  dt/(1 - kr)
% calSpeedEst2 = (kr + 1)/(2 - 2 * kr) * dt
% 

% plot(a(2:end))
end