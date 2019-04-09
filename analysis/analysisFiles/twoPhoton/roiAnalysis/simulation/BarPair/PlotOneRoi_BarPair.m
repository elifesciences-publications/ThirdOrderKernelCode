function PlotOneRoi_BarPair(roi,saveFigFlag)
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

% there might be several bp responses due to different LN method...
if isfield(roi.bp,'fc')
%     PlotBarPair_Full(roi.bp.fc,roiType,roiName);
    PlotBarPair_Full_PDNDCompare(roi.bp.fc,roiType,roiName)
    if saveFigFlag
        PlotOneRoi_Save(gcf,titleStr,'BarPair_Coe');
        % save the data, by type, name, number and name
    end
end

if isfield(roi.bp,'fr')
%     PlotBarPair_Full(roi.bp.fr,roiType,roiName);
    PlotBarPair_Full_PDNDCompare(roi.bp.fr,roiType,roiName)
    if saveFigFlag
        PlotOneRoi_Save(gcf,titleStr,'BarPair_Rec');
        % save the data, by type, name, number and name
    end
end
    
    
end