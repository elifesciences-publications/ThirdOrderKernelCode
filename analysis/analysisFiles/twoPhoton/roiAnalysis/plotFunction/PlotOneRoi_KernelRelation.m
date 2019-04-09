function PlotOneRoi_KernelRelation(roi,saveFigFlag)
roiNumber  = roi.stimInfo.roiNum;
roiType = roi.typeInfo.type;
roiName = roi.typeInfo.Name;
filename = roi.stimInfo.filename;

titleStr = [];
% change the structure... roiName + filename + roiNumber + subname
if roiType < 5
    titleStr = [roiName,'_ ',filename,'_ Roi_ ', num2str(roiNumber)];
elseif roiType >= 5 && roiType <= 20
    titleStr = [roiName{1},'_ ',roiName{2},filename,'_ Roi_ ', num2str(roiNumber)];
else
    titleStr =['NotClear',filename,'_ Roi_ ', num2str(roiNumber)];
end

f1 = roi.fps.f1;
f2 = roi.fps.f2;
secondKernelHat = roi.fps.sHat;
secondKernel = roi.filterInfo.secondKernel;
firstKernel = roi.filterInfo.firstKernel;
barUse = roi.fps.barUse;

subplot(2,2,1);
quickViewOneKernel(secondKernelHat(:),2);
title('f1 * f2');
subplot(2,2,2);
secondKernel = secondKernel(:,barUse);
sK = reshape(secondKernel,[64,64]);
sK = sK(1:30,1:30);
secondKernel = sK(:);
quickViewOneKernel(secondKernel,2);

title('2o')
subplot(2,2,3);
quickViewOneKernel(firstKernel,1);
set(gca,'XTick',[barUse,barUse + 1],'XTickLabel',{'+'});
title('1o')
subplot(2,2,4);
plot(f1,'r');
hold on
plot(f2,'b');
title('f1/f2');
hold off
if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'1o2oRelation');
    % save the data, by type, name, number and name
end


end