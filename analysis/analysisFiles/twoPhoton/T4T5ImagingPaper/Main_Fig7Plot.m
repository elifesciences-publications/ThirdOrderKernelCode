% Main_Fig7Plot;

% get the kernel, and plot the thing again... annoying, but you have to do
% it. because you did not finish it very well..

clear
clc

roiMethodType = 'ICA_NNMF';
stimulusType = '5B';
roiData5B = getData_Juyue('5B',roiMethodType);
% roiData5T = getData_Juyue('5T',roiMethodType);
% roiData = [roiData5T;roiData5B];
roiData = roiData5B;
roiDataUse = roiSelection_AllRoi(roiData,'method','kernelType');% this seems like a reasonable idea... also record the
roiDataUseEdge = roiSelection_AllRoi(roiDataUse,'method','prob');% this seems like a reasonable idea... also record the
roiDataUseEdge = roiAnalysis_ChangeFilterDirection(roiDataUseEdge,'method','corChangeAndCentered');

flyLargeMovement = {'I:\2pData\2p_microscope_data\2015_08_11\+;UASGC6f_+;T4T5_+ - 1\multiBarFlicker_20_60hz_-64.6down005'};
roiDataUseEdge = roiSelection_AllRoi(roiDataUseEdge ,'method','fly','targetedfilepath',flyLargeMovement);

% kernelToUseis 3....
% get the mean kernel... first order kernel.
% first,
%%
kernelTypeUse = [1,3];
normRoiFlag = true;
% too little flies.
[meanKernel,norm] = roiAnalysis_AverageFunction_OverFly_IndividualBars(roiDataUseEdge,'whichValue','firstKernel','kernelTypeUse',kernelTypeUse,...
    'normRoiFlag',normRoiFlag);

% you also have to flip the Progressive to regressive?
meanKernelOneDir = cell(4,1);
for tt = 1:1:4
    % too trouble some...
    % where is your code?
    if tt == 2 || tt == 4
        nRoi = size(meanKernel{tt},3);
        for rr = 1:1:nRoi
            
            meanKernelOneDir{tt} = cat(3,meanKernelOneDir{tt},fliplrKernel(meanKernel{tt}(:,:,rr),1));
        end
    else
        meanKernelOneDir{tt} = meanKernel{tt};
    end
end

% first cell element is T4 cell
% second cell element is T5 cell
meanKernelT4T5 = {cat(3,meanKernelOneDir{1},meanKernelOneDir{2});cat(3,meanKernelOneDir{3},meanKernelOneDir{4})};

% calculate the meanKernel
meanKernelEachType = zeros(60,20,2);
for ii = 1:1:2
    meanKernelEachType(:,:,ii) = mean(meanKernelT4T5{ii},3);
end

% do simulation...
% do the simuluation first.
dt = [-15:1:15]; % it is unit of dt, time is dt*1/60 seconds.

dtUn = [-300,-200,-100,100,200,300];
dtSimu = [dtUn,dt];
indDt = length(dtUn) + 1:length(dtSimu);
indUncor = 1:length(dtUn);

nTrial = 10;
dtSweepResp = zeros(length(dt),2,2,nTrial); % phi and reverse phi. as well as
dtSweepUnCorr = zeros(2,nTrial);

% do this for several trials... and get a mean value.... should be the
% same...
for nn = 1:1:nTrial
    for ii = 1:1:2
        tic
        [respMeanNonLinear,respNonLinear,respLinear,stimMat] = ScintiPreFirst(meanKernelEachType(:,:,ii),1,0,0,0,'rectification',20,dtSimu,[1,-1]); % phi
        toc
        dtSweepResp(:,:,ii,nn) = respMeanNonLinear(indDt,:);
        dtSweepUnCorr(ii,nn) = mean(mean(respMeanNonLinear(indUncor,:)));
    end
end
save('dtSweepData_Binary','dtSweepResp','dtSweepUnCorr','meanKernelEachType');
saveFigFlag = true;
% plot the mean filter and the dtSweep
MakeFigure;
subplotNumKernel= [1,2];
subplotNumDt= [3,4];
for ii = 1:1:2
    subplot(2,2,subplotNumKernel(ii));
    quickViewOneKernel_Smooth(meanKernelEachType(:,:,ii),1);
    subplot(2,2,subplotNumDt(ii));
    meanResp = squeeze(mean(dtSweepResp(:,:,ii,:),4));
    meanUnCorrResp = mean(dtSweepUnCorr(ii,:));
    PlotDtSweepResponse_EmilioFormat(meanResp,dt,meanUnCorrResp,'left','',true)
    
end
if saveFigFlag
    MySaveFig_Juyue(gcf,'Binary_LN_CorrelatedNoise', '' ,'nFigSave',3,'fileType',{'eps','fig','png'});
end

MakeFigure;
subplotNumKernel= [1,2];
subplotNumDt= [3,4];

for ii = 1:1:2
    subplot(2,2,subplotNumKernel(ii));
    quickViewOneKernel_Smooth(meanKernelEachType(:,:,ii),1);
    subplot(2,2,subplotNumDt(ii));
    for nn = 1:1:nTrial
        hold on
        PlotDtSweepResponse_EmilioFormat(dtSweepResp(:,:,ii,nn),dt,dtSweepUnCorr(ii,nn),'left','',true)
    end
end
if saveFigFlag
    MySaveFig_Juyue(gcf,'Binary_LN_CorrelatedNoise_10Trial', '' ,'nFigSave',3,'fileType',{'eps','fig','png'});
end

%% also plot the prograssive minus the regressive result.
load('C:\Users\Clark Lab\Documents\Holly_log\01_10_2016\dtSweepData_Binary.mat'); % might not be necessary in the future.

for ii = 1:1:2
    meanResp = squeeze(mean(dtSweepResp(:,:,ii,:),4));
    meanUnCorrResp = mean(dtSweepUnCorr(ii,:));
    PlotDtSweepResponse_EmilioFormat(meanResp,dt,meanUnCorrResp,'left','',true)
    
end

MakeFigure;
subplotNumKernel= [1,2];
subplotNumDt= [3,4];
subplotPDMinusND = [5,6];
for ii = 1:1:2
    subplot(3,2,subplotNumKernel(ii));
    quickViewOneKernel_Smooth(meanKernelEachType(:,:,ii),1);
    subplot(3,2,subplotNumDt(ii));
    
    meanResp = squeeze(mean(dtSweepResp(:,:,ii,:),4));
    meanUnCorrResp = mean(dtSweepUnCorr(ii,:));
    PlotDtSweepResponse_EmilioFormat(meanResp,dt,meanUnCorrResp,'left','',true)

    subplot(3,2,subplotPDMinusND(ii));
    PlotDtSweepResponse_PDMinusND_EmilioFormat(meanResp,dt,meanUnCorrResp,'left','',true)
end
if saveFigFlag
    MySaveFig_Juyue(gcf,'Binary_LN_CorrelatedNoise_PD-ND', '' ,'nFigSave',3,'fileType',{'eps','fig','png'});
end
% you get