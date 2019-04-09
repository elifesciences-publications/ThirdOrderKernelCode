
aveResp = D.analysis.aveResp(:,:,1);
semAveResp = D.analysis.semAveResp(:,:,1);
indResp = cell2mat(D.analysis.indResp(:,:,1));
indResp = indResp(2:end,:);

rPhi = aveResp(2:end/2,:);
phi = aveResp(end/2+2:end,:);

semRPhi = semAveResp(2:end/2,:);
semPhi = semAveResp(end/2+2:end,:);

[~,phiMaxI] = max(indResp);
[~,rPhiMinI] = min(indResp);

phiTimes = delayList(phiMaxI);
rPhiTimes = delayList(rPhiMinI);

phiPeakMean = mean(phiTimes);
rPhiPeakMean = mean(rPhiTimes);

semPhiPeakMean = std(phiTimes)/sqrt(size(indResp,2));
semRPhiPeakMean = std(rPhiTimes)/sqrt(size(indResp,2));