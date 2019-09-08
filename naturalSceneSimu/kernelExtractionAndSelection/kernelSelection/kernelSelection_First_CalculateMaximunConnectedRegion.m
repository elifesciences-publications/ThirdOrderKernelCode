function [maxConnectedArea,barSelected]= kernelSelection_First_CalculateMaximunConnectedRegion(kernelZ,varargin)
threshZ = 2;
plotFlag = false;
timeRange = [2:25];
nMultiBars = size(kernelZ,2);
for ii = 1:2:length(varargin)
    str = [ varargin{ii} ' = varargin {' num2str(ii+1) '};'];
    eval(str);
end
kernelMap = abs(kernelZ) > threshZ;
kernelMap = repmat(kernelMap,[1,2]);

% which one is better??
se = strel('disk',1);
% se = strel('arbitrary',[1,1,1;1,1,1;1,1,1]);
kernelMapClose = imclose(kernelMap,se);

% you are going to create a kernelWindow;
kernelWindow = false(size(kernelMap));
kernelWindow(timeRange,:) = true;

kernelMap = kernelMap & kernelWindow;
kernelMapClose = kernelMapClose & kernelWindow;


connArea = bwconncomp(kernelMapClose,8);
nCon = connArea.NumObjects;
if nCon == 0
    maxConnectedArea = 0;
    barSelected = false(nMultiBars,1);
else
    numPixelPerRegion = zeros(nCon,1);
    for nn = 1:1:nCon
        numPixelPerRegion(nn) = length(connArea.PixelIdxList{nn});
    end
    
    [numPixelPerRegionLargest,whichArea]= sort(numPixelPerRegion,'descend');
    maxConnectedArea = numPixelPerRegionLargest(1);
    
    % also return the bar number
    [~,indS] = ind2sub(size(kernelMap), connArea.PixelIdxList{whichArea(1)});
    
    bars = unique(indS);
    instances = histc(indS,bars);
    
    % lowestValue for one map...3. if there is too many of them, select the
    % most 5 one...
    
    threshBar = 3;
    barUse = bars(instances >= threshBar)';
    
    if length(barUse) > 5;
        [value,ind] = sort(instances,'descend');
        barUse = bars(ind(1:5));
    end
    barUse = mod(barUse - 1,nMultiBars) + 1;
    barSelected = false(nMultiBars,1);
    barSelected(barUse) = true;
end

% for the maxConnecteArea, remmember which bar is being preserved...

if plotFlag
    disp(['the largest area is ' , num2str(maxConnectedArea)]);
    MakeFigure;
    subplot(3,3,1);
    quickViewOneKernel(kernelZ,1);
    colorbar;
    subplot(3,3,4);
    quickViewOneKernel(kernelMap,1);
    subplot(3,3,5);
    quickViewOneKernel(imdilate(kernelMap,se),1);
    subplot(3,3,6);
    quickViewOneKernel(kernelMapClose,1);
end
end

