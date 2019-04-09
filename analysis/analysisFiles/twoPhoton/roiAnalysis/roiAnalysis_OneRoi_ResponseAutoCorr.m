function roi = roiAnalysis_OneRoi_ResponseAutoCorr(roi,varargin)
maxT = 180;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
S = GetSystemConfiguration;
kernelFolder = S.kernelSavePath;

flickpath = roi.stimInfo.flickPath;
flickpath = [kernelFolder,flickpath];
load(flickpath);
resp = flickSave.respData{1};
stimIndexes = flickSave.stimIndexed{1};
stimIndexesFull = stimIndexes(1):1:stimIndexes(end);
nT = length(stimIndexesFull);
% respFull = nan(nT,1);
% respFull(ismember(stimIndexesFull,stimIndexes)) = resp;
% calculate the autocorrelation of the response.
% lags = 0:maxT - 1;
% numLag = length(lags);
% acorrf = zeros(numLag,1);
% acovf = zeros(numLag,1);
% for ll = 1:1:length(lags)
%     lagThis = lags(ll);
%     [acorrf(ll),acovf(ll)] = MyNaNCorr(respFull(1:end - lagThis),respFull(lagThis + 1:end));
% end

[acorrf,lags] = autocorr(resp,100);
respInfo.autoCorr = acorrf;
respInfo.lags = lags;
roi.respInfo = respInfo;
end