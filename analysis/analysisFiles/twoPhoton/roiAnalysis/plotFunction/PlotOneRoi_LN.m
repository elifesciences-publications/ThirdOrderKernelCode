function PlotOneRoi_LN(roi,varargin)
saveFigFlag = false;
plotSoftRectificationFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
roiNumber  = roi.stimInfo.roiNum;
roiType = roi.typeInfo.edgeType;
roiName = roi.typeInfo.edgeName;
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


if isfield(roi,'LN')
    predResp = roi.LN.predResp;
    resp = roi.LN.resp;
    PlotLNModel(predResp,resp);
end

if plotSoftRectificationFlag
    MakeFigure;
    PlotLNModel(predResp,resp);
    hold on
    % on top of that, plot...
    x = [-0.7:0.01:0.7];
    softRectificationCoe = roi.LN.fit_SoftRectification;
    y = MyLN_SoftRectification(x,softRectificationCoe);
    plot(x,y);

end
if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'LN');
    % save the data, by type, name, number and name
end
end