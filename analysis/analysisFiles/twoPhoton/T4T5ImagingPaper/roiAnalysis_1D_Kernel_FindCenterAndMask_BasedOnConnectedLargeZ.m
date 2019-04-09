function lobeInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_BasedOnConnectedLargeZ(kernelMap, kernelWindow)
se = strel('disk',1);
kernelMapClose = imclose(kernelMap,se);
kernelMap = kernelMap & kernelWindow;
kernelMapClose = kernelMapClose & kernelWindow;


connArea = bwconncomp(kernelMapClose,8);
nCon = connArea.NumObjects;
if nCon == 0
    maxConnectedArea = 0;
    center = [];
    mask = [];
else
    numPixelPerRegion = zeros(nCon,1);
    for nn = 1:1:nCon
        numPixelPerRegion(nn) = length(connArea.PixelIdxList{nn});
    end
    
    [numPixelPerRegionLargest,whichArea]= sort(numPixelPerRegion,'descend');
    maxConnectedArea = numPixelPerRegionLargest(1);
    
    % also return the bar number
    [indT,indS] = ind2sub(size(kernelMap), connArea.PixelIdxList{whichArea(1)});
    center = [mean(indT),mean(indS)];
    
    mask = false(size(kernelMap));
    a = connArea.PixelIdxList{whichArea(1)};
    mask(a) = true;
    % centerOut = [mean(indT),mean(indS)];
    
    lobeInfo.maxArea = maxConnectedArea;
    lobeInfo.center = center;
    lobeInfo.mask = mask;
end