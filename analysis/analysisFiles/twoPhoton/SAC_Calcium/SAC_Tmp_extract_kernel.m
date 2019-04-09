function [meankernel, kernel_autoregressive, pred_resp, resp, laguerre_expansion] = SAC_Tmp_extract_kernel(cell_name, order, LN_flag, fpass, arma_flag, save_kernels)
%% hyper parameters
maxTau = 10;
nbars = 15;

%% action parameters
% bleed_through_flag  = 1;
expand_in_laguerre_flag = 0;
% arma_flag = 1;
% LN_flag = false;

%%
[resp, resptime_perroi, stimtime, stimseq] = SAC_ReadImageData_Utils_GetRespStimStimind(cell_name, 0.1);
ratio_fstim_fresp = 1/(mean(diff(resptime_perroi(:,1)))/mean(diff(stimtime(:, 1))));

%% extract kernels for each roi for each trial.
n_roi = size(resp, 2);
n_data = size(resp, 3);

kernel = cell(n_data, 1);
kernel_autoregressive = cell(n_data, 1);
for tt = 1:1:n_data
    %% collect
    nT = size(resptime_perroi, 1);
    t_stim = stimtime(:,tt);
    stim_indexes = zeros(nT, n_roi);
    for rr = 1:1:n_roi
        [stim_indexes(:,rr), ~] = SAC_calcium_alignment_respstim(resptime_perroi(:,rr), t_stim);
    end
    
    %% kernel extraction
    resp_tt = mat2cell(resp(2:end,:,tt), nT - 1, ones(n_roi, 1));
    stimind = mat2cell(stim_indexes(2:end,:), nT - 1, ones(n_roi, 1));
    
    if ratio_fstim_fresp > 1 && arma_flag
        [ks, kr] = kernel_extraction_ARMA_OLS(resp_tt,stimseq(:,:,tt),stimind,'order', 1, 'maxTau',maxTau,'kernel_by_bar_flag', false, 'nMultiBars', nbars,'ratio_fstim_fresp', ratio_fstim_fresp); % 32 might be too large.
        kernel_autoregressive{tt} = squeeze(cat(3, kr{:}));
        
        if order == 2
            resp_tt_use = cell(length(resp_tt),1);
            for rr = 1:1:length(resp_tt)
                resp_tt_use{rr} = resp_tt{rr} - kr{rr} * [0;resp_tt{rr}(1:end - 1)];
            end
            
            %% use kr in the first order kernel.
            out = SAC_Tmp_ExtractKernel_OLS_Second(resp_tt_use,stimseq(:,:,tt), stimind, maxTau, nbars, ratio_fstim_fresp, 0, 0, kr);
            kernel{tt} = cat(3, out{:});
        else
            kernel{tt} = cat(3, ks{:});
        end
        
    elseif ratio_fstim_fresp > 1 && ~arma_flag
        if order == 1
            [ks, kr] = kernel_extraction_ARMA_OLS(resp_tt,stimseq(:,:,tt),stimind,'order', 1, 'maxTau', maxTau ,'kernel_by_bar_flag', false, 'nMultiBars', nbars,'ratio_fstim_fresp', ratio_fstim_fresp, 'arma_flag', 0); % 32 might be too large.
            kernel{tt} = cat(3, ks{:});
        elseif order == 2
            
            out = SAC_Tmp_ExtractKernel_OLS_Second(resp_tt,stimseq(:,:,tt), stimind, maxTau, nbars, ratio_fstim_fresp, arma_flag, 0, []);
            kernel{tt} = cat(3, out{:});
        end
        
    elseif ratio_fstim_fresp <= 1 && arma_flag
        %% reverse correlation.
        [ks, kr] = kernel_extraction_ARMA_OLS(resp_tt,stimseq(:,:,tt),stimind,'order', 1, 'maxTau',maxTau,'kernel_by_bar_flag', false, 'nMultiBars', nbars,'ratio_fstim_fresp', ratio_fstim_fresp); % 32 might be too large.
        kernel_autoregressive{tt} = cat(3, kr{:});
        if order == 2
            out = Main_KernelExtraction_ReverseCorr(resp_tt, stimseq(:, :, tt), stimind, 'order', order, 'donoise', 0, 'maxTau', maxTau, 'kr', kr);
            kernel{tt} = out{1};
        else
            kernel{tt} = cat(3, ks{:});
        end
        
    elseif ratio_fstim_fresp <= 1 && ~arma_flag
        %% reverse correlation.
        out = Main_KernelExtraction_ReverseCorr(resp_tt, stimseq(:, :, tt), stimind, 'order', order, 'donoise', 0, 'maxTau', maxTau);
        kernel{tt} = out{1};
    end
    %     if arma_flag
    %
    %         %         [ks, kr] = kernel_extraction_ARMA_OLS(resp_tt,stimseq(:,:,tt),stimind,'order', 1, 'maxTau',maxTau,'kernel_by_bar_flag', false, 'nMultiBars', nbars,'ratio_fstim_fresp', ratio_fstim_fresp); % 32 might be too large.
    %         %         kernel_autoregressive{tt} = cat(3, kr{:});
    %         %
    %         %
    %         %         if order == 2
    %         %             out = Main_KernelExtraction_ReverseCorr(resp_tt, stimseq(:, :, tt), stimind, 'order', order, 'donoise', 0, 'maxTau', maxTau, 'kr', kr);
    %         %             kernel{tt} = out{1};
    %         %         else
    %         %             kernel{tt} = cat(3, ks{:});
    %         %         end
    %     else
    %         %
    %         if ratio_fstim_fresp > 1
    %             if order == 1
    %                 [ks, kr] = kernel_extraction_ARMA_OLS(resp_tt,stimseq(:,:,tt),stimind,'order', 1, 'maxTau', maxTau ,'kernel_by_bar_flag', false, 'nMultiBars', nbars,'ratio_fstim_fresp', ratio_fstim_fresp, 'arma_flag', 0); % 32 might be too large.
    %                 kernel{tt} = cat(3, ks{:});
    %             elseif order == 2
    %                 out = SAC_Tmp_ExtractKernel_OLS_Second(resp_tt,stimseq(:,:,tt), stimind, maxTau, nbars, ratio_fstim_fresp);
    %                 %                 [ks, kr] = kernel_extraction_ARMA_OLS(resp_tt,stimseq(:,:,tt),stimind,'order', 1, 'maxTau', maxTau ,'kernel_by_bar_flag', false, 'nMultiBars', nbars,'ratio_fstim_fresp', ratio_fstim_fresp, 'arma_flag', 0); % 32 might be too large.
    %
    %                 %                 covMat = STC_Utils_SecondKernelToCovMat(kernels_full,varargin)
    %                 kernel{tt} = cat(3, out{:});
    %             end
    %         else
    %             out = Main_KernelExtraction_ReverseCorr(resp_tt, stimseq(:, :, tt), stimind, 'order', order, 'donoise', 0, 'maxTau', maxTau);
    %             kernel{tt} = out{1};
    %         end
    %     end
    
end
meankernel = mean(cat(4, kernel{:}), 4); % over different trials.

pred_resp = zeros(nT, n_roi, n_data);
if LN_flag
    averaged_across_rois = mean(meankernel, 3);
    for tt = 1:1:n_data
        %% collect temporal info.
        nT = size(resptime_perroi, 1);
        t_stim = stimtime(:,tt);
        stim_indexes = zeros(nT, n_roi);
        
        for rr = 1:1:n_roi
            [stim_indexes(:,rr), ~] = SAC_calcium_alignment_respstim(resptime_perroi(:,rr), t_stim);
            %% predict response.
            pred_resp(2:end, rr, tt) = SAC_Tmp_LN_Calcu(averaged_across_rois, stimseq(:,:,tt), stim_indexes(2:end,rr));
        end
    end
end

laguerre_expansion = [];
if expand_in_laguerre_flag
    laguerre_expansion = zeros(size(meankernel));
    for rr = 1:1:n_roi
        laguerre_expansion(:,:,rr) = SAC_Tmp_extract_kernel_expand_with_laguerre(meankernel(:,:,rr), order, n, alpha);
    end
end

if save_kernels
    % fpass, arma,
    respfolder = fullfile('D:\data_sac_calcium\', cell_name);
    kernelfile = fullfile(respfolder, [cell_name, '_kernel', '_o', num2str(order), '_arma', num2str(arma_flag), '_n','0', '.mat']);
    save(kernelfile, 'meankernel', 'kernel_autoregressive')
    
end
end
