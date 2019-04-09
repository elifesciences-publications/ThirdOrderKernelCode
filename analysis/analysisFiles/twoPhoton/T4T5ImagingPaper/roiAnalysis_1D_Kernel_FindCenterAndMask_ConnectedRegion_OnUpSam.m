function lobeInfo = roiAnalysis_1D_Kernel_FindCenterAndMask_ConnectedRegion_OnUpSam(kernelMap)
% barUse would detemine the center,
maxNumCombineArea = 4;
dThresh = 100;
maskInit = false(size(kernelMap));
mask = false(size(kernelMap));
flag = false;

% from these map, you could dilate a little bit...
% se = strel('disk',4,4);
% % kernelMap = imdilate(kernelMap,se);
% kernelMap = imdilate(kernelMap,se);

connArea = bwconncomp(kernelMap,8);
nCon = connArea.NumObjects;
numPixelPerRegion = zeros(nCon,1);
for nn = 1:1:nCon
    numPixelPerRegion(nn) = length(connArea.PixelIdxList{nn});
end
[numPixelPerRegionLargest,whichArea]= sort(numPixelPerRegion,'descend');

center = zeros(nCon,2);
for nn = 1:1:nCon
    [indT,indS] = ind2sub(size(kernelMap), connArea.PixelIdxList{whichArea(nn)});
    center(nn,:) = [mean(indT),mean(indS)];
end

d = zeros(nCon,1);
centerLargest = center(1,:);
for nn = 1:1:nCon
   d(nn) = sqrt(sum((centerLargest - center(nn,:)).^2));
end
[dSort,dIndSort] = sort(d,'ascend');
nDSmallerThanThresh = sum(dSort < dThresh);


connSelectedByDist = false(nCon,1);
connSelectedByDist(dIndSort(1:nDSmallerThanThresh))= 1; %
numPixelPerRegionNearby =  numPixelPerRegionLargest(connSelectedByDist);
[numPixelPerRegionNearby,~] = sort(numPixelPerRegionNearby,'descend');
nAreaCombine = min([nDSmallerThanThresh,maxNumCombineArea]);
areaCombine = sum(numPixelPerRegionNearby(1:nAreaCombine));

selectedRegion = whichArea(connSelectedByDist); % the index becomes extremely confusing now...

for ii = 1:1:length(selectedRegion)
    a = connArea.PixelIdxList{selectedRegion(ii)};
    maskInit(a) = true;
    % centerOut = [mean(indT),mean(indS)];
end

if  (numPixelPerRegionLargest(1) >= 1300)
    flag = true;
    mask = maskInit;
elseif ~(numPixelPerRegionLargest(1) >= 1300) && (areaCombine >= 1600)
   flag = true; 
   % construct the the filter your self...
   h = fspecial('average',[20,10]);
   h = h > 0;
   se = strel('arbitrary',h);
   mask = imdilate(maskInit,se);
end


if flag

    [indT,indS] = ind2sub(size(kernelMap),find(mask == 1));
    centerOut = [mean(indT),mean(indS)];
else
    mask  = zeros(size(kernelMap));
    centerOut =[];
end
centerOut = round(centerOut);

% if the center is very late,
lobeInfo.flag = flag;
lobeInfo.center = centerOut;
lobeInfo.mask = mask;

% 
% if  areaCombine > 2500
%     flag = true;
% 
% end
% % if the largest regio is larger than something, you are good.?
% [indT,indS] = ind2sub(size(kernelMap), connArea.PixelIdxList{whichArea(1)});
% centerOut = [mean(indT),mean(indS)];
% if numPixelPerRegionLargest(1) > 1700
%     flag = true;
%     a = connArea.PixelIdxList{whichArea(1)};
%     mask(a) = true;
%     mask = reshape(mask,size(kernelMap));
% else
%     flag = false;
%     mask  = zeros(size(kernelMap));
%     centerOut =[];
% end
% lobeInfo.flag = flag;
% lobeInfo.center = centerOut;
% lobeInfo.mask = mask;
% disp(['maxArea:',num2str(numPixelPerRegionLargest(1)),' numAreaCombines:',num2str(nAreaCombine),' areaCombine:',num2str(areaCombine),' flag:',num2str(flag)]);

end
