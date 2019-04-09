function [value,nPerType] = roiAnalysis_AverageFunction_OverRoi(roiData,varargin)

whichValue = 'glider';
dx = 1;
normKernelFlag = false;
normRoiFlag = true;
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

for tt = 1:1:nType
    roiUse  = find(edgeType == tt & kernelType > 1);
    nRoiUse = length(roiUse);
    valueThisType = [];
    if nRoiUse ~= 0
        for ii = 1:1:nRoiUse
            roi = roiData{roiUse(ii)};
            % it is possible that for one roi, it does not have dx = 1 or
            % dx = 2.
            switch dx
                case 1
                    barUse = find(roi.filterInfo.secondKernel.dx1.barSelected);
                case 2
                    barUse = find(roi.filterInfo.secondKernel.dx2.barSelected);
                case 0
                    barUse = find([roi.filterInfo.secondKernel.dx1.barSelected;roi.filterInfo.secondKernel.dx2.barSelected]);
            end
            if ~isempty(barUse)
                [valueThisRoi,barUse] = roiAnalysis_AverageFuncion_OverKernel({roi},'whichValue',whichValue,'dx',dx,...
                                                                             'normKernelFlag',normKernelFlag,'normRoiFlag',normRoiFlag);
                valueThisRoi = mean(valueThisRoi{tt},2);
                valueThisType = cat(2,valueThisType,valueThisRoi);
            end
        end
        value{tt} = valueThisType;
        nPerType(tt) = size(valueThisType,2);
    end
end