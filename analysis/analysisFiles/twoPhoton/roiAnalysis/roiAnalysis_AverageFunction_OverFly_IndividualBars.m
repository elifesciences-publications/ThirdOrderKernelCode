function [value,nPerType] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiData,varargin)
whichValue = 'glider';
dx = 1;
normKernelFlag = false;
normRoiFlag = true;
kernelTypeUse  = [1,2,3];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nRoi = length(roiData);
edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
end

roiByFly = roiAnalysis_AnalyzeRoiByFly(roiData);
nfly = length(roiByFly);

nRoi = length(roiData);
nType = 4;
value = cell(nType ,1);
nPerType = zeros(nType ,1);

for tt = 1:1:nType
    roiSelectedType = edgeType == tt;
    roiSelectedKernelType = false(length(kernelType),1);
    for kk = 1:1:length(kernelTypeUse)
        roiSelectedKernelType  = roiSelectedKernelType | kernelType == kernelTypeUse(kk);
    end
    valueThisType = [];
    % go over fly...
    for ff = 1:1:nfly
        % for each fly, do the thing....
        roiUseThiFly = roiByFly(ff).roiUse;
        roiSelectedFly = false(nRoi,1);
        roiSelectedFly(roiUseThiFly) = true;
        roiSelected = roiSelectedFly & roiSelectedType & roiSelectedKernelType;
        
        if find(roiSelected)
            roiDataThisFly = roiData(roiSelected);
            [valueThisFly,nPerTypeThisFly] = roiAnalysis_AverageFunction_OverRoi_IndividualBars(roiDataThisFly,'whichValue',whichValue,'dx',dx,...
                                                                                 'normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag,'kernelTypeUse',kernelTypeUse);
            if nPerTypeThisFly(tt) ~= 0
                valueThisFly = mean(valueThisFly{tt},3);
                valueThisType = cat(3,valueThisType,valueThisFly);
            end
        end
    end
    value{tt} = valueThisType;
    nPerType(tt) = size(valueThisType,3);
end
end