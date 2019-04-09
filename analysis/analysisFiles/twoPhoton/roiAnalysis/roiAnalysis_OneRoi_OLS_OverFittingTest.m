% how are you going to do this?
function [bestKernel,rTrainingSelected,rTestingSelected,maxTau_DtMax_Range] = roiAnalysis_OneRoi_OLS_OverFittingTest(roi,maxTauRange,dtMaxRange,barNumRange,varargin)
order = 1;
dx = 1; % could be the next nearest bar/
plotFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% load data data set.
S = GetSystemConfiguration;
kernelPath = S.kernelSavePath;
flickpath = [kernelPath,roi.stimInfo.flickPath];

roiNum = roi.stimInfo.roiNum;
switch order
    case 1
        k = roi.filterInfo.firstKernel.Original;
    case 2
        % depend on dx.
        switch dx
            case 1
                k = roi.filterInfo.secondKernel.dx1.Original;
            case 2
                k = roi.filterInfo.secondKernel.dx2.Original;
        end
end
[respData,stimData,stimIndexes,repCVFlag,repStimuIndInFrame] = GetStimResp_ReverseCorr(flickpath, roiNum);
% [respData,stimData,stimIndexes] = GetStimResp_OLS(flickpath, roiNum); %
% compute the thing...
nMultiBars = size(k,2);
switch order
    case 1
        maxTau = size(k,1);
    case 2
        maxTau = round(sqrt(size(k,1)));
end
[nonRepData,repData] = roiAnalysis_OneRoi_OLS_PrepareStimResp_NonRepAndRep(respData,stimData,stimIndexes,repStimuIndInFrame,order,dx,maxTau,nMultiBars);

% OLS calculate kernel again.
% first oder.
switch order
    case 1
        kernelFull = zeros(maxTau,nMultiBars);
        for qq = 1:1:nMultiBars
            SS = nonRepData.stim{qq};
            RR = nonRepData.resp ;
            kernelFull(:,qq) = SS\RR;
        end
    case 2
%         kernelFull = zeros(maxTau^2,nMultiBars);
        % it seems that the result from the reverse correlation is very
        % different from that of OLS. especially for the second order
        % kernel. why is that?
        
        % var(SS())
        %         for qq = 1:1:nMultiBars
        %             SS = nonRepData.stim{qq};
        %             RR = nonRepData.resp ;
        %             tic
        %             kernelFull(:,qq) = SS\RR; % extremely large. take some time? 1 minute? take a timer here and ask Omer for help. % for one second order kernel, it takes half minutes.
        %             toc
        %
        % %             use the full kernel to predict response, should be able to
        % %             overfit the data.
        %         end
        kernelFull = k;
end

barCenter = roiAnalysis_FindFirstKernelCenter(roi,'methodFilterCenter','prob');
% you are going to just reextract kernels, but would not calculate from
% begining. therefore, for the second order kernels, you have to calculate
% the kernelFull here.
[bestKernel,rTrainingSelected,rTestingSelected,maxTau_DtMax_Range] = roiAnalysis_OneRoi_OLS_OverFittingTest_ModelSelection_1o2o(nonRepData,repData, maxTauRange,barNumRange,barCenter,kernelFull,order,dtMaxRange,'plotFlag',plotFlag);
% give out the rTesting, so that you can get a average.
% used for showing

% useful in the future.
% fit LN model here, for fit he
if plotFlag
    [respNonRepFull,predRespNonRepFull,respRepFull,predRespRepFull,~,predRespByTrialUpSampleFull] = roiAnalysis_OneRoi_OLS_PredResp_RepAndNonRep(nonRepData,repData,kernelFull);
    kernelTrunc = bestKernel;
    [respNonRepTrunc,predRespNonRepTrunc,respRepTrunc,predRespRepTrunc,respRepByTrialUpSample,predRespByTrialUpSampleTrunc] = roiAnalysis_OneRoi_OLS_PredResp_RepAndNonRep(nonRepData,repData,kernelTrunc);


    MakeFigure;
    
    subplot(3,5,1)
    quickViewOneKernel_Smooth(kernelFull,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
    title('full kernel');
    subplot(3,5,6);
    PlotLNModel(predRespNonRepFull,respNonRepFull)
    subplot(3,5,11)
    PlotLNModel(predRespRepFull,respRepFull)
    
    
    subplot(3,5,2)
    quickViewOneKernel_Smooth(kernelTrunc,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
    title('trancated kernel');
    subplot(3,5,7);
    PlotLNModel(predRespNonRepTrunc,respNonRepTrunc)
    subplot(3,5,12)
    PlotLNModel(predRespRepTrunc,respRepTrunc);
    
    subplot(3,5,3:5)
    sem = std(respRepByTrialUpSample,1,2)/sqrt(size(respRepByTrialUpSample,2));
    PlotXY_Juyue((1:size(respRepByTrialUpSample,1))', mean(respRepByTrialUpSample,2),'errorBarFlag',true,'sem',sem);
    title('response in repeated segments');
    xlabel('time [60Hz frames]')
    
    subplot(3,5,8:10)
    sem = std(predRespByTrialUpSampleFull,1,2)/sqrt(size(predRespByTrialUpSampleFull,2));
    PlotXY_Juyue((1:size(predRespByTrialUpSampleFull,1))', mean(predRespByTrialUpSampleFull,2),'errorBarFlag',false,'sem',sem);
    title('FULL Model : predicted response in repeated segments');
    xlabel('time [60Hz frames]')
    
    subplot(3,5,13:15)
    sem = std(predRespByTrialUpSampleTrunc,1,2)/sqrt(size(predRespByTrialUpSampleTrunc,2));
    PlotXY_Juyue((1:size(predRespByTrialUpSampleTrunc,1))', mean(predRespByTrialUpSampleTrunc,2),'errorBarFlag',false,'sem',sem);
    title('trancated Model : predicted response in repeated segments');
    xlabel('time [60Hz frames]')
end
end