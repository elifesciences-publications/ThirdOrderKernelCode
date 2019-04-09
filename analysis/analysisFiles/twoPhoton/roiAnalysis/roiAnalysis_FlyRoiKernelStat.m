function numStat = roiAnalysis_FlyRoiKernelStat(roiData,varargin)

% order will not matter,
% understand how many rois, kernels, fly.

nType = 4;

nRoi = length(roiData);
edgeType = zeros(nRoi,1);
kernelType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
    kernelType(rr) = roiData{rr}.filterInfo.kernelType;
end

flyID = zeros(nRoi,1);
roiByFly = roiAnalysis_AnalyzeRoiByFly(roiData);
nfly = length(roiByFly);
for ff = 1:1:nfly
    roiUse = roiByFly(ff).roiUse;
    flyID(roiUse) = ff;
end


numRoiPerFly = zeros(nType,nfly);
numFirstKernelPerFly = zeros(nType,nfly);
numSecondKernelPerFly = zeros(nType,nfly,2); % dx1 dx2

for tt =1:1:nType
    
    roiSelectedFirstThisType = edgeType == tt & (kernelType ==1  | kernelType == 3);
    roiSelectedSecondThisType = edgeType == tt & kernelType >1;
    roiSelectedThisType = edgeType == tt;
    
    for ff = 1:1:nfly
        roiSelectedFly = flyID == ff; % selected for this might be all zeros.
        numRoiPerFly(tt,ff) = sum(roiSelectedFly & roiSelectedThisType);
        numFirstKernelPerFly(tt,ff) = sum(roiSelectedFly & roiSelectedFirstThisType);
        
        % it takes a while to do the second...
        roiUse = find(roiSelectedFly & roiSelectedSecondThisType);
        for dx = 1:1:2
            numTemp = 0;
            for ii = 1:1:length(roiUse)
                roi = roiData{roiUse(ii)};
                % first
                [~,barUse] =  roiAnalysis_OneRoi_GetSecondKernel(roi,dx,'Original',false,false);
                numTemp = numTemp + length(barUse);
            end
           numSecondKernelPerFly(tt,ff,dx) = numTemp;
        end
    end
end

numFirstKernelPerType = sum(numFirstKernelPerFly,2);
numSecondKernelPerType = squeeze(sum(numSecondKernelPerFly,2));


numStat.nfly = nfly;
numStat.nFirstKernelPerType = numFirstKernelPerType;
numStat.nSecondKernelPerType = numSecondKernelPerType; % dx = 1, dx = 2;
numStat.nRoiPerFly = numRoiPerFly;
numStat.nFirstKernelPerFly = numFirstKernelPerFly;
numStat.nSecondKernelPerFly = numSecondKernelPerFly;