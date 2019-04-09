function respData = roiAnalysis_OneRoi_GetResponse(roi)
firstKernelOLSMat = roi.stimInfo.firstKernelOLSMat;
roiNumFirst = roi.stimInfo.firstKernelRoiNum;
load(firstKernelOLSMat);
[respData,~,~] = GetStimResp_OLS(firstKernelOLSMat, roiNumFirst);
respData = respData{1};
end