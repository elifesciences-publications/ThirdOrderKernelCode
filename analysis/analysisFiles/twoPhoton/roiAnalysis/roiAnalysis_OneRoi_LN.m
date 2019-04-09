function roiData = roiAnalysis_OneRoi_LN(roiData)
flickpath = roiData.stimInfo.flickPath;
roiUse = roiData.stimInfo.roiNum;
[stim,resp] = GetStimResp(flickpath , roiUse);
% stim = filterInfo.stim;
% resp = filterInfo.resp;
k = roiData.filterInfo.firstKernelOriginal;

predResp = Kernel_Pred_OneRoi_AllBar_Linear(stim,k);

[predLN,coe] = MyFitPoly2(predResp,resp);
r(1) = corr(predResp,resp);
str{1} = 'response and 1o ';

LN.resp = resp;
LN.predResp = predResp;
LN.predLN = predLN;
LN.coe = coe;
LN.r = r;
LN.str = str;
  
roiData.LN = LN;
end