function respAutoCoe = roiAnalysis_OneRoi_ResponseAutoCorrelation(roi,varargin)
nXcorr = 20;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

flickpath = roi.stimInfo.flickPath;
roiNum = roi.stimInfo.roiNum;
[respData,stimData,stimIndexes] = GetStimResp_ReverseCorr(flickpath, roiNum);

%         maxTau = min([maxTauUpLim,maxTau]);
[OLSMat] = tp_Compute_OLSMat_ARMA(respData,stimData,stimIndexes,'order',1,'maxTau',2,'maxTau_r',1,'nMultiBars', 20);
%         OLSMat = tp_Compute_OLSMat_ARMA(respData,stimData,stimIndexes,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
RR = OLSMat.resp{1};
respAutoCoe = autocorr(RR,nXcorr);
respAutoCoe = respAutoCoe(2:end);
end