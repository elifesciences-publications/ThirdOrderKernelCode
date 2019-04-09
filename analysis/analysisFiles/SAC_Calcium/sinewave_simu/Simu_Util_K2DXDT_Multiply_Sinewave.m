function pred_resp = Simu_Util_K2DXDT_Multiply_Sinewave(K2_DXDT, x_resolu, t_resolu, dx_bank, dt_bank, k_vals_bank, f_vals_bank, dir_bank)
n_f = length(f_vals_bank);
n_k = length(k_vals_bank);

f_vals = repmat(f_vals_bank, [1, n_k, 2]);
k_vals = repmat(k_vals_bank, [n_f, 1, 2]);
dir_vals = repmat(reshape(dir_bank, [1, 1, 2]), [n_f,n_k,1]);

x = dx_bank * x_resolu;
t = dt_bank * t_resolu;

%%
n_epoch = length(f_vals(:));
pred_resp = zeros(n_epoch, 1);
for ee = 1:1:n_epoch
    % set up stimulus. sinewave.
    k_x = k_vals(ee);
    k_t = f_vals(ee);
    dir = dir_vals(ee);

    stim_cont = cos(dir * 2 * pi * k_x * x + 2 * pi * k_t * t');
%     MakeFigure;
%     imagesc(stim_cont);
%     MakeFigure; 
%     imagesc(stim_cont .* K2_DXDT);
    % get the response from DXDT.
    pred_resp(ee) = sum(sum(stim_cont .* K2_DXDT, 1), 2);
end
pred_resp = pred_resp/2; 
end