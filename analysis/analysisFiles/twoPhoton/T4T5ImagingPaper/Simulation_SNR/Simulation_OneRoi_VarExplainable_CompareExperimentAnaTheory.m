function Simulation_OneRoi_VarExplainable_CompareExperimentAnaTheory(roi,varargin)
plotFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[respFull,respRepByTrial,respRepByTrialTimeLag,respRepByTrialShort,respRepByTrialTimeLagShort,respNoiselessRepByTrialShort,respNoiselessRepByTrialTimeLagShort,respRepNoiselessUpSample] = roiAnalysis_OneRoi_getResponseRepSeg(roi);
nSeg = size(respFull,2);

%%  build the test trial and training trial
testTrialInd = eye(nSeg) == 1;
shiftTestTrialInd = testTrialInd;
numTrialHoldOut = 1;
for ii = 2:1:numTrialHoldOut
    shiftTestTrialInd = [shiftTestTrialInd(2:end,:);shiftTestTrialInd(1,:)];
    testTrialInd = testTrialInd | shiftTestTrialInd;
end
trainTrialInd = ~ testTrialInd;
%%
% it works for one trial. pretty good. change a way to do it for multiple
% trial.
% generate a respFull which is more interesting...
respFullNaN = nan(size(respRepByTrialTimeLag));
for ss = 1:1:nSeg
    respFullNaN(respRepByTrialTimeLagShort(:,ss),ss) = respRepByTrialShort{ss};
end

varInfo_SingleVSNoiseless = cell(nSeg,1);
varInfo_MeanTrainVSNoiseless = cell(nSeg,1);
varInfo_SingleVSMeanTrain  = cell(nSeg,1);
nTrialTrain = zeros(nSeg,1);
for ss = 1:1:nSeg
    %% singleTestingTrial vs real signal.
    varInfo_SingleVSNoiseless{ss} = roiAnalysis_OneRoi_VarRepSeg_ComputeVar(respRepByTrialShort{ss},respNoiselessRepByTrialShort{ss});
    
    %% meanTrainingTrial vs real signal.
    meanResp = nanmean(respFullNaN(:,trainTrialInd(ss,:)),2); % what if there is nan in one time point. that would still be nan, do not worry...
    meanRespNoiseless = respRepNoiselessUpSample;
    meanRespNoiseless (isnan(meanResp)) = [];meanResp(isnan(meanResp)) = [];
    varInfo_MeanTrainVSNoiseless{ss} = roiAnalysis_OneRoi_VarRepSeg_ComputeVar(meanResp,meanRespNoiseless);
    
    %% singleTestingTrial vs meanTrainingTrial
    meanResp = nanmean(respFullNaN(:,trainTrialInd(ss,:)),2);
    nTrialTrainThis = sum(respRepByTrialTimeLagShort(:,trainTrialInd(ss,:)),2);
    respSingleTrial = respRepByTrialShort{testTrialInd(:,ss)};
    meanRespSingleTrial = meanResp(respRepByTrialTimeLagShort(:,testTrialInd(:,ss)));
    respSingleTrial(isnan(meanRespSingleTrial)) = []; nTrialTrainThis(isnan(meanRespSingleTrial)) = [];meanRespSingleTrial(isnan(meanRespSingleTrial)) = [];
    nTrialTrain(ss) = mean(nTrialTrainThis);
    varInfo_SingleVSMeanTrain{ss} = roiAnalysis_OneRoi_VarRepSeg_ComputeVar(respSingleTrial,meanRespSingleTrial);
    % kill all the nan.
end
nSegSumSignal = mean(nTrialTrain); % only 19 trials...

% calculate several theoretical value.
varExpTheo_SingleVSNoiseless = Simulation_VarExplainable_Utils_TheoreticalCal(roi.simuInfo.reciprocalSNR,1,'respRespNoiseless');
varExpExp_SingleVSNoiseless = cellfun(@(x) x.varExplainable,varInfo_SingleVSNoiseless);

% covNoiseSigal = cellfun(@(x) x.covNoiseMean,varInfo_SingleVSNoiseless);
% varResp = cellfun(@(x) x.varResp,varInfo_SingleVSNoiseless);
% varMean = cellfun(@(x) x.varMeanResp,varInfo_SingleVSNoiseless);
% varNoise = cellfun(@(x) x.varNoise,varInfo_SingleVSNoiseless);
% %%
% MakeFigure; % this should be around 0.
% subplot(221)
% histogram(covNoiseSigal); % plot the mean 
% hold on
% ax = gca; yLim = ax.YLim;
% plot([mean(covNoiseSigal),mean(covNoiseSigal)],yLim,'r');
% subplot(222); % the esitmated variance, real variance 
% histogram(varMean);hold on
% ax = gca; yLim = ax.YLim;
% plot([mean(varMean),mean(varMean)],yLim,'r');
% subplot(223);
% histogram(varResp);
% ax = gca; yLim = ax.YLim;
% hold on
% x = mean(varResp );
% plot([mean(varResp ),mean(varResp )],yLim,'b');
% ax = gca; yLim = ax.YLim;
% varRespMeanTheory = (1 + roi.simuInfo.reciprocalSNR^2 ) * mean(varMean);
% plot([varRespMeanTheory,varRespMeanTheory],yLim,'r');
% subplot(224)
% histogram(varNoise);hold on 
% plot([mean(varNoise ),mean(varNoise)],yLim,'b');
% ax = gca; yLim = ax.YLim;
% % estimation of the variance of the noise is wrong, why is that?
% varNoiseTheory = (roi.simuInfo.reciprocalSNR^2 ) * mean(varMean);
% plot([varNoiseTheory,varNoiseTheory],yLim,'r'); 
varExpTheo_MeanTrainVSNoiseless =Simulation_VarExplainable_Utils_TheoreticalCal(roi.simuInfo.reciprocalSNR,nSegSumSignal,'respRespNoiseless');
varExpExp_MeanTrainVSNoiseless = cellfun(@(x) x.varExplainable,varInfo_MeanTrainVSNoiseless);

varExpTheo_SingleVSMeanTrain = Simulation_VarExplainable_Utils_TheoreticalCal(roi.simuInfo.reciprocalSNR,nSegSumSignal,'respResp');
varExpExp_SingleVSMeanTrain = cellfun(@(x) x.varExplainable,varInfo_SingleVSMeanTrain);

%% varaince explained by mean. cross validation, on the repeated segments.
varExplainedByMeanInterp = zeros(nSeg,1);
varExplainedByMeanInterpTrain = zeros(nSeg,1);
for ss = 1:1:nSeg
    [varExplainedByMeanInterp(ss),varExplainedByMeanInterpTrain(ss)] = roiAnalysis_OneRoi_VarRepSeg_OneCV(respFull,respRepByTrialShort,respRepByTrialTimeLagShort,trainTrialInd(:,ss),testTrialInd(:,ss));
end

varExplainedByMeanNonInterp = zeros(nSeg,1);
varExplainedByMeanNonInterpTrain = zeros(nSeg,1);
for ss = 1:1:nSeg
    [varExplainedByMeanNonInterp(ss),varExplainedByMeanNonInterpTrain(ss)] = roiAnalysis_OneRoi_VarRepSeg_OneCV_NonInterp(respRepByTrialShort,respRepByTrialTimeLagShort,trainTrialInd(:,ss),testTrialInd(:,ss));
end


if plotFlag
    %%
    MakeFigure;
    subplot(221)
    h = histogram(varExpExp_SingleVSNoiseless);
    ax = gca;yLim = ax.YLim;hold on
    plot([varExpTheo_SingleVSNoiseless,varExpTheo_SingleVSNoiseless],yLim,'r'); % the noise is much higher? why is that?
    plot([mean(varExpExp_SingleVSNoiseless),mean(varExpExp_SingleVSNoiseless)],yLim,'b');
    legend('','theory','exp');
    title('Single Trial with noiseless signal');
    
    subplot(222)
    h = histogram(varExpExp_MeanTrainVSNoiseless);
    ax = gca;yLim = ax.YLim;hold on
    plot([varExpTheo_MeanTrainVSNoiseless,varExpTheo_MeanTrainVSNoiseless],yLim,'r'); % the noise is much higher? why is that?
    plot([mean(varExpExp_MeanTrainVSNoiseless),mean(varExpExp_MeanTrainVSNoiseless)],yLim,'b');
    legend('','theory','exp');
    title('Mean of Trianing Trials with noiseless signal');
    
    subplot(223)
    h = histogram(varExpExp_SingleVSMeanTrain);
    ax = gca;yLim = ax.YLim;hold on
    plot([varExpTheo_SingleVSMeanTrain,varExpTheo_SingleVSMeanTrain],yLim,'r'); % the noise is much higher? why is that?
    plot([mean(varExpExp_SingleVSMeanTrain),mean(varExpExp_SingleVSMeanTrain)],yLim,'b');
    legend('','theory','exp');
    title('Mean of Trianing Trials with Single Test Trial');
    
    
    subplot(224) % the non interpolation works. compare the interpolated and non interpolated one.
    clear h
    h{1} = histogram(varExplainedByMeanInterp);
    hold on
    h{2} = histogram(varExplainedByMeanNonInterp);
    Histogram_Untils_SetBinWidthLimitsTheSame(h,'normByProbabilityFlag',true);
    ax = gca;
    yLim = ax.YLim;
    hold on
    legend('interp','nonInterp');
    plot([mean(varExplainedByMeanInterp),mean(varExplainedByMeanInterp)],yLim,'b'); % the noise is much higher? why is that?
    plot([mean(varExplainedByMeanNonInterp),mean(varExplainedByMeanNonInterp)],yLim,'r');
    title('estimation with mean with Interpolation or NanMean(Non Interpolation)');
end