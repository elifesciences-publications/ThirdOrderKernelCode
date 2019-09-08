function roiBarPicked = PickRoiBarOnP(h,threshold)

% only the roi and bar whose kernel has a lot of significant value will be
% set to one.

sumH = sum(h);
roiBarPicked = squeeze(sumH > threshold);
end