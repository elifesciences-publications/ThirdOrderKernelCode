function pred_resp = Simu_Util_Generate_Resp_Sinewave(stim, K2)
[n_x_stim, n_t_stim] = size(stim);

n_x_k2 = size(K2, 1);
n_t_k2 = size(K2, 3);

if (n_x_k2 ~= n_x_stim)
    error('not the same spatial length');
end

pred_resp = zeros(n_t_stim, 1); %%
for t = n_t_k2 + 1:1:n_t_stim
    for x1 = 1:1:n_x_k2
        for x2 = 1:1:n_x_k2
            stim_1 = stim(x1, t:-1: t - n_t_k2 + 1);
            stim_2 = stim(x2, t:-1: t - n_t_k2 + 1);
            pred_resp_this = stim_1 * squeeze(K2(x1, x2, :, :)) * stim_2';
            pred_resp(t) = pred_resp(t) + pred_resp_this;
        end
    end
end
end