% collection of Fig2

nFigSave = 3;
figFileType = {'fig','eps','png'};
saveFigFlag = true;
roiUse = FigPlot2_IndividualKernelAndTrace(roiDataUseEdge,'saveFigFlag',saveFigFlag,'nFigSave',nFigSave,'figFileType',figFileType);
FigPlot2_KernelCenter(roiDataUseEdge,'saveFigFlag',saveFigFlag,'nFigSave',nFigSave,'figFileType',figFileType);
FigPlot2_MeanKernel(roiDataUseEdge,'saveFigFlag',saveFigFlag,'kernelOrZ','kernel','nFigSave',nFigSave,'figFileType',figFileType);
roiDataUseEdge = FigPlot2_LN(roiDataUseEdge,'saveFigFlag',saveFigFlag,'nFigSave',nFigSave,'figFileType',figFileType);

nLNType = 1;
LNType = {'softRectification'};
roiDataUseEdge = FigPlot_PredDSI_DSI(roiDataUseEdge,'roiCircled',roiUse,'nLNType',nLNType,'LNType',LNType);


% for rr = 1:1:length(roiDataUseEdge)
%     roiDataUseEdge{rr} = roiAnalysis_OneRoi_Edges(roiDataUseEdge{rr},'grayStartFlag',true,'nLNType',1,'LNType',LNType);
% end
roiDataUseEdge = FigPlot_PredESI_ESI(roiDataUseEdge,'roiCircled',roiUse,'nLNType',nLNType ,'LNType',LNType);
%%
% ViewFirstOrderKernelsByType(roiDataUseEdge,'titleByRoiSequenceFlag',true);
% % what if you exclude that fly? which moves a lot?
% roiUse = [40,3,41,42,85,92,49,87,99,106,1,3,57,68,]

%% for the best looking four kernels.