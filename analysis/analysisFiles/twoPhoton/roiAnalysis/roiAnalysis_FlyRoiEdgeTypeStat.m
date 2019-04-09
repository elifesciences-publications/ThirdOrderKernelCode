function numStat = roiAnalysis_FlyRoiEdgeTypeStat(roiData,varargin)
% only care about edgeType...
sortMethod = 'flyId';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
nType = 4;

nRoi = length(roiData);
edgeType = zeros(nRoi,1);
for rr = 1:1:nRoi
    edgeType(rr) = roiData{rr}.typeInfo.edgeType;
end

flyID = zeros(nRoi,1);
roiByFly = roiAnalysis_AnalyzeRoiByFly(roiData,sortMethod);
nfly = length(roiByFly);
for ff = 1:1:nfly
    roiUse = roiByFly(ff).roiUse;
    flyID(roiUse) = ff;
end


numRoiPerFly = zeros(nType,nfly);
for tt =1:1:nType
    roiSelectedThisType = edgeType == tt;
    for ff = 1:1:nfly
        roiSelectedFly = flyID == ff; % selected for this might be all zeros.
        numRoiPerFly(tt,ff) = sum(roiSelectedFly & roiSelectedThisType);        
    end
end

numStat.nfly = nfly;
numStat.nRoiPerFly = numRoiPerFly;