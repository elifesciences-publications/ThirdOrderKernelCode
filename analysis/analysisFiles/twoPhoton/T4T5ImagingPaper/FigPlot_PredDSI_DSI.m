function roiData = FigPlot_PredDSI_DSI(roiData,varargin)
% you also want to circle the kernel which is shown in the first plot...
% here, the roiData must has LN computed already....
nRoi = length(roiData);
nLNType = 2;
LNType = {'nonp','softRectification'};
saveFigFlag = false;
MainName = 'Fig2_c_DSI_';
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
if ~isfield(roiData{1},'squareResp')
    for rr = 1:1:nRoi
        % determin which type do you want to keep?
        roiData{rr} = roiAnalysis_OneRoi_SquareWave(roiData{rr},'nLNType',nLNType,'LNType',LNType);
    end
end

if ~isfield(roiData{1}.typeInfo,'dirDiff')
    for rr = 1:1:nRoi
        roiData{rr} = roiAnalysis_dirDifference(roiData{rr});
    end
end
%
%% second, PredictedDSI and DSI
dirType = zeros(nRoi,1);
dirTypeEdge = zeros(nRoi,1);

DSI = zeros(nRoi,1);
DSI_Edge = zeros(nRoi,1);

edgeType = zeros(nRoi,1);
%

dirDiff = zeros(nRoi,1);

for ii = 1:1:nLNType
    LNTypeThis = LNType{ii};
    eval(['predDSI.', LNTypeThis,' = zeros(nRoi,1);']);
    eval(['predDirDiff.', LNTypeThis,' = zeros(nRoi,1);']);
end
for rr = 1:1:nRoi
    roi = roiData{rr};
    edgeType(rr) = roi.typeInfo.edgeType;
    
    % direction selectivity index
    dirType(rr) = roi.typeInfo.dirType;
    dirTypeEdge(rr) = roi.typeInfo.dirTypeEdge;
    DSI(rr) = roi.typeInfo.DSI_Diff;
    DSI_Edge(rr) = roi.typeInfo.DSI_Edge;
    dirDiff(rr) = roi.typeInfo.dirDiff;
    for ii = 1:1:nLNType
        LNTypeThis = LNType{ii};
        % predDSI.nonp(rr) = roi.squareResp.f.nonp.DSI;
        eval(['predDSI.',LNTypeThis,'(rr) = roi.squareResp.f.',LNTypeThis,'.DSI;']);
        eval(['predDirDiff.',LNTypeThis,'(rr) = roi.squareResp.f.',LNTypeThis,'.dirDiff;']);
    end
    % direction selectivity, only using the differences between mean value.
    
end

DSI(DSI > 1) = 1;
DSI(DSI < -1) = -1;
for ii = 1:1:nLNType
    LNTypeThis = LNType{ii};
    eval(['predDSI.',LNTypeThis,'(predDSI.',LNTypeThis,' < -1) = -1;']);
    eval(['predDSI.',LNTypeThis,'(predDSI.',LNTypeThis,' > 1) = 1;']);
end

yLabelStr = {'Actual DSI(Square)','Actual DSI(Edge)'};
xLabelStr = {'predicted DSI (Square)'};



for ii = 1:1:nLNType
    LNTypeThis = LNType{ii};
    eval(['predDSIPlot = predDSI.',LNTypeThis,';']);
    eval(['predDirDiffPlot = predDirDiff.',LNTypeThis,';'])
    MakeFigure;
%     subplot(2,2,1);
%     r = corr(predDSIPlot,DSI,'type','Spearman');
%     titleStr = ['LN Method : ',LNType{1},sprintf('   r : %0.2f',r)];
%     FigPlot_IndexScatter(predDSIPlot,DSI,edgeType,xLabelStr,yLabelStr{1},titleStr);
%     subplot(2,2,2);
%     r = corr(predDSIPlot,DSI_Edge,'type','Spearman');
%     titleStr = ['LN Method : ',LNType{1},sprintf('   r : %0.2f',r)];
%     FigPlot_IndexScatter(predDSIPlot,DSI_Edge,edgeType,xLabelStr,yLabelStr{2},titleStr);
%     subplot(2,2,3)
%     r = corr(dirDiff,DSI,'type','Spearman');
%     titleStr = ['LN Method : ',LNType{1},sprintf('   r : %0.2f',r)];
%     
%     FigPlot_DiffScatter(dirDiff,DSI,edgeType,'Actual: Prog - Reg (Square)','DSI (Square)',titleStr);
%     subplot(2,2,4)
    r = corr(predDirDiffPlot,dirDiff,'type','Spearman');
    titleStr = ['LN Method : ',LNType{1},sprintf('   r : %0.2f',r)];
    FigPlot_DiffScatter(predDirDiffPlot,dirDiff,edgeType,'Predicted : Prog - Reg (Square)','Actual: Prog - Reg (Square)',titleStr);
    
    % after this scatter plot.
    hold on
    scatter(predDirDiffPlot(roiCircled),dirDiff(roiCircled),'yo','lineWidth',2);
    hold off
    
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,LNTypeThis,'nFigSave',nFigSave,'fileType',figFileType);
    end
end
% roiDataUse = roiData([roiCircled]);
% for rr = 1:1:length(roiDataUse)
%     PlotOneRoi_KernelAndTrace(roiDataUse{rr});
% end
% ViewFirstOrderKernelsByType(roiDataUse);
% roiUse;
% roiSelected = predDirDiffPlot > 0 & dirDiff < 0;
% roiUse = find(roiSelected)'
end

