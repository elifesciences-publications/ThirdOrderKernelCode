%%
function [cstruct,maxPointsInEachLevel,whichContour,traceToPlot] = MyContour2poly(c,levels)

idxlabel = 1;
l = 1;
cstruct = struct('level', {}, 'x', {}, 'y', {},'n',{});
while idxlabel <= size(c,2)
    n = c(2,idxlabel);
    cstruct(l).x = c(1,idxlabel+(1:n));
    cstruct(l).y = c(2,idxlabel+(1:n));
    cstruct(l).level = c(1,idxlabel);
    cstruct(l).n = n;
    l = l+1;
    idxlabel = idxlabel+n+1;
end

% how many contours in total?
nContour = l - 1;
% find the largest area for each level.
levelAll = size(nContour,1);
numPoints = size(nContour,1);
for ii = 1:1:nContour
    levelAll(ii) = cstruct(ii).level;
    numPoints(ii) = cstruct(ii).n;
end

% 
nLevels = length(levels);
maxPointsInEachLevel = zeros(nLevels,1);
whichContour = zeros(nLevels,1);
traceToPlot = cell(nLevels,1);
for ll = 1:1:nLevels
    areaUse = find(levelAll == levels(ll));
    [maxPointsInEachLevel(ll),which] = max(numPoints(areaUse));
    which = areaUse(which);
    whichContour(ll) = which;
    n = cstruct(which).n;
    traceToPlot{ll} = zeros(n,2);
    traceToPlot{ll}(:,1) = cstruct(which).x;
    traceToPlot{ll}(:,2) = cstruct(which).y;
end

% determine whether the contour is large enough to be drawn...
% contour draw;
% for each leve, find the largest contour and estimate how large it is...


% also compute the largest area for each level.