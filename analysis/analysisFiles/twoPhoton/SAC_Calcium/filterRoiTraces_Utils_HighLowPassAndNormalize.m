function [resp_norm, f0] = filterRoiTraces_Utils_HighLowPassAndNormalize(resp, fpass,fs)
%    df = highpass(resp(2:end,:),fpass,fs,'ImpulseResponse','iir');
%    f0 = lowpass(resp(2:end,:), fpass, fs,'ImpulseResponse','iir');
%    resp_norm = df./f0;
    %% actually, you should connect them together...
    % connect different trials together. get rid of the first zero in the
    % recording.
    resp_f_tmp = resp(2:end, :, :);
    nt = size(resp_f_tmp, 1);
    nroi = size(resp_f_tmp, 2);
    ntrial = size(resp_f_tmp,3);
    
    resp_f_cell = mat2cell(resp_f_tmp, nt, nroi, ones(ntrial, 1));
    resp_f_concatenate = cat(1, resp_f_cell{:});
    
    % highpass, lowpass.
    f0_tmp = lowpass(resp_f_concatenate, fpass, fs,'ImpulseResponse','iir');
    df_tmp = highpass(resp_f_concatenate, fpass, fs,'ImpulseResponse','iir');

    % reorganize into trials, padd the first zeros back, and calculate df/f.
    f0_tmp_cell = mat2cell(f0_tmp, ones(ntrial,1) * nt, nroi);
    f0 = [zeros(1, nroi,ntrial);cat(3, f0_tmp_cell{:})];
    
    df_tmp_cell = mat2cell(df_tmp, ones(ntrial,1) * nt, nroi);
    df = [zeros(1, nroi,ntrial);cat(3, df_tmp_cell{:})];
    
    resp_norm = zeros(size(resp));
    resp_norm(2:end, :, :) = df(2:end,:,:)./f0(2:end,:,end);
    
    %% plot resp, and f0 on top of it.
%     MakeFigure;
%     subplot(2,1,1)
%     SAC_utils_plot_several_trials((2:1000)/fs, squeeze(mean(resp(2:end,:,:), 2)), [0,0,1]);
%     hold on
%     SAC_utils_plot_several_trials((2:1000)/fs, squeeze(mean(f0(2:end,:,:), 2)), [1,0,0]);
%     legend({'F','F0'});
%     
%     subplot(2,1,2)
%     SAC_utils_plot_several_trials((1:1000)/fs, squeeze(mean(df, 2)), [1,0,0]);
%     legend({'F','F0'});
    
end