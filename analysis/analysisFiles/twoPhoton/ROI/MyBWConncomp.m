function masks = MyBWConncomp(BW,minPixNumber)

CC = bwconncomp(BW,8);
nCon = CC.NumObjects;
numPixelPerRegion = zeros(nCon,1);
for nn = 1:1:nCon
    numPixelPerRegion(nn) = length(CC.PixelIdxList{nn});
end
indConLarge  = find(numPixelPerRegion > minPixNumber);
nLCon = length(indConLarge);

masks = zeros(size(BW,1)* size(BW,2),nLCon);

for nn = 1:1:nLCon
    indThisRegion = CC.PixelIdxList{indConLarge(nn)};
    masks(indThisRegion,nn) = 1;
end

masks = reshape(masks,size(BW,1),size(BW,2),nn);

area_of_each_region = cellfun(@(x) length(x), CC.PixelIdxList);
area_of_each_region = area_of_each_region(indConLarge);
[~, largest_masks] = max(area_of_each_region);
masks = masks(:, :, largest_masks);
% find the largest region.
%% test whether there are overlap between masks. there is no overlap, good!
% 
% masksSum = sum(masks,3);
% MakeFigure;
% imagesc(masksSum);
