function roiData = roiAnalysis_OneRoi_barPair(roiData)
% predicted response of one bar pair..
firstKernel = roiData.filterInfo.firstKernel;
nBarUse = size(firstKernel,2);
doLN = 1;
coe = roiData.LN.coe;


[respRec,stimMat] = BarPairPre(firstKernel,doLN,0,'rectification',nBarUse);
fr.resp = respRec;
fr.stim = stimMat;

[respCoe,stimMat] = BarPairPre(firstKernel,doLN,coe,'coe',nBarUse);
fc.resp = respCoe;
fc.stim = stimMat;

bp.fc = fc;
bp.fr = fr;

roiData.bp = bp;

% roiType = roiData.typeInfo.type;
% roiName = roiData.typeInfo.Name;
% PlotBarPair_Full(fr,roiType,roiName);
% PlotBarPair_Full(fc,roiType,roiName);
end