
% this function can be used to plot individual rois. or a bunch of them..
function Analyze_Function_Individual_Fly_PlotSinalToNoise_Draft(filepath, kernel_identifier,varargin)
roiSelected = [];
Main_Name = [];
saveFigFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if sum(ismember('simulation',filepath)) == 0
    fileID_name = ['flyID', num2str(My_GetFlyBehaviorIdFromDatabase(filepath))];
else
    fileparts = strsplit(filepath, '\');
    fileID_name = fileparts{end};
end
flickSave = Analysis_Function_Loading_Draft(filepath, kernel_identifier, 'which_data', 'flick');
respData= flickSave.respData;
stimData = flickSave.stimData;
stimIndexes = flickSave.stimIndexed;
repStimuIndInFrame = flickSave.repStimIndInFrame;
%
nMultiBars = size(stimData,2);
repSegFlag = true;

maxTau = 2;
order = 1;
OLSMat = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,repStimuIndInFrame,repSegFlag,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
respRepByTrial = OLSMat.respByTrial;
respRepByTrialTimeLag = OLSMat.relativeTimePointsEachTrial; % is there are problem with your alignment code?

roiUse = find(roiSelected);
for rr = 1:1:length(roiUse)
    roi_this = roiUse(rr);
    [powerSignalEst_this,powerNoiseEst_this,~, respFull_this_nan] = roiAnalysis_OneRoi_RepSegAnalysis_Power_Utils_SigPower(respRepByTrial{roi_this },respRepByTrialTimeLag{roi_this},'nonInterp');
    
    [respFull_this,~] =  MultibarFlicker_alignResponseInRepSeg(respRepByTrial{roi_this},respRepByTrialTimeLag{roi_this });
    MakeFigure;
    plot(respFull_this,'color',[0.5,0.5,0.5]);
    % plot mean on top of it
    meanResp = nanmean(respFull_this_nan,2);
    hold on
    plot(meanResp,'r');
    xlabel('frames');
    ylabel('dFF');
    filepath_name = filepath; filepath_name(filepath_name == '_') = [];
    title([filepath_name ,'#', num2str(roi_this)]);
    text(800,max(respFull_this(:)),sprintf('signal power = %f \nnoise power = %f\nsnr = %f',powerSignalEst_this,powerNoiseEst_this,powerSignalEst_this/powerNoiseEst_this));
    ConfAxis;
    if saveFigFlag
        MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['snr'],'nFigSave',2,'fileType',{'png','fig'});
    end
end
end

