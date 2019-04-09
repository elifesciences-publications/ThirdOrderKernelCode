function PlotOneRoi_ft(roi,varargin)
nLNType = 2;
LNType = {'nonp','softRectification'};
saveFigFlag = false;
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

% if isfield(roi.ft,'fc')
%     subplot(3,1,1)
%     PlotFTResponse(roi.ft.fc.mean,roi.ft.omega,roi.ft.lambda);
%     title('frequency Tuning - LN: coe');
%
% end
for ii = 1:1:nLNType
    LNTypeThis = LNType{ii};
    eval(['meanResp = roi.ft.f.',LNTypeThis,'.mean;'])
    omega = roi.ft.omega;
    lambda = roi.ft.lambda;
    PlotFTResponse(meanResp,omega,lambda);
end

% if isfield(roi.ft.f,'nonp')
%     subplot(3,1,1)
%     PlotFTResponse(roi.ft.f.nonp.mean,roi.ft.omega,roi.ft.lambda);
%     title('frequency Tuning - LN: non parametric');
% %     if saveFigFlag
% %         PlotOneRoi_Save(gcf,titleStr,'Fre_Rec');
% %         % save the data, by type, name, number and name
% %     end
% end
% if isfield(roi.ft.f,'rectification')
%     subplot(3,1,2)
%     PlotFTResponse(roi.ft.f.rectification.mean,roi.ft.omega,roi.ft.lambda);
%     title('frequency Tuning - LN: rectification');
% %     if saveFigFlag
% %         PlotOneRoi_Save(gcf,titleStr,'Fre_Rec');
% %         % save the data, by type, name, number and name
% %     end
% end
%
% if isfield(roi.ft,'s')
%      subplot(3,1,3)
%     PlotFTResponse(roi.ft.s.mean,roi.ft.omega,roi.ft.lambda);
%     title('frequency Tuning - 2o');
% %     if saveFigFlag
% %         PlotOneRoi_Save(gcf,titleStr,'Fre_2o');
% %         % save the data, by type, name, number and name
% %     end
% end

if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'Fre');
    % save the data, by type, name, number and name
end
end