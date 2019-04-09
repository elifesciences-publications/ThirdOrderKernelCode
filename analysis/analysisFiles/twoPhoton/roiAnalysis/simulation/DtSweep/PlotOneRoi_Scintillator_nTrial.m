function PlotOneRoi_Scintillator_nTrial(roi,saveFigFlag)
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
MakeFigure;
% there might be several bp responses due to different LN method...
if isfield(roi.dtSweep,'fc')
    PlotDtSweepResponse_nTrial(roi.dtSweep.fc,roiType,roiName);
    if saveFigFlag
        PlotOneRoi_Save(gcf,titleStr,'Scint_Coe');
        % save the data, by type, name, number and name
    end
end
MakeFigure;
if isfield(roi.dtSweep,'fr')
    PlotDtSweepResponse_nTrial(roi.dtSweep.fr,roiType,roiName);
    if saveFigFlag
        PlotOneRoi_Save(gcf,titleStr,'Scint_Rec');
        % save the data, by type, name, number and name
    end
end
    
MakeFigure;
if isfield(roi.dtSweep,'s')
    PlotDtSweepResponse_nTrial(roi.dtSweep.s,roiType,roiName);
    if saveFigFlag
        PlotOneRoi_Save(gcf,titleStr,'Scint_2o');
        % save the data, by type, name, number and name
    end
end
end