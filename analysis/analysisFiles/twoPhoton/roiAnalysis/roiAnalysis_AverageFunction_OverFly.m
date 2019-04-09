function [value,nPerType] = roiAnalysis_AverageFunction_OverFly(roiData,varargin)
whichValue = 'glider';
dx = 1;
normKernelFlag = false;
normRoiFlag = true;
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
    roiSelectedType  = edgeType == tt & kernelType > 1;
    valueThisType = [];
    % go over fly...
    for ff = 1:1:nfly
        % for each fly, do the thing....
        roiUseThiFly = roiByFly(ff).roiUse;
        roiSelectedFly = false(nRoi,1);
        roiSelectedFly(roiUseThiFly) = true;
        roiSelected = roiSelectedFly & roiSelectedType;
        
        if find(roiSelected)
            roiDataThisFly = roiData(roiSelected);
            [valueThisFly,nPerTypeThisFly] = roiAnalysis_AverageFunction_OverRoi(roiDataThisFly,'whichValue',whichValue,'dx',dx,...
                                                                                 'normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag);
            if nPerTypeThisFly(tt) ~= 0
                valueThisFly = mean(valueThisFly{tt},2);
                valueThisType = cat(2,valueThisType,valueThisFly);
            end
        end
    end
    value{tt} = valueThisType;
    nPerType(tt) = size(valueThisType,2);
end
end