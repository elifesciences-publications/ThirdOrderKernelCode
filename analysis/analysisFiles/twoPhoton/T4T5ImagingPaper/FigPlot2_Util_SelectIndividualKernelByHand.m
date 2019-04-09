function bestRoi = FigPlot2_Util_SelectIndividualKernelByHand(roiData)
nType = 4;
% roiDataType = cell(nType,1);
% roiDataBest = cell(nType,1);
roiByFly = roiAnalysis_AnalyzeRoiByFly(roiData);

nRoi = length(roiData);
edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.typeInfo.edgeType;
    kernelType(rr) = roi.filterInfo.kernelType;
end

flyID = zeros(nRoi,1);
nfly = length(roiByFly);
for ff = 1:1:nfly
    roiUse = roiByFly(ff).roiUse;
    flyID(roiUse) = ff;
end

kernelQuality = zeros(nRoi,1);
for rr = 1:1:nRoi
    kernelQuality(rr) = roiData{rr}.filterInfo.firstKernel.maxConnectedArea;
end

for tt = 1:1:4
    %     roiUse = find(edgeType == tt & kernelType > 1); % do not limited to the kernel you selected.
    roiSelectedType = edgeType == tt & (kernelType == 1 | kernelType == 3);
    for ff = 1:1:nfly
        roiSelectedFly = flyID == ff; % selected for this might be all zeros.
        roiUse = find(roiSelectedFly & roiSelectedType);
        if ~isempty(roiUse)
            ViewFirstOrderKernelsByType(roiData(roiSelectedFly & roiSelectedType),'typeSelected',[tt]);
            roiUse
        end
        
    end
    
end

end