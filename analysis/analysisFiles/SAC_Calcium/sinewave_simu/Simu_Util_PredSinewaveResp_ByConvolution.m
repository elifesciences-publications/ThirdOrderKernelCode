function resp = Simu_Util_PredSinewaveResp_ByConvolution(K2, f_vals_bank, k_vals_bank, dir_bank)
f_vals = repmat(f_vals_bank, [1, n_k, 2]);
k_vals = repmat(k_vals_bank, [n_f, 1, 2]);
dir_vals = repmat(reshape(dir_bank, [1, 1, 2]), [n_f,n_k,1]);

n_epoch = n_f * n_k * 2;
resp = cell(n_epoch, 1);
for ee = 1:1:n_epoch
    
    %% set up stimulus. sinewave.
    k_x = k_vals(ee);
    k_t = f_vals(ee);
    dir = dir_vals(ee);
    stim_cont = Simu_Util_Generate_Stim_Sinewave(k_x, k_t, dir, x_resolu, t_resolu, t_total, x_total);
    %% get the response
    resp{ee}= Simu_Util_Generate_Resp_Sinewave(stim_cont, K2);
end

end