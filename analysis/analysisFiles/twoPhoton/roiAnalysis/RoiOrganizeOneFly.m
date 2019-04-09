function roiData = RoiOrganizeOneFly(Z,flyEye,cfRoi,roiTrace,...
    filepath,flickpath,firstkernelpath,secondkernelpathNearest,secondkernelpathNextNearest,firstnoisepath,secondnoisepath,barWidth)
coordinates = 'eye';
nMultiBars = 20;

load(firstkernelpath);
firstKernel = saveKernels.kernels;
load(secondkernelpathNearest);
secondKernelDx1 = saveKernels.kernels;
load(secondkernelpathNextNearest);
secondKernelDx2 = saveKernels.kernels;

nRoi = size(firstKernel,3); % all the data will be stored...
% roiUse = find(roiSelected);
% nRoi = length(roiUse);
%% someone will have second order new kernel, someone will not...
roiData = cell(nRoi,1);
for rr = 1:1:nRoi
    %     rr = roiUse(ii);
    %%
    PEye.trace = roiTrace.eye.indiVidualTrace{rr};
    PEye.value = cfRoi.PEye.value(rr,:);
    PEye.edgeType = cfRoi.PEye.edgeType(rr);
    PEye.edgeName = cfRoi.PEye.edgeName{rr};
    PEye.ESI = cfRoi.PEye.ESI(rr,PEye.edgeType); % it is not used anymore...
    PEye.dirType = cfRoi.PEye.dirType(rr);
    PEye.dirName = cfRoi.PEye.dirName{rr};
    PEye.DSI = cfRoi.PEye.DSI(rr,PEye.dirType);
    PEye.DSI_Diff = cfRoi.PEye.DSI_Diff(rr,1);
    PEye.DSI_Edge = cfRoi.PEye.DSI_Edge(rr);
    PEye.dirTypeEdge = cfRoi.PEye.dirTypeEdge(rr);
    PEye.dirTypeEdgeName = cfRoi.PEye.dirTypeEdgeName{rr};
    PEye.contrastType = cfRoi.PEye.contrastType(rr);
    PEye.contrastName = cfRoi.PEye.contrastName(rr);
    PEye.LDSI_PreferedDir = cfRoi.PEye.LDSI_PreferedDir(rr);
    PEye.LDSI_Combined = cfRoi.PEye.LDSI_Combined(rr);
    PEye.leftRightFlag = cfRoi.PEye.leftRightFlag(rr);
    
    
    PStim.trace = roiTrace.stim.indiVidualTrace{rr};
    PStim.value = cfRoi.PStim.value(rr,:);
    PStim.edgeType = cfRoi.PStim.edgeType(rr);
    PStim.edgeName = cfRoi.PStim.edgeName{rr};
    PStim.ESI = cfRoi.PStim.ESI(rr,PStim.edgeType);
    PStim.dirType = cfRoi.PStim.dirType(rr);
    PStim.dirName = cfRoi.PStim.dirName{rr};
    PStim.DSI = cfRoi.PStim.DSI(rr,PStim.dirType);
    PStim.DSI_Diff = cfRoi.PStim.DSI_Diff(rr,1);
    PStim.DSI_Edge = cfRoi.PStim.DSI_Edge(rr);
    PStim.dirTypeEdge = cfRoi.PStim.dirTypeEdge(rr);
    PStim.dirTypeEdgeName = cfRoi.PStim.dirTypeEdgeName{rr};
    PStim.contrastType = cfRoi.PStim.contrastType(rr);
    PStim.contrastName = cfRoi.PStim.contrastName(rr);
    PStim.LDSI_PreferedDir = cfRoi.PStim.LDSI_PreferedDir(rr);
    PStim.LDSI_Combined = cfRoi.PStim.LDSI_Combined(rr);
    PStim.leftRightFlag = cfRoi.PStim.leftRightFlag(rr);
    
    CCEye.trace = roiTrace.eye.indiVidualTrace{rr};
    CCEye.value = cfRoi.CCEye.value(rr,:);
    CCEye.edgeType = cfRoi.CCEye.edgeType(rr);
    CCEye.edgeName = cfRoi.CCEye.edgeName{rr};
    CCEye.ESI = cfRoi.CCEye.ESI(rr,CCEye.edgeType);
    CCEye.dirType = cfRoi.CCEye.dirType(rr);
    CCEye.dirName = cfRoi.CCEye.dirName{rr};
    CCEye.DSI = cfRoi.CCEye.DSI(rr,CCEye.dirType);
    CCEye.DSI_Diff = cfRoi.CCEye.DSI_Diff(rr,1);
    CCEye.DSI_Edge = cfRoi.CCEye.DSI_Edge(rr);
    CCEye.dirTypeEdge = cfRoi.CCEye.dirTypeEdge(rr);
    CCEye.dirTypeEdgeName = cfRoi.CCEye.dirTypeEdgeName{rr};
    CCEye.contrastType = cfRoi.CCEye.contrastType(rr);
    CCEye.contrastName = cfRoi.CCEye.contrastName(rr);
    CCEye.LDSI_PreferedDir = cfRoi.CCEye.LDSI_PreferedDir(rr);
    CCEye.LDSI_Combined = cfRoi.CCEye.LDSI_Combined(rr);
    CCEye.leftRightFlag = cfRoi.CCEye.leftRightFlag(rr);
    
    CCStim.trace = roiTrace.stim.indiVidualTrace{rr};
    CCStim.value = cfRoi.CCStim.value(rr,:);
    CCStim.edgeType = cfRoi.CCStim.edgeType(rr);
    CCStim.edgeName = cfRoi.CCStim.edgeName{rr};
    CCStim.ESI = cfRoi.CCStim.ESI(rr,CCStim.edgeType);
    CCStim.dirType = cfRoi.CCStim.dirType(rr);
    CCStim.dirName = cfRoi.CCStim.dirName{rr};
    CCStim.DSI = cfRoi.CCStim.DSI(rr,CCStim.dirType);
    CCStim.DSI_Diff = cfRoi.CCStim.DSI_Diff(rr,1);
    CCStim.DSI_Edge = cfRoi.CCStim.DSI_Edge(rr);
    CCStim.dirTypeEdge = cfRoi.CCStim.dirTypeEdge(rr);
    CCStim.dirTypeEdgeName = cfRoi.CCStim.dirTypeEdgeName{rr};
    CCStim.contrastType = cfRoi.CCStim.contrastType(rr);
    CCStim.contrastName = cfRoi.CCStim.contrastName(rr);
    CCStim.LDSI_PreferedDir = cfRoi.CCStim.LDSI_PreferedDir(rr);
    CCStim.LDSI_Combined = cfRoi.CCStim.LDSI_Combined(rr);
    CCStim.leftRightFlag = cfRoi.CCStim.leftRightFlag(rr);
    
    if strcmp(coordinates,'eye')
        typeInfo = PEye;
    end
    
    %%
    % do you flip filter here? not here! you have a function later on to do
    % this. do not flip it here...
    filterInfo.firstKernel.Original = firstKernel(:,:,rr);
    filterInfo.secondKernel.dx1.Original = secondKernelDx1(:,:,rr);
    filterInfo.secondKernel.dx2.Original = secondKernelDx2(:,:,rr);
    %%
    stimInfo.roiNum = rr; % roiNumber does not work at all. you have to remember the mask of this guy. might be useful in the future.
    stimInfo.roiMasks = squeeze(Z.ROI.roiMasks(:,:,rr)); % have not tested yet. hope it works.
    stimInfo.barWidth = barWidth;
    [~,stimInfo.filename,~] = fileparts(filepath);
    
    % delete the abosulte path before store them....
    S = GetSystemConfiguration;
    twoPhotonDataPath = S.twoPhotonDataPathLocal;
    twoPhotonDataPath(twoPhotonDataPath == '/') = '\';
    twoPhotonDataPath(end) = [];
    kernelPath = S.kernelSavePath;
    
    % next roi still need the information, do not over write it...
    filepathThisRoi = KernelPathManage_DeleteAbsolutePath(filepath,twoPhotonDataPath);
%     filepathThisRoi = filepath;
    flickpathThisRoi = KernelPathManage_DeleteAbsolutePath(flickpath,kernelPath);
    firstkernelpathThisRoi = KernelPathManage_DeleteAbsolutePath(firstkernelpath,kernelPath);
    firstnoisepathThisRoi = KernelPathManage_DeleteAbsolutePath(firstnoisepath,kernelPath);
    secondkernelpathNearestThisRoi = KernelPathManage_DeleteAbsolutePath(secondkernelpathNearest,kernelPath);
    secondnoisepathThisRoi = KernelPathManage_DeleteAbsolutePath(secondnoisepath,kernelPath);
    secondkernelpathNextNearestThisRoi = KernelPathManage_DeleteAbsolutePath(secondkernelpathNextNearest,kernelPath);
    
    stimInfo.filepath = filepathThisRoi ;
    stimInfo.flickPath = flickpathThisRoi;
    stimInfo.firstKernelPath  = firstkernelpathThisRoi;
    stimInfo.firstNoisePath  = firstnoisepathThisRoi;
    stimInfo.secondKernelPathNearest  = secondkernelpathNearestThisRoi;
    stimInfo.secondNoisePath  = secondnoisepathThisRoi;
    stimInfo.secondKernelPathNextNearest = secondkernelpathNextNearestThisRoi;
    %%
    flyInfo.flyEye = flyEye;
    %%
    roi.prob.PEye = PEye;
    roi.prob.PStim = PStim;
    roi.prob.CCEye = CCEye;
    roi.prob.CCStim = CCStim;
    
    roi.typeInfo = typeInfo;
    roi.stimInfo = stimInfo;
    roi.filterInfo = filterInfo;
    roi.flyInfo = flyInfo;
    
    roiData{rr} = roi;
    clear clear PEYe PStim CCEye CCStim typeInfo stimInfo filterInfo flyInfo roi
    % save roi ?
    
end
