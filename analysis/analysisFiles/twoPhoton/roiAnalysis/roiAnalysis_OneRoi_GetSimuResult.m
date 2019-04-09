function [resp,barUse] = roiAnalysis_OneRoi_GetSimuResult(roi,dx,whichSimu)

switch whichSimu
    case 'glider'
        respInfo = roi.simu.sK.glider.resp;
    case 'sinewave'
        respInfo = roi.simu.sK.sine.resp;
end

switch dx
    case 1
        kernelInfo = roi.filterInfo.secondKernel.dx1;
        resp = respInfo.dx1;
    case 2
        kernelInfo = roi.filterInfo.secondKernel.dx2;
        resp = respInfo.dx2;
end
if isfield(kernelInfo,'barSelected')
    barSelected = kernelInfo.barSelected;
else
    barSelected = true(size(resp,2),1);
    
end
barUse = find(barSelected);

