function roi =  roiAnalysis_OneRoi_VarRepSeg(roi,varargin)
plotFlag = false;
numTrialHoldOut = 1;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% there would be several computing method.
% think of a totally different way of compuating these....
[respFull,respRepByTrial,respRepByTrialTimeLag,respRepByTrialShort,respRepByTrialTimeLagShort] = roiAnalysis_OneRoi_getResponseRepSeg(roi);
nSeg = size(respFull,2);

%%  build the test trial and training trial
testTrialInd = eye(nSeg) == 1;
shiftTestTrialInd = testTrialInd;
for ii = 2:1:numTrialHoldOut
    shiftTestTrialInd = [shiftTestTrialInd(2:end,:);shiftTestTrialInd(1,:)];
    testTrialInd = testTrialInd | shiftTestTrialInd;
end
trainTrialInd = ~testTrialInd;

%% varaince explained by mean. cross validation, on the repeated segments.
varExplainedByMeanInterp = zeros(nSeg,1);
varExplainedByMeanInterpTrain = zeros(nSeg,1);
for ss = 1:1:nSeg
    [varExplainedByMeanInterp(ss),varExplainedByMeanInterpTrain(ss)] = roiAnalysis_OneRoi_VarRepSeg_OneCV(respFull,respRepByTrialShort,respRepByTrialTimeLagShort,trainTrialInd(:,ss),testTrialInd(:,ss));
end
varExplainedByMeanNonInterp = zeros(nSeg,1);
varExplainedByMeanNonInterpTrain = zeros(nSeg,1);
for ss = 1:1:nSeg
    [varExplainedByMeanNonInterp(ss),varExplainedByMeanNonInterpTrain(ss)] = roiAnalysis_OneRoi_VarRepSeg_OneCV_NonInterp(respRepByTrial,respRepByTrialTimeLag,trainTrialInd(:,ss),testTrialInd(:,ss));
end

%%
% for control signal.
[respFullControl,respRepByTrialControl,respRepByTrialTimeLagControl,respRepByTrialShortControl,respRepByTrialTimeLagShortControl] = roiAnalysis_OneRoi_getResponseRepSeg(roi,'controlRespFlag',true);
% varaince explained by mean, on the nonrepeated segments.
varExplainedByMeanInterpControl = zeros(nSeg,1);
varExplainedByMeanInterpTrainControl = zeros(nSeg,1);
for ss = 1:1:nSeg
    [varExplainedByMeanInterpControl(ss),varExplainedByMeanInterpTrainControl(ss)] = roiAnalysis_OneRoi_VarRepSeg_OneCV(respFullControl,respRepByTrialShortControl,respRepByTrialTimeLagShortControl,trainTrialInd(:,ss),testTrialInd(:,ss));
end

varExplainedByMeanNonInterpControl = zeros(nSeg,1);
varExplainedByMeanNonInterpTrainControl = zeros(nSeg,1);
for ss = 1:1:nSeg
    [varExplainedByMeanNonInterpControl(ss),varExplainedByMeanNonInterpTrainControl(ss)] = roiAnalysis_OneRoi_VarRepSeg_OneCV_NonInterp(respRepByTrialControl,respRepByTrialTimeLagControl,trainTrialInd(:,ss),testTrialInd(:,ss));
end

if sum(isnan(varExplainedByMeanInterp)) > 0 | sum(isnan(varExplainedByMeanNonInterp)) > 0
    warning('response data has a huge amount of zeros');
    pInterp = 10;
    pNonInterp = 10;
else
    % you should use r.^2, cause sometimes, p will be high even if the
    % correlation between mean and response is significant smaller than
    % zeros. how could you do one direction ranksum?
    pInterp =  ranksum(varExplainedByMeanInterp,varExplainedByMeanInterpControl);
    pNonInterp = ranksum(varExplainedByMeanNonInterp,varExplainedByMeanNonInterpControl);
end

%% compute the signal to noise.
% varInfo = roiAnalysis_OneRoi_VarRepSeg_OrganizeAndComputeVar(respFull,respRepByTrialShort,respRepByTrialTimeLagShort,'interpolationFlag',interpolationFlagForSNR);
% pInterp = 0;
ana.varExplainedByMeanInterp = varExplainedByMeanInterp;
ana.varExplainedByMeanNonInterp = varExplainedByMeanNonInterp;
ana.pInterp = pInterp;
ana.pNonInterp = pNonInterp;
roi.repSegInfo = ana;

if plotFlag
    MakeFigure;
    subplot(221);
    h{1} = histogram(varExplainedByMeanInterp);
    hold on
    h{2} = histogram(varExplainedByMeanInterpTrain);
    title('interpolation');
    legend(['test meanVar ', num2str(mean(varExplainedByMeanInterp))],['train meanVar ', num2str(mean(varExplainedByMeanInterpTrain))])
    
    subplot(222);
    h{3} = histogram(varExplainedByMeanNonInterp);
    hold on
    h{4} = histogram(varExplainedByMeanNonInterpTrain);
    title('no interpolation');
    legend(['test meanVar ', num2str(mean(varExplainedByMeanNonInterp))],['train meanVar ', num2str(mean(varExplainedByMeanNonInterpTrain))])
    
    binWidth = min(cellfun(@(x)x.BinWidth,h,'UniformOutput',true));
    a = min(cellfun(@(x)x.BinLimits(1),h,'UniformOutput',true));
    b = max(cellfun(@(x)x.BinLimits(2),h,'UniformOutput',true));
    for ii = 1:1:4
        h{ii}.BinLimits = [a,b];
        h{ii}.BinWidth = binWidth;
    end
    
    stimHz = 60;timePlot = (1:size(respFull,1))'/stimHz;
    legendStr = cell(9,1); % 5 for the first line. + 5
    sem = std(respFull,1,2)/sqrt(size(respFull,2));
    subplot(212)
    PlotXY_Juyue(timePlot, mean(respFull,2),'errorBarFlag',true,'sem',sem,'colorMean',[1,0,0]);
    hold on
    % with interpolation.
    
    % how about without interpolation?
    respFullNonInterp = nan(size(respRepByTrialTimeLag));
    nSeg = size(respFullNonInterp,2);
    for ss = 1:1:nSeg
        respFullNonInterp(respRepByTrialTimeLag(:,ss),ss) = respRepByTrial{ss};
    end
    meanRespTrain = nanmean(respFullNonInterp,2); % what if there is nan in one time point. that would still be nan, do not worry...
    sem = nanstd(respFullNonInterp,1,2)/sqrt(size(respFullNonInterp,2));
    PlotXY_Juyue(timePlot,meanRespTrain ,'errorBarFlag',true,'sem',sem,'colorMean',[0,0,1]);
    hold on
    legend('interpolated','','','','','non interpolated')
end

if plotFlag
    
    
    MakeFigure;
    subplot(321);
    h{1} = histogram(varExplainedByMeanInterpControl);
    hold on
    h{2} = histogram(varExplainedByMeanInterp);
    title(['interpolation, p : ', num2str(pInterp)]); % also give out the p value.
    legend(['control meanVar ', num2str(mean(varExplainedByMeanInterpControl))],['test meanVar ', num2str(mean(varExplainedByMeanInterp))])
    
    subplot(322);
    h{3} = histogram(varExplainedByMeanNonInterpControl);
    hold on
    h{4} = histogram(varExplainedByMeanNonInterp);
    title(['no interpolation, p : ', num2str(pNonInterp)]);
    legend(['control meanVar ', num2str(mean(varExplainedByMeanNonInterpControl))],['test meanVar ', num2str(mean(varExplainedByMeanNonInterp))])
    
    binWidth = min(cellfun(@(x)x.BinWidth,h,'UniformOutput',true));
    a = min(cellfun(@(x)x.BinLimits(1),h,'UniformOutput',true));
    b = max(cellfun(@(x)x.BinLimits(2),h,'UniformOutput',true));
    for ii = 1:1:4
        h{ii}.BinLimits = [a,b];
        h{ii}.BinWidth = binWidth;
    end
    
    stimHz = 60;timePlot = (1:size(respFull,1))'/stimHz;
    sem = std(respFull,1,2)/sqrt(size(respFull,2));
    subplot(312)
    PlotXY_Juyue(timePlot, mean(respFull,2),'errorBarFlag',true,'sem',sem,'colorMean',[1,0,0]);
    hold on
    % with interpolation.
    
    % how about without interpolation?
    respFullNonInterp = nan(size(respRepByTrialTimeLag));
    nSeg = size(respFullNonInterp,2);
    for ss = 1:1:nSeg
        respFullNonInterp(respRepByTrialTimeLag(:,ss),ss) = respRepByTrial{ss};
    end
    meanRespTrain = nanmean(respFullNonInterp,2); % what if there is nan in one time point. that would still be nan, do not worry...
    sem = nanstd(respFullNonInterp,1,2)/sqrt(size(respFullNonInterp,2));
    PlotXY_Juyue(timePlot,meanRespTrain ,'errorBarFlag',true,'sem',sem,'colorMean',[0,0,1]);
    hold on
    legend('interpolated','','','','','non interpolated');
    title('response at repeated segments');
    
    subplot(313)
    stimHz = 60;timePlot = (1:size(respFullControl,1))'/stimHz;
    sem = std(respFullControl,1,2)/sqrt(size(respFullControl,2));
    
    PlotXY_Juyue(timePlot, mean(respFullControl,2),'errorBarFlag',true,'sem',sem,'colorMean',[1,0,0]);
    hold on
    % with interpolation.
    
    % how about without interpolation?
    respFullNonInterp = nan(size(respRepByTrialTimeLagControl));
    nSeg = size(respFullNonInterp,2);
    for ss = 1:1:nSeg
        respFullNonInterp(respRepByTrialTimeLagControl(:,ss),ss) = respRepByTrialControl{ss};
    end
    meanRespTrain = nanmean(respFullNonInterp,2); % what if there is nan in one time point. that would still be nan, do not worry...
    sem = nanstd(respFullNonInterp,1,2)/sqrt(size(respFullNonInterp,2));
    PlotXY_Juyue(timePlot,meanRespTrain ,'errorBarFlag',true,'sem',sem,'colorMean',[0,0,1]);
    hold on
    legend('interpolated','','','','','non interpolated');
    title('response after repeated segments');
end


% plot the time traces
% you have the respFull
%%
% trainTrialInd = true(size(respRepByTrial));
% testTrialInd = true(size(respRepByTrial));
% varExplainedByMean = roiAnalysis_OneRoi_VarRepSeg_OneCV_NanMean(respRepByTrial,respRepByTrialTimeLag,trainTrialInd,testTrialInd);


% do not care about this. use the new method.
% respFull = respFull(6:end-4,:);
% meanResp = mean(respFull,2);
% residual = bsxfun(@minus,respFull,meanResp);
% % varTimeTrace = var(residual,0,2);
% % varNoise = mean(varTimeTrace);
% varNoise = var(residual(:),1);
% varMeanResp = var(meanResp,1);
% varResp = var(respFull(:),1);
% sigToNoise = sqrt(varMeanResp/varNoise);
% varExplainableOri = varMeanResp/varResp;
%
% ana.varResp = varResp;
% ana.varMeanResp = varMeanResp;
% ana.varNoise = varNoise;
% ana.sigToNoise = sigToNoise;
% ana.varExplainable = varExplainable;
%
% roi.SNInfo = ana;
% how about Damon's advice? How are you going to do this?
% MakeFigure;
% nSeg = size(respFull,2);
% meanRespMat = repmat(meanResp,[1,nSeg]);
% scatter(meanRespMat(:),respFull(:));
% corr(meanRespMat(:),respFull(:))^2
% signal to noise. explainable variance.

% do you want to do this for all rois? yes.
end
