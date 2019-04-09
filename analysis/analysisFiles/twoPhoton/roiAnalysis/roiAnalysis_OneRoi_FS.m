function roiData = roiAnalysis_OneRoi_FS(roiData)
nMultiBarUse = 20;
filterInfo = roiData.filterInfo;
barSelected = filterInfo.barSelected;
firstKernel = filterInfo.firstKernel;

barUse = find(barSelected);
% how many bars are there
% if length(barUse) > 1 || isempty(barUse) % in trouble...
% %     barUse = barUse(1); 
%  disp('no second order kernel, or too much second order kernel, do not compute...');
%  roiData.secondKernelHat= [];
%  return;
% end
% use this bar and its right one...
if length(barUse) > 1
    barUse = barUse(1); %%%%% bad... the reslut
end
f1 = firstKernel(:,barUse);
f2 = firstKernel(:,MyMode(barUse+1,nMultiBarUse));

secondKernelHat = f1*f2';
% roiData.secondKernelHat = secondKernelHat; 
roiData.fps.sHat = secondKernelHat;
roiData.fps.f1 = f1;
roiData.fps.f2 = f2;
roiData.fps.barUse = barUse;

end