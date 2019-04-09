function PlotAllRoi_Simu_VarAndRSquare(roiData,varargin)
% PlotAllRoi_Simu_VarAndRSquare(roiData,'titleStr','firstOnly','interpolationFlagForExpVarFlag',true)
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
varExplained = zeros(nRoi,1);
reciprocalSNR = zeros(nRoi,1);
% snrEst = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    reciprocalSNR(rr) = roi.simuInfo.reciprocalSNR;
    if interpolationFlagForExpVarFlag
        varExplained(rr) = mean(roi.repSegInfo.varExplainedByMeanInterp);
    else
        varExplained(rr) = mean(roi.repSegInfo.varExplainedByMeanNonInterp);
    end
%     snrEst(rr) = roi.repSegInfo.varInfo.sigToNoise;
end


rFirst = zeros(nRoi,1);
rSecond = zeros(nRoi,1);
rLN_Rec = zeros(nRoi,1);
rLN_Poly2 = zeros(nRoi,1);
rFirstPlusSecond = zeros(nRoi,1);
% varExplainedInterp = zeros(nRoi,1);
pInterp = zeros(nRoi,1);
for rr = 1:1:nRoi
    roi = roiData{rr};
    rFirst(rr) = roi.LM.firstOrder.r.overall;
    rSecond(rr) = roi.LM.secondOrder.r.overall;
    rLN_Rec(rr) = roi.LM.nonLinearity.r_SoftRectification.overall;
    rLN_Poly2(rr) = roi.LM.nonLinearity.r_Poly.overall;
    rFirstPlusSecond (rr) = roi.LM.firstPlusSecond.r.overall;
    % record the mean value...
    %     varExplainedInterp(rr)  = mean(roi.repSegInfo.varExplainedByMeanInterp);
    pInterp(rr) = roi.repSegInfo.pInterp;
end

MakeFigure;
subplot(221)
scatter(reciprocalSNR,rFirst,'filled');
hold on
scatter(reciprocalSNR,rSecond,'filled');
scatter(reciprocalSNR,rFirstPlusSecond,'filled'); % I see, I forget the Rsquare there! That is the resaion...
scatter(reciprocalSNR,rLN_Rec,'filled');
scatter(reciprocalSNR,rLN_Poly2,'filled');
% scatter(reciprocalSNR,rLN_Rec.^2,'filled');
scatter(reciprocalSNR,varExplained,'filled');
corrTheoreticalLine = 1./(sqrt(1 + reciprocalSNR.^2) .* sqrt(1 + reciprocalSNR.^2/(3.8673))); % this should be theoretical line...? is that true...
scatter(reciprocalSNR,corrTheoreticalLine,'filled');
set(gca,'xscale','log');
% set(gca,'yscale','log');
xlabel('NSR : std(noise)/std(signal)');
ylabel('corr(predRespByModel,resp) or corr(mean resp,resp)');
LProperty = legend('1o','2o','1o+2o','LN-Rec','LN-Poly2','Variance Explained By Mean in Repeated Seg','1/(sqrt(1 + nsr^2)*(1 + nsr^2/3.8673))');
LProperty.Location = 'northeast';
% plot the point where our data is on.
title(titleStr);

subplot(222); % plot the ratio at different situations. scatter plot?
scatter(reciprocalSNR,rFirst./varExplained,'filled');
hold on
scatter(reciprocalSNR,rSecond./varExplained,'filled');
scatter(reciprocalSNR,rFirstPlusSecond./varExplained,'filled');
scatter(reciprocalSNR,rLN_Rec./varExplained,'filled');
scatter(reciprocalSNR,rLN_Poly2./varExplained,'filled');

% scatter(reciprocalSNR,rLN_Rec.^2,'filled');
% scatter(reciprocalSNR,varExplainedInterp,'filled');
set(gca,'xscale','log');
% set(gca,'yscale','log');
xlabel('NSR : std(noise)/std(signal)');
ylabel('ratio : corr(predRespByModel,resp)/corr(mean resp,resp)');

LProperty = legend('1o','2o','1o+2o','LN-Rec','LN-Poly2');
LProperty.Location = 'southwest';
% plot the point where our data is on.
title(titleStr);

subplot(223)
scatter(reciprocalSNR,rFirst,'filled');
hold on
scatter(reciprocalSNR,rSecond,'filled');
scatter(reciprocalSNR,rFirstPlusSecond,'filled'); % I see, I forget the Rsquare there! That is the resaion...
scatter(reciprocalSNR,rLN_Rec,'filled');
scatter(reciprocalSNR,rLN_Poly2,'filled');
scatter(reciprocalSNR,varExplained,'filled');
scatter(reciprocalSNR,corrTheoreticalLine,'filled');

set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('NSR : std(noise)/std(signal)');
ylabel('corr(predRespByModel,resp) or corr(mean resp,resp)');
LProperty = legend('1o','2o','1o+2o','LN-Rec','LN-Poly2','Variance Explained By Mean in Repeated Seg','1/(sqrt(1 + nsr^2)*(1 + nsr^2/3.8673))');
LProperty.Location = 'southwest';
% plot the point where our data is on.
title(titleStr);

subplot(224); % plot the ratio at different situations. scatter plot?
scatter(reciprocalSNR,rFirst./varExplained,'filled');
hold on
scatter(reciprocalSNR,rSecond./varExplained,'filled');
scatter(reciprocalSNR,rFirstPlusSecond./varExplained,'filled');
scatter(reciprocalSNR,rLN_Rec./varExplained,'filled');
scatter(reciprocalSNR,rLN_Poly2./varExplained,'filled');
set(gca,'xscale','log');
set(gca,'yscale','log');
xlabel('NSR : std(noise)/std(signal)');
ylabel('ratio : corr(predRespByModel,resp)/corr(mean resp,resp)');

LProperty = legend('1o','2o','1o+2o','LN-Rec','LN-Poly2');
LProperty.Location = 'southwest';
% plot the point where our data is on.
title(titleStr);


% subplot(223);
% scatter(reciprocalSNR,snrEst,'filled');
% set(gca,'xscale','log');
% % set(gca,'yscale','log');
% xlabel('NSR : std(noise)/std(signal), true simulation data');
% ylabel('SNR : std(signal)/std(noise),estimated by repeated segments');
%
% % also test, whether the p could survive.
% subplot(224);
% scatter(reciprocalSNR,pInterp,'filled');
% set(gca,'xscale','log'); set(gca,'yscale','log');
% xlabel('NSR : std(noise)/std(signal), true simulation data');
% ylabel('p value : correlation in repeated segments VS non repeated');
% title would be differet.

%% choose some bad example to plot.
% [~,minSNR]= max(reciprocalSNR);
% roiShow = roiData{2};
% PlotOneRoi_OLS_LN_And_Scond(roiShow);

if saveFigFlag
    MySaveFig_Juyue(gcf,MainName,titleStr,'nFigSave',nFigSave,'fileType',figFileType);
end

end