function stimseq = SAC_Load_StimSeq(stimtime_file)
% stimseq_file = 'D:\data_sac_calcium\param_info\stimseq_15_5_shared.mat';
% data = load(stimseq_file);
% stimseq = data.stimseq;
    data = load(stimtime_file);
    
    nbar = data.stim(1,1);
    framesPerChange = data.stim(1, 5);
    stimseed = data.stim(:, 6);
    stimdur = data.stim(1,7);
    nframe = round(stimdur/framesPerChange);
    ntrial = size(data.stim, 1);
    stimseq = zeros(nframe, nbar, ntrial);
    for tt = 1:1:ntrial
        rng(stimseed(tt));
        for ff = 1:1:nframe
            stimseq(ff, :, tt) = round(rand(nbar, 1));
        end
    end
end