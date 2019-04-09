function roiData = RoiOrganizeOneFly_Edge(Z,filepath,flyEye,flyID,barWidth,cfRoi,roiTrace, analysis_method_identifier)

% redo everything...
coordinates = 'eye';
nRoi = size(Z.ROI.roiMasks,3); % all the data will be stored...
% roiUse = find(roiSelected);
% nRoi = length(roiUse);
%% someone will have second order new kernel, someone will not...
roiData = cell(nRoi,1);
for rr = 1:1:nRoi
    %     rr = roiUse(ii);
    %%
    PEye.trace = roiTrace.eye.individualTrace{rr};
    PEye.value = cfRoi.PEye.value(rr,:);
    PEye.edgeType = cfRoi.PEye.edgeType(rr);
    PEye.edgeName = cfRoi.PEye.edgeName{rr};
    PEye.ESI = cfRoi.PEye.ESI(rr); % it is not used anymore...
    PEye.dirType = cfRoi.PEye.dirType(rr);
    PEye.dirName = cfRoi.PEye.dirName{rr};
    PEye.DSI = cfRoi.PEye.DSI(rr,PEye.dirType);
    PEye.DSI_Edge = cfRoi.PEye.DSI_Edge(rr);
    PEye.dirTypeEdge = cfRoi.PEye.dirTypeEdge(rr);
    PEye.dirTypeEdgeName = cfRoi.PEye.dirTypeEdgeName{rr};
    PEye.contrastType = cfRoi.PEye.contrastType(rr);
    PEye.contrastName = cfRoi.PEye.contrastName(rr);
    PEye.leftRightFlag = cfRoi.PEye.leftRightFlag(rr);
    
    PStim.trace = roiTrace.stim.individualTrace{rr};
    PStim.value = cfRoi.PStim.value(rr,:);
    PStim.edgeType = cfRoi.PStim.edgeType(rr);
    PStim.edgeName = cfRoi.PStim.edgeName{rr};
    PStim.ESI = cfRoi.PStim.ESI(rr);
    PStim.dirType = cfRoi.PStim.dirType(rr);
    PStim.dirName = cfRoi.PStim.dirName{rr};
    PStim.DSI = cfRoi.PStim.DSI(rr,PStim.dirType);
    PStim.DSI_Edge = cfRoi.PStim.DSI_Edge(rr);
    PStim.dirTypeEdge = cfRoi.PStim.dirTypeEdge(rr);
    PStim.dirTypeEdgeName = cfRoi.PStim.dirTypeEdgeName{rr};
    PStim.contrastType = cfRoi.PStim.contrastType(rr);
    PStim.contrastName = cfRoi.PStim.contrastName(rr);
    PStim.leftRightFlag = cfRoi.PStim.leftRightFlag(rr);
    
    if strcmp(coordinates,'eye')
        typeInfo = PEye;
    end
    
    repeatability.value = cfRoi.repeatability.wholeProb(rr);
    repeatability.trace = cfRoi.repeatabilityTrace(rr,:);
    %%
    %%
    stimInfo.roiNum = rr; % roiNumber does not work at all. you have to remember the mask of this guy. might be useful in the future.
    stimInfo.roiMasks = squeeze(Z.ROI.roiMasks(:,:,rr)); % have not tested yet. hope it works.
    stimInfo.barWidth = barWidth;
%     [~,stimInfo.filename,~] = fileparts(filepath); % you might want to delete this as well.
    
    % delete the abosulte path before store them....
    S = GetSystemConfiguration;
    twoPhotonDataPath = S.twoPhotonDataPathLocal;
    twoPhotonDataPath(twoPhotonDataPath == '/') = '\';
    twoPhotonDataPath(end) = [];
    
    % next roi still need the information, do not over write it...
    file_relative_path = KernelPathManage_DeleteAbsolutePath(filepath,twoPhotonDataPath);
%     filepathThisRoi = filepath;
    stimInfo.filepath = file_relative_path ;
    %%
    flyInfo.flyEye = flyEye;
    flyInfo.flyID = flyID;
    %% also remember the kernelIdentifier.
    analysis_method_info.identifier = analysis_method_identifier;
    %%
    roi.prob.PEye = PEye;
    roi.prob.PStim = PStim;
    roi.repeatability = repeatability;
    roi.typeInfo = typeInfo;
    roi.stimInfo = stimInfo;
    roi.analysis_method_info = analysis_method_info;
%     roi.filterInfo = filterInfo;
    roi.flyInfo = flyInfo;
    
    roiData{rr} = roi;
    clear clear PEYe PStim CCEye CCStim typeInfo stimInfo filterInfo flyInfo roi
    % save roi ?
    
end
