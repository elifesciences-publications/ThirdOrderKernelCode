function PlotAllRoi_LNModel_RAndVar(roiData,roiSelected,varargin)
titleStr = '';
interpolationFlagForExpVarFlag = true;
nFigSave = 1;
figFileType = {'fig'};
MainName = '';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% this is a really bad idea... to put this function here. you should ignore
% this, find a way to only use 777
% nRoi = length(roiData);
% for rr = 1:1:nRoi
%     roiData{rr} = roiAnalysis_OneRoi_VarRepSeg(roiData{rr},'interpolationFlagForSNR',false);
% end
% % plot the relationship
nRoi = length(roiData);
% plot only the interpolated data....
if interpolationFlagForExpVarFlag
    varExplained = cellfun(@(x) nanmean(x.repSegInfo.varExplainedByMeanInterp),roiData);
else
    varExplained = cellfun(@(x) nanmean(x.repSegInfo.varExplainedByMeanNonInterp),roiData);
end


rFirst = cellfun(@(x) x.LM.firstOrder.r.overall,roiData);
rSecond = cellfun(@(x) x.LM.secondOrder.r.overall,roiData);
rLN_Rec = cellfun(@(x) x.LM.nonLinearity.r_SoftRectification.overall,roiData);
rLN_Poly2 = cellfun(@(x) x.LM.nonLinearity.r_Poly.overall,roiData);
rFirstPlusSecond = cellfun(@(x) x.LM.firstPlusSecond.r.overall,roiData);
if interpolationFlagForExpVarFlag
    pRepSeg = cellfun(@(x) x.repSegInfo.pInterp,roiData);
else
    pRepSeg = cellfun(@(x) x.repSegInfo.pNonInterp,roiData);
end

dataR = [rFirst,rSecond,rLN_Poly2,rLN_Rec,rFirstPlusSecond,varExplained];
% no need to plot them all.
dataROverVariance = bsxfun(@rdivide,dataR ,varExplained);

MakeFigure;
subplot(2,2,1);
FigPlot_BarPlot_Corr(dataR(roiSelected,:),'xTickStr',{'1o','2o','LN-Poly','LN-Rec','1o+2o','Variance Explained By Mean'},'yLabelStr','corr(predRespByModel,resp) or corr(mean resp,resp)','titleStr',titleStr,'limPreSetNeg',true);
subplot(2,2,2);
FigPlot_BarPlot_Corr(dataROverVariance(roiSelected,:),'xTickStr',{'1o','2o','LN-Poly','LN-Rec','1o+2o','Variance Explained By Mean'},'yLabelStr','ratio : corr(predRespByModel,resp)/corr(mean resp,resp)','titleStr',titleStr,'limPreSetNeg',true);

subplot(2,2,3)
markerArea = 10;
LineWidth = 1;
legendStr = {'1o','2o','LN-Poly','LN-Rec','1o+2o'};
FigPlot_Scatter_VarAndCorr(dataR(roiSelected,:),'tilteStr',titleStr,'legendStr',legendStr,'markerArea',markerArea,'LineWidth',LineWidth,'setLogScaleFlag',true);

end