function ROI = RoiIsBackGround(Z)
loadFlexibleInputs(Z);
roiMaskfile = [filename,'/','savedAnalysis/'];
dataInfo = dir([roiMaskfile,'IcaRoiExtraction*.mat']);

if isempty(dataInfo)
    dataInfo = dir([roiMaskfile,'HHCARoiExtraction*.mat']);
end
% if there are multible of them, choose the newest one.
dataNameAll = {dataInfo.name};
[~, newestInd] = max(cellfun(@(fname) datenum(fname(regexp(fname, '\d+_\d+_\d+', 'start'):regexp(fname, '\d+_\d+_\d+', 'end')), 'dd_mm_yy'),dataNameAll));
dataName = [roiMaskfile,dataInfo(newestInd).name];
% if there are two of them, chose the lastest one
load(dataName);
roiMask_ICA_InWindow = lastRoi.roiMaskInitial;
%% infer what is the windmask used...
imageSize = imgSize(1:2);
Z.grab.windowMask = ICA_DFOVERF_Untils_InferWindowMask(roiMask_ICA_InWindow ,imageSize);

smallBkgdMask = roiUtils_TinyConnectedBg( Z );
% double them, because Emilio's code will kill the last roiMask;
smallBkgdMask = cat(3,smallBkgdMask,smallBkgdMask);
ROI.roiMasks = smallBkgdMask;

end