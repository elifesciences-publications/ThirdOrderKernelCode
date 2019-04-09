function K2_DXDT_pred = Simu_Utils_RecoverDXDT_FromResp(resp, x_resolu, t_resolu, dx_bank, dt_bank,k_vals_bank, f_vals_bank, dir_bank)
n_f = length(f_vals_bank);
n_k = length(k_vals_bank);

f_vals = repmat(f_vals_bank, [1, n_k, 2]);
k_vals = repmat(k_vals_bank, [n_f, 1, 2]);
dir_vals = repmat(reshape(dir_bank, [1, 1, 2]), [n_f,n_k,1]);

%% do the reverse from the pred_resp.
x = dx_bank * x_resolu;
t = dt_bank * t_resolu;

K2_DXDT_pred = zeros(length(x), length(t));
n_epoch = length(k_vals(:));
for ee = 1:1:n_epoch
    % set up stimulus. sinewave.
    k_x = k_vals(ee);
    k_t = f_vals(ee);
    dir = dir_vals(ee);

    stim_cont = cos(dir * 2 * pi * k_x * x + 2 * pi * k_t * t');

    % predict K2_DXDT_pred from cos.
    K2_DXDT_pred = K2_DXDT_pred + resp(ee) * stim_cont;
end

end