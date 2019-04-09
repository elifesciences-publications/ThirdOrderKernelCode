function roiBounderiesUse = MyBWBoundaries(bwMap)
roiBoundaries = bwboundaries(bwMap,8,'noholes');

nBoundary = length(roiBoundaries);
nEle = zeros(nBoundary,1);
for ii = 1:1:nBoundary
    nEle(ii) = size(roiBoundaries{ii},1);
end
[~,whichUse] = max(nEle);
roiBounderiesUse{1} = roiBoundaries{whichUse};
% find the largest and return it.
end
