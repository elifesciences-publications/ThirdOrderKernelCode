function [value,nPerType] = roiAnalysis_AverageFunction_OverRoi_IndividualBars(roiData,varargin)

whichValue = 'glider';
dx = 1;
normKernelFlag = false;
normRoiFlag = true;
kernelTypeUse = [1,2,3];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nRoi = length(roiData);
nType = 4;
value = cell(4,1);
nPerType = zeros(4,1);

edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
end

% all the roi....
for tt = 1:1:nType
    roiSelectedType = edgeType == tt;
    roiSelectedKernelType = false(length(kernelType),1);
    for kk = 1:1:length(kernelTypeUse)
        roiSelectedKernelType  = roiSelectedKernelType | kernelType == kernelTypeUse(kk);
    end
    roiUse = find(roiSelectedType &  roiSelectedKernelType);
    nRoiUse = length(roiUse);
    valueThisType = [];
    if nRoiUse ~= 0
        for ii = 1:1:nRoiUse
            roi = roiData{roiUse(ii)};
            
            [valueThisRoi,barUse] = roiAnalysis_AverageFunction_OverKernel_IndividualBars({roi},'whichValue',whichValue,'dx',dx,...
                'normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag,'kernelTypeUse',kernelTypeUse);
            % this time, valueThisRoi{} would be in three
            valueThisRoi = valueThisRoi{tt};
            valueThisType = cat(3,valueThisType,valueThisRoi);
        end
        value{tt} = valueThisType;
        nPerType(tt) = size(valueThisType,3);
    end
end