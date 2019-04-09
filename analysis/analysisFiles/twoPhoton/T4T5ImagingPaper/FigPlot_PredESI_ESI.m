function roiData = FigPlot_PredESI_ESI(roiData,varargin)
nRoi = length(roiData);
nLNType = 2;
LNType = {'nonp','softRectification'};
grayStartFlag = true;
saveFigFlag = false;
MainName = 'Fig2_c_ESI_';
nFigSave = 3;
figFileType = {'fig','eps','png'};
roiCircled = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% first, calcualte the response to square waves.
% test whether the LN is computed.
if ~isfield(roiData{1},'LN')
    for rr = 1:1:nRoi
        roiData{rr} = roiAnalysis_OneRoi_LN_OLS(roiData{rr});
    end
    
end
if ~isfield(roiData{1},'edge')
    for rr = 1:1:nRoi
        roiData{rr} = roiAnalysis_OneRoi_Edges(roiData{rr},'grayStartFlag',grayStartFlag,'nLNType',nLNType,'LNType',LNType);
    end
end

if ~isfield(roiData{1}.typeInfo,'contDiff_Combined')
    for rr = 1:1:nRoi
        roiData{rr} = roiAnalysis_contrastDifferece(roiData{rr});
    end
end

if ~isfield(roiData{1}.typeInfo,'dirDiff')
    for rr = 1:1:nRoi
        roiData{rr} = roiAnalysis_dirDifference(roiData{rr});
    end
end
%

%% First, Predicted ESI and Resp ESI.
% combined and prefered.
contrastType = zeros(nRoi,1);
edgeType = zeros(nRoi,1);

LDSI_Combined = zeros(nRoi,1);
LDSI_Prefered = zeros(nRoi,1);
contDiff_Combined = zeros(nRoi,1);
contDiff_Prefered = zeros(nRoi,1);

DSIEdge_Combined = zeros(nRoi,1);
DSIEdge_Prefered = zeros(nRoi,1);
dirDiffEdge_Combined = zeros(nRoi,1);
dirDiffEdge_Prefered = zeros(nRoi,1);
% prediction, you have to compute the difference...
% predicted response.
for jj = 1:1:nLNType
    LNTypeThis = LNType{jj};
    eval(['predLSDI_Prefered.',LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predLSDI_Combined.',LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predDSI_Prefered.',LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predDSI_Combined.',LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predContDiff_Prefered.',LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predContDiff_Combined.',LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predDirDiff_Prefered.',LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predDirDiff_Combined.',LNTypeThis,' = zeros(nRoi,1);']);
    
end

for rr = 1:1:nRoi
    roi = roiData{rr};
    contrastType(rr) = roi.typeInfo.contrastType;
    edgeType(rr) = roi.typeInfo.edgeType;
    LDSI_Prefered(rr) = roi.typeInfo.LDSI_PreferedDir;
    LDSI_Combined(rr) = roi.typeInfo.LDSI_Combined;
    contDiff_Combined(rr) = roi.typeInfo.contDiff_Combined;
    contDiff_Prefered(rr) = roi.typeInfo. contDiff_PreferedDir;
    
    DSIEdge_Combined(rr) = roi.typeInfo.DSIEdge_Combined;
    DSIEdge_Prefered(rr) = roi.typeInfo.DSIEdge_PreferedCont;
    dirDiffEdge_Combined(rr) = roi.typeInfo.dirDiffEdge_Combined;
    dirDiffEdge_Prefered(rr) = roi.typeInfo.dirDiffEdge_PreferedCont;
    
    for jj = 1:1:nLNType
        LNTypeThis = LNType{jj};
        eval(['predLSDI_Prefered.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.LDSI_PreferedDir;']);
        eval(['predLSDI_Combined.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.LDSI_Combined;']);
        eval(['predDSI_Prefered.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.DSI_PreferedCont;']);
        eval(['predDSI_Combined.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.DSI_Combined;']);
        
        eval(['predContDiff_Prefered.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.contDiff_PreferedDir;']);
        eval(['predContDiff_Combined.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.contDiff_Combined;']);
        eval(['predDirDiff_Prefered.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.dirDiff_PreferedCont;']);
        eval(['predDirDiff_Combined.',LNTypeThis,'(rr) = roi.edge.f.',LNTypeThis,'.SI.dirDiff_Combined;']);
        
    end
end

for jj = 1:1:nLNType
    LNTypeThis = LNType{jj};
    eval(['predLSDI_Prefered.',LNTypeThis,'(predLSDI_Prefered.',LNTypeThis,' > 1) = 1;']);
    eval(['predLSDI_Prefered.',LNTypeThis,'(predLSDI_Prefered.',LNTypeThis,' < - 1) = -1;']);
    
    eval(['predLSDI_Combined.',LNTypeThis,'(predLSDI_Combined.',LNTypeThis,' > 1) = 1;']);
    eval(['predLSDI_Combined.',LNTypeThis,'(predLSDI_Combined.',LNTypeThis,' < - 1) = -1;']);
    
    eval(['predDSI_Prefered.',LNTypeThis,'(predDSI_Prefered.',LNTypeThis,' > 1) = 1;']);
    eval(['predDSI_Prefered.',LNTypeThis,'(predDSI_Prefered.',LNTypeThis,' < - 1) = -1;']);
    
    eval(['predDSI_Combined.',LNTypeThis,'(predDSI_Combined.',LNTypeThis,' > 1) = 1;']);
    eval(['predDSI_Combined.',LNTypeThis,'(predDSI_Combined.',LNTypeThis,' < - 1) = -1;']);
    
end

% there will be four pictures;
for jj = 1:1:nLNType
    LNTypeThis = LNType{jj};
    
    eval(['predLSDI_Prefered_Plot = predLSDI_Prefered.',LNTypeThis,';']);
    eval(['predLSDI_Combined_Plot = predLSDI_Combined.',LNTypeThis,';']);
    eval(['predContDiff_Prefered_Plot = predContDiff_Prefered.',LNTypeThis,';']);
    eval(['predContDiff_Combined_Plot = predContDiff_Combined.',LNTypeThis,';']);
    
    eval(['predDSI_Prefered_Plot = predDSI_Prefered.',LNTypeThis,';']);
    eval(['predDSI_Combined_Plot = predDSI_Combined.',LNTypeThis,';']);
    eval(['predDirDiff_Prefered_Plot = predDirDiff_Prefered.',LNTypeThis,';']);
    eval(['predDirDiff_Combined_Plot = predDirDiff_Combined.',LNTypeThis,';']);
    
    % predContDiff_Combined
    MakeFigure;
    %     % first, ESI.
%     %     prefered. combined. index/difference.
%     subplot(2,2,1)
%     r = corr(predLSDI_Prefered_Plot,LDSI_Prefered,'type','Spearman');
%     titleStr = [', r : ', num2str(r)];
%     FigPlot_IndexScatter(predLSDI_Prefered_Plot,LDSI_Prefered,edgeType,'predicted: ESI (at prefered dir)','Actual: ESI ',[LNTypeThis,titleStr]);
%     subplot(2,2,2)
%     r = corr(predLSDI_Combined_Plot,LDSI_Combined,'type','Spearman');
%     titleStr = [', r : ', num2str(r)];
%     FigPlot_IndexScatter(predLSDI_Combined_Plot,LDSI_Combined,edgeType,'predicted: ESI (combine both dir)','Actual: ESI ',[LNTypeThis,titleStr]);
%     subplot(2,2,3)
%     r = corr(predContDiff_Prefered_Plot,contDiff_Prefered,'type','Spearman');
%     titleStr = [', r : ', num2str(r)];
%     FigPlot_DiffScatter(predContDiff_Prefered_Plot,contDiff_Prefered,edgeType,'predicted: Light - Dark (at preferred dir)','Actual',[LNTypeThis,titleStr]);
%     set(gca,'XLim',[-2,2]);
%     
%     subplot(2,2,4)
    r = corr(predContDiff_Combined_Plot,contDiff_Combined,'type','Spearman');
    % calculate the rank order....
    titleStr = [', r : ', num2str(r)];
    FigPlot_DiffScatter(predContDiff_Combined_Plot,contDiff_Combined,edgeType,'predicted: Light - Dark (combine both dir)','Actual:',[LNTypeThis,titleStr]);
    set(gca,'XLim',[-2,2]);
    % calculate the r value, put that on the title...
    hold on
    scatter(predContDiff_Combined_Plot(roiCircled),contDiff_Combined(roiCircled),'ko','lineWidth',2);
    hold off
    
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,LNTypeThis,'nFigSave',nFigSave,'fileType',figFileType);
    end
    % second DSI
    %      MakeFigure;
    %     % first, ESI.
    %     % prefered. combined. index/difference.
    %     subplot(2,2,1)
    %     FigPlot_IndexScatter(predDSI_Prefered_Plot,DSIEdge_Prefered,edgeType,'predicted: DSI (at prefered dir)','Actual: DSI (edge) ',LNTypeThis);
    %     subplot(2,2,2)
    %     FigPlot_IndexScatter(predDSI_Combined_Plot,DSIEdge_Combined,edgeType,'predicted: DSI (combine both dir)','Actual: DSI (edge) ',LNTypeThis);
    %     subplot(2,2,3)
    %     FigPlot_DiffScatter(predDirDiff_Prefered_Plot,dirDiffEdge_Prefered,edgeType,'predicted: prog - reg (at prefered dir)','Actual',LNTypeThis);
    %     subplot(2,2,4)
    %     FigPlot_DiffScatter(predDirDiff_Combined_Plot,dirDiffEdge_Combined,edgeType,'predicted: prog - red (combine both dir)','Actual',LNTypeThis);
    %
    
end

% plot those four regressive. why is the result so wired...
% % 
% edgeTypeCircled = edgeType(roiCircled);
% roiUse = roiCircled(edgeTypeCircled == 4);
% roiDataUse = roiData([roiUse]);
% for rr = 1:1:length(roiDataUse)
%     PlotOneRoi_Edge(roiDataUse{rr},'nLNType',nLNType,'LNType',LNType);
% % MakeFigure;
% %     PlotOneRoi_Edge_Movie(roiDataUse{rr});
% end

roiSelected = predContDiff_Prefered_Plot< 0 & contDiff_Prefered > 0;
roiUse = find(roiSelected)
% roiSelected = (DSI_Edge > 0 & predDSI_Prefered < 0);
% roiUse = find(roiSelected)'
%
% roiSelected = (DSI_Edge < 0 & predDSI_Prefered > 0);
% roiUse = find(roiSelected)'
end

