function PlotOneRoi_OLS_LN_And_Scond(roi)

% change the structure....
MakeFigure;
% plot the kernel first.
subplot(3,4,1)
quickViewOneKernel_Smooth(roi.LM.firstOrder.kernel,1,'labelFlag',false,'posUnit',5,'timeUnit',1/60);
title('1o kernel')

subplot(3,4,2);
predRespNonRep = roi.LM.firstOrder.predRespNonRep;
respNonRep = roi.LM.firstOrder.respNonRep;
PlotLNModel(predRespNonRep,respNonRep);
hold on
ax = gca;
x = ax.XLim(1):0.01:ax.XLim(2);
nonLinearity = roi.LM.nonLinearity; % w
plot(x,MyLN_Poly(x,nonLinearity.fit_Poly2,nonLinearity.lookUpTable,'setUpLowerBoundFlag',false)); % poly nomial, second order might not be enough. maybe third order kernel?
plot(x,MyLN_SoftRectification(x,nonLinearity.fit_SoftRectification));
legend('r','','poly2','rec');

subplot(3,4,3);
% what is 
respRep = roi.LM.firstOrder.resp;
predResp = roi.LM.firstOrder.predResp_L;
PlotLNModel(predResp,respRep);

subplot(3,4,4);
% find what is the non zeros kernel
barUsed = find(sum(roi.LM.secondOrder.kernel) ~= 0);
for qq = 1:1:length(barUsed)
%     subplot(2,4,qq +1);
    barNum = barUsed(qq);
    quickViewOneKernel_Smooth(roi.LM.secondOrder.kernel(:,barNum),2,'labelFlag',false,'posUnit',5,'timeUnit',1/60);
    title(['bar # ', num2str(barUsed(qq))]);
end

% you need a color scheme. 
colorTable.resp = [1,1,0]; % red
colorTable.firstOrder = [1,0,0]; % yellow
colorTable.secondOrder = [0,0,0]; % black
colorTable.LN_Poly2 = [0,1,0]; % green;
colorTable.LN_Rec = [0,0,1]; % blue;
colorTable.firstPlusSecond = [1,0,1]; % pink;

% it should be larger.
subplot(345)
% this should become a function as well.
varExplainedInterp = roi.repSegInfo.varExplainedByMeanInterp;
% varExplainedNonInterp = roi.repSegInfo.varExplainedByMeanNonInterp;

rFirst = roi.LM.firstOrder.r.byTrial;
rSecond = roi.LM.secondOrder.r.byTrial;
rLN_Rec = roi.LM.nonLinearity.r_SoftRectification.byTrial;
rLN_poly = roi.LM.nonLinearity.r_Poly.byTrial;
rFirstrPlusSecond = roi.LM.firstPlusSecond.r.byTrial;
data = [rFirst,rSecond,rLN_Rec,rLN_poly,rFirstrPlusSecond,varExplainedInterp];

FigPlot_Scatter_VarAndCorr(data,'tilteStr','Interpolation','legendStr',{'1o','2o','LN-Rec','LN-Poly','1o+2o'});
% markerArea = 1;
% LineWidth = 1;
% scatter(varExplainedInterp,rFirst.^2,markerArea ,'MarkerEdgeColor',colorTable.firstOrder,'MarkerFaceColor',colorTable.firstOrder,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
% scatter(varExplainedInterp,rSecond.^2,markerArea ,'MarkerEdgeColor',colorTable.secondOrder,'MarkerFaceColor',colorTable.secondOrder,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
% scatter(varExplainedInterp,rLN_poly.^2,markerArea ,'MarkerEdgeColor',colorTable.LN_Poly2,'MarkerFaceColor',colorTable.LN_Poly2,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
% scatter(varExplainedInterp,rLN_Rec.^2,markerArea ,'MarkerEdgeColor',colorTable.LN_Rec,'MarkerFaceColor',colorTable.LN_Rec,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
% scatter(varExplainedInterp,rFirstrPlusSecond.^2,markerArea ,'MarkerEdgeColor',colorTable.firstPlusSecond,'MarkerFaceColor',colorTable.firstPlusSecond,'LineWidth',LineWidth);hold on;xlabel('varExplainedByMean');
% ylabel('r^2' );
% legend('1o','2o','LN-Poly','LN-Rect','1o+2o');
% hold on; plot(0:0.01:0.4,0:0.01:0.4,'b--');
% title('Interpolation');



subplot(346) % for this roi, you could plot the bar plot with error bar. 5 bar plot.
% there would be 5 values. can you handle that? try
% you would use the function later on , so do not worry
% data = [rFirst.^2,rSecond.^2,rLN_poly.^2,rLN_Rec.^2,rFirstrPlusSecond.^2,varExplainedInterp,varExplainedNonInterp];
data = [rFirst.^2,rSecond.^2,rLN_poly.^2,rLN_Rec.^2,rFirstrPlusSecond.^2,varExplainedInterp];
FigPlot_BarPlot_Corr(data,'xTickStr',{'1o','2o','LN-Poly','LN-Rect','1o+2o','Interp'},'titleStr','variance and r^2','limPreSetNeg',true);

subplot(347); % plot the ratio.
% data = [rFirst.^2,rSecond.^2,rLN_poly.^2,rLN_Rec.^2,rFirstrPlusSecond.^2,varExplainedInterp,varExplainedNonInterp];
data = [rFirst.^2,rSecond.^2,rLN_poly.^2,rLN_Rec.^2,rFirstrPlusSecond.^2,varExplainedInterp];
data = bsxfun(@rdivide,data,varExplainedInterp);
FigPlot_BarPlot_Corr(data,'xTickStr',{'1o','2o','LN-Poly','LN-Rect','1o+2o','Interp'},'titleStr','ratio Over Interp','limPreSetNeg',true);

% subplot(348) % compare the varExplained by two method for each trial....
% scatter( roi.repSegInfo.varExplainedByMeanInterp,roi.repSegInfo.varExplainedByMeanNonInterp,'r.');
% xlabel('Interpolation');
% ylabel('No Interpolation');
% title('variance explained by mean');
% plot the ratio.



% subplot(346); % relationship between first order kernel and second order kernel
% show the relation between the response of first order kernel and second
% order kernel. 
% you have not save the two traces. you should? do not think of it for
% now...
% for the plotting, you have put everything as the second order kernel. I
% will pad something before the response of second order kernel,

subplot(3,4,9:12)
predUpSample_S = roi.LM.secondOrder.predRespByTrialUpSample;
predUpSample_S = [zeros(4,size(predUpSample_S,2));predUpSample_S];
respRepByTrialUpSample = roi.LM.firstOrder.respByTrialUpSample;
predUpSample_L = roi.LM.firstOrder.predRespByTrialUpSample;
predUpSample_L_S = predUpSample_L(end - size(predUpSample_S,1)+1:end,:) + predUpSample_S;
predUpSample_LN_Soft = roi.LM.nonLinearity.predResp_LN_SoftRectification_ByTrialUpSample;
predUpSample_LN_Poly = roi.LM.nonLinearity.predResp_LN_Poly_ByTrialUpSample;

% the legend is really strange...
% how are you going to plot this?
% what is wrong with my legend here?
stimHz = 60;timePlot = (1:size(respRepByTrialUpSample,1))'/stimHz;
legendStr = cell(9,1); % 5 for the first line. + 5 
sem = std(respRepByTrialUpSample,1,2)/sqrt(size(respRepByTrialUpSample,2));
PlotXY_Juyue(timePlot, mean(respRepByTrialUpSample,2),'errorBarFlag',true,'sem',sem,'colorMean',colorTable.resp,'colorError',colorTable.resp);
hold on 

% SNInfo.varExplainable = roiAnalysis_OneRoi_VarRepSeg(roi);
legendStr{1} = 'response'; % 
roi.SNInfo.varExplainable = 0; % this value was gone...
legendStr{2} = ['VarExplainable: '];
% legendStr{3} = ['std : ', num2str(sqrt(roi.SNInfo.varExplainable))];
legendStr{3} = '';
legendStr{4} = '';
legendStr{5} = '';
% predicted response of first order
plot(timePlot, mean(predUpSample_L,2),'color',colorTable.firstOrder,'lineWidth',3); % yellow
hold on 
legendStr{6} = (['1o : ',num2str(roi.LM.firstOrder.r.overall)]); % you should use the response, not hte mean response.

% predicted response of second order
plot(timePlot, mean(predUpSample_S,2),'color',colorTable.secondOrder,'lineWidth',3); % black
hold on 
legendStr{7} = ['2o : ',num2str(roi.LM.secondOrder.r.overall)]; % you should use the response, not hte mean response.
% predicted response of second plus first order
plot(timePlot, mean(predUpSample_L_S,2),'color',colorTable.firstPlusSecond,'lineWidth',3); % pink
hold on 
legendStr{8} = ['1o+2o : ',num2str(roi.LM.firstPlusSecond.r.overall)];
% LN model: polynomial;
plot(timePlot, mean(predUpSample_LN_Poly,2),'color',colorTable.LN_Poly2,'lineWidth',3); % green
legendStr{9} = ['LN-Poly : ',num2str(roi.LM.nonLinearity.r_Poly.overall)];
hold on 
% LN model; soft rectification
plot(timePlot, mean(predUpSample_LN_Soft,2),'color',colorTable.LN_Rec,'lineWidth',3); % blue
legendStr{10} = ['LNp-Soft : ',num2str(roi.LM.nonLinearity.r_SoftRectification.overall)];
% xlabel('time [60Hz frames]')
legend(legendStr)
hold off
xlabel('time [s]');
ylabel('\Delta F/F')

% you would plot a lot of things.

% first, LN.(2 of them, also plot the theoretical curve)

% kernel you are using. for the second order kernel, label which bar it is.

% time traces. (response, first order, second order, LN(poly,
% soft_rectification),first + second);