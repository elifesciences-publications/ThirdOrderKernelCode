function PlotOneRoi_SquareWave(roi,varargin)
nLNType = 2;
LNType = {'nonp','softRectification'};

roiNumber  = roi.stimInfo.roiNum;
roiType = roi.typeInfo.edgeType;
roiName = roi.typeInfo.edgeName;
filename = roi.stimInfo.filename;
saveFigFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

titleStr = [];
% change the structure... roiName + filename + roiNumber + subname
if roiType < 5
    titleStr = [roiName,'_ ',filename,'_ Roi_ ', num2str(roiNumber)];
elseif roiType >= 5 && roiType <= 20
    titleStr = [roiName{1},'_ ',roiName{2},filename,'_ Roi_ ', num2str(roiNumber)];
else
    titleStr =['NotClear',filename,'_ Roi_ ', num2str(roiNumber)];
end

% 
% if isfield(roi.squareResp.f,'rectification')
%     resp = roi.squareResp.f.rectification.resp;
%     respLinear = roi.squareResp.f.respLinear;
%     stim = roi.squareResp.f.stim;
%     PlotSquareWaveResponse(resp,respLinear,stim);
%     %     PlotEdgeResponseMovie(roi,resp,respLinear,stim);
% end
% 
% if isfield(roi.squareResp.f,'nonp')
%     resp = roi.squareResp.f.nonp;
%     respLinear = roi.squareResp.f.respLinear;
%     stim = roi.squareResp.f.stim;
%     PlotSquareWaveResponse(resp,respLinear,stim);
%     %     PlotEdgeResponseMovie(roi,resp,respLinear,stim);
% end
for ii = 1:1:nLNType
    LNTypeThis = LNType{ii};
    eval(['resp = roi.squareResp.f.',LNTypeThis,'.resp;']);
    respLinear = roi.squareResp.f.respLinear;
    stim = roi.squareResp.f.stim;
    PlotSquareWaveResponse(resp,respLinear,stim);
    
end


% if isfield(roi.squareResp,'fr')
%     resp = roi.squareResp.fr.resp;
%     respLinear = roi.squareResp.f.respLinear;
%     stim = roi.squareResp.f.stim;
%     PlotSquareWaveResponse(resp,respLinear,stim);
% end


if saveFigFlag
    PlotOneRoi_Save(gcf,titleStr,'EdgeResponse');
    % save the data, by type, name, number and name
end
end