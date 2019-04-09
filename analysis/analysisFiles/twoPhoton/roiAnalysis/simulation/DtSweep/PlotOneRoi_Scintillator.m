function PlotOneRoi_Scintillator(roi,varargin)
saveFigFlag = false;
nLNType = 1;
LNType = {'softRectification'};
flipByEyeFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

roiNumber  = roi.stimInfo.roiNum;
roiType = roi.typeInfo.edgeType;
roiName = roi.typeInfo.edgeName;
filename = roi.stimInfo.filename;
% do not use direction, but use eye. always put the progressive direction
% to the position 
flyEye = roi.flyInfo.flyEye;
% dirTypeStim = roi.prob.PStim.dirTypeEdge; % if should tell you left or right.


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
% MakeFigure;
% if isfield(roi.dtSweep,'fc')
%     subplot(2,2,1);
%     fx = roi.dtSweep.fc;
%     resp = fx.resp;
%     meanResp = fx.mean;
%     respLinear = roi.dtSweep.fL;
%     dtNumBank = roi.dtSweep.dtNumBank;
%     PlotDtSweepResponse(meanResp,resp,respLinear,dtNumBank,dirTypeStim,'1o,coe');
% end
% 
% if isfield(roi.dtSweep,'fr')
%         fx = roi.dtSweep.fr;
%      resp = fx.resp;
%     meanResp = fx.mean;
%     respLinear = roi.dtSweep.fL;
%     PlotDtSweepResponse(meanResp,resp,respLinear,dtNumBank,dirTypeStim,'1o,rec');
% end
% 
% if isfield(roi.dtSweep,'fnonp')
%     subplot(2,2,1);
%     fx = roi.dtSweep.fnonp;
%     resp = fx.resp;
%     meanResp = fx.mean;
%     respLinear = roi.dtSweep.fL;
%      dtNumBank = roi.dtSweep.dtNumBank;
%     PlotDtSweepResponse(meanResp,resp,respLinear,dtNumBank,dirTypeStim,'1o,non parametric');
% end
% 
% 
% if isfield(roi.dtSweep,'s')
%     subplot(2,2,2);
%     fx = roi.dtSweep.s;
%     resp = fx.resp;
%     meanResp = fx.mean;
%     PlotDtSweepResponse(meanResp,resp,'NA',dtNumBank,dirTypeStim,'2o');
% end

for ii = 1:1:nLNType
    LNTypeThis = LNType{ii};
    eval(['resp = roi.dtSweep.f.',LNTypeThis,'.resp;']);
    eval([' meanResp = roi.dtSweep.f.',LNTypeThis,'.mean;']);
    respLinear = roi.dtSweep.fL;
    dtNumBank = roi.dtSweep.dtNumBank;
    PlotDtSweepResponse(meanResp,resp,respLinear,dtNumBank,flyEye,LNTypeThis,flipByEyeFlag);
end

if saveFigFlag
%     
    PlotOneRoi_Save(gcf,titleStr,'Scint_1o');
    % save the data, by type, name, number and name
end
end