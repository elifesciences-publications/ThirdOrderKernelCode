function [flyResp, roiMask, extraVals] = IcaRegionRestrictedRoiExtraction(backgroundSubtractedMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin)



MakeFigure;
imagesc(mean(backgroundSubtractedMovie, 3));
colormap gray
restrictionMask = roipoly;

roiAcceptanceMask = ones(size(backgroundSubtractedMovie, 1), size(backgroundSubtractedMovie, 2));

roiAcceptanceMask = roiAcceptanceMask .* restrictionMask;

% uniqueVals = unique(roiMask);
% uniqueVals(uniqueVals==0) = [];

% flyRespInds = 1:size(flyResp, 2);

% outOfRegionRois = ~ismember(flyRespInds, uniqueVals);
% 
% for ii = 1:length(uniqueVals)
%     roiMask(roiMask==uniqueVals(ii)) = ii;
% end

deltaFOverF(~repmat(roiAcceptanceMask, [1 1 size(deltaFOverF, 3)])) = 0;

[flyResp, roiMask, extraVals] = IcaRoiExtraction(backgroundSubtractedMovie,deltaFOverF,epochStartTimes,epochDurations,params,varargin{:});