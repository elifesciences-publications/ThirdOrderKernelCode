function PlotOneRoi_Edge_Movie(roi)

% if isfield(roi.edge,'fc')
%     resp = roi.edge.fc.resp;
%     respLinear = roi.edge.fL;
%     stim = roi.edge.stim;
%     PlotEdgeResponseMovie(roi,resp,respLinear,stim);
% end
% 
% if isfield(roi.edge,'fr')
%     resp = roi.edge.fr.resp;
%     respLinear = roi.edge.fL;
%     stim = roi.edge.stim;
%    PlotEdgeResponseMovie(roi,resp,respLinear,stim);
% end
if isfield(roi.edge.f,'rectification')
    resp = roi.edge.f.rectification.resp;
    respLinear = roi.edge.fL;
    stim = roi.edge.stim;
    PlotEdgeResponseMovie(roi,resp,respLinear,stim);
end

if isfield(roi.edge.f,'softRectification')
    resp = roi.edge.f.softRectification.resp;
    respLinear = roi.edge.fL;
    stim = roi.edge.stim;
    PlotEdgeResponseMovie(roi,resp,respLinear,stim);
end
% if isfield(roi.edge.f,'nonp')
%     resp = roi.edge.f.nonp.resp;
%     respLinear = roi.edge.fL;
%     stim = roi.edge.stim;
%     PlotEdgeResponseMovie(roi,resp,respLinear,stim);
% end
   
%     PlotEdgeResponseMovie(roi,resp,respLinear,stim);