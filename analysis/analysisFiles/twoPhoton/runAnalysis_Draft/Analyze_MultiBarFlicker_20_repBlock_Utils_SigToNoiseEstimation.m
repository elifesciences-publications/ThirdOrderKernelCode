function analysis = Analyze_MultiBarFlicker_20_repBlock_Utils_SigToNoiseEstimation(~,~,~,stimAnalysis,~,~,~,varargin)
%% arguments for file orangization
plotFlag           = false;
data_subfolder_raw = 'raw';
stash_name         = '';
RoiIdentificationMethod   = 'ICA_DFOVERF';
twoPhotonMaster_data_flag = true; % will you forget this?
stimFunction_Appliable    = 'multiBarFlicker_20_repBlock_60hz'; % might have to be changed for Catherine in the future.
%% argument for signal to noise analysis.
order           = 1;
controlRespFlag = false;


for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% one can have different roi Identification method. cool.
S          = GetSystemConfiguration;
kernelPath = S.kernelSavePath;

if twoPhotonMaster_data_flag
    RoiIdentificationMethod = TPMaster_To_RA_Trans_Utils_RoiIndentification(roiExtractionFile);
end


%% start calculate signal to noise of each fly.
% inside the function, you will do fly by fly.
nfly           = length(dataPath);
powerSignalEst = cell(nfly,1); % is this a good idea?
powerNoiseEst  = cell(nfly,1);
for ff = 1:1:nfly
    
    %%  get the repStimIndInFrame
    repFrameInds_struct    = Analyze_MultiBarFlicker_20_repBlock_Utils_FindRepSegments([],[],[],stimAnalysis(ff),[],[],[],varargin{:});
    repStimuIndInFrame     = repFrameInds_struct.repFrameInds;
    %% load the roiData structure,
    [roiData_getData_path] = runAnalysis_utils_GetRoiDataStructurePath(dataPath{ff}, data_subfolder_raw, RoiIdentificationMethod, stash_name,'return_folder_name',false, 'retrun_latest_file',true);
    load(roiData_getData_path{1});
    
    %% initialize the data.
    nRoi               = length(roiData); % roi data comes from loading the data.
    powerSignalEst{ff} = zeros(nRoi,1);
    powerNoiseEst{ff}  = zeros(nRoi,1);
    
    %% get the response and stimulus for this fly.
    flickpath = [kernelPath,roiData{1}.stimInfo.flickPath];
    load(flickpath);
    respData    = flickSave.respData;
    stimData    = flickSave.stimData;
    stimIndexes = flickSave.stimIndexed;
    
    %% get how many bars and maxTau.
    k  = roiData{1}.filterInfo.firstKernel.Original; nMultiBars = size(k,2); maxTau = size(k,1);
    
    %% check whether there is repeated segments in this stimulus function.
    filepath_this_split = strsplit(dataPath{ff},'/'); stimFunction_this =  filepath_this_split {3};
    
    if strcmp(stimFunction_this,stimFunction_Appliable) % This function should be independently of cross-validation. you should check whether this is a rep design. check the stimFunction. instead of repCVFlag.
        repSegFlag = true;
        % control: what is the signal to noise to the non repeated
        % segments.
        if controlRespFlag
            % 15 + 45 % control response: 15 seconds after the 15 seconds of repeated stimulus.
            % you tp_Compute_OLSMat_NonRepOrRep would take care of taking
            stimuIndInFrameUsed = repStimuIndInFrame + size(repStimuIndInFrame,1);
        else
            stimuIndInFrameUsed = repStimuIndInFrame;
        end
        
        %%
        OLSMat                = tp_Compute_OLSMat_NonRepOrRep(respData,stimData,stimIndexes,stimuIndInFrameUsed,repSegFlag,'order',order,'maxTau',maxTau,'nMultiBars', nMultiBars);
        respRepByTrial        = OLSMat.respByTrial;
        respRepByTrialTimeLag = OLSMat.relativeTimePointsEachTrial; % is there are problem with your alignment code?
    else
        error('this fly does not have repeated segments');
    end
    
    %% calculate the estimated power and noise.
    for rr = 1:1:nRoi
        [powerSignalEst{ff}(rr),powerNoiseEst{ff}(rr),~] = roiAnalysis_OneRoi_RepSegAnalysis_Power_Utils_SigPower(respRepByTrial{rr},respRepByTrialTimeLag{rr},'nonInterp');
    end
    % save some of them?
    if plotFlag
        % sort the signal to noise.
        [~, I] = sort(powerSignalEst{ff}./powerNoiseEst{ff},'descend');
        
        count_for_plot = 0;
        count_for_plot_figure = 0;
        for ii = 1:1:nRoi 
            rr = I(ii);
            [powerSignalEst_this,powerNoiseEst_this,~, respFull_this_nan] = roiAnalysis_OneRoi_RepSegAnalysis_Power_Utils_SigPower(respRepByTrial{rr},respRepByTrialTimeLag{rr},'nonInterp');
            
            [respFull_this,~] =  MultibarFlicker_alignResponseInRepSeg(respRepByTrial{rr},respRepByTrialTimeLag{rr});
            % how can you control this.
            if count_for_plot == 0
                MakeFigure;
                count_for_plot_figure = count_for_plot_figure + 1;
            end
            subplot(3,4,count_for_plot + 1);
            plot(respFull_this,'color',[0.5,0.5,0.5]);
            % plot mean on top of it
            meanResp = nanmean(respFull_this_nan,2);
            hold on
            plot(meanResp,'r');
            xlabel('frames');
            ylabel('dFF');
            title(['#', num2str(rr)]);
            text(800,max(respFull_this(:)),sprintf('signal power = %f \nnoise power = %f\nsnr = %f',powerSignalEst_this,powerNoiseEst_this,powerSignalEst_this/powerNoiseEst_this));
            %         ConfAxis;
            count_for_plot = count_for_plot + 1;
            count_for_plot = mod(count_for_plot,12);
            
            MySaveFig_Juyue(gcf,['signal_to_noise_',num2str(ff)],['_',roiExtractionFile,num2str(count_for_plot_figure)],'nFigSave',2,'fileType',{'png','fig'})
        end
    end
    % look at the signal to noise.
end
tic
analysis.powerSignalEst = powerSignalEst;
analysis.powerNoiseEst = powerNoiseEst;

% you can do this on roi basis. but you can also do it with batches,
% loading flick data is slow.
% for rr = 1:1:nRoi
%     roi = roiData{rr};
%     [~,respRepByTrial,respRepByTrialTimeLag,~,~] = roiAnalysis_OneRoi_getResponseRepSeg(roi,'repStimuIndInFrame',repFramesInds);
%     [powerSignalEst(rr),powerNoiseEst(rr),~] = roiAnalysis_OneRoi_RepSegAnalysis_Power_Utils_SigPower(respRepByTrial,respRepByTrialTimeLag,'nonInterp');
%     % if plot function?
% end