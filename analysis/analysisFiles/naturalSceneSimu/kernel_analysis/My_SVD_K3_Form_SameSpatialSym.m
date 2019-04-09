function My_SVD_K3_Form_SameSpatialSym(K3)
save_fig_flag = 1;
maxTau = 64;
tMax = 48;
n_sum = 10;
tau_21 = [-7:7]; % 
tau_31 = [-7:7];

ylabel_str = '\Delta\tau_{21}';
xlabel_str = '\Delta\tau_{23}';
y_vals = tau_21;
x_vals = tau_31;

n_21 = length(tau_21);
n_31 = length(tau_31);
K3_Impulse = zeros(tMax, n_21, n_31);
for ii = 1:1:n_21
    for jj = 1:1:n_31
        dtxx = tau_21(ii) - tau_31(jj);
        dtxy = -tau_21(jj);
        [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);        
        K3_Impulse(1:sum(~isnan(ind)),ii,jj) = K3(wind(:) == 1); % most recent bars.    
    end
end


%% do SVD on the third-order format.
[U, fitting_errors] = My_SVD_K3_3D_Appro(K3_Impulse);
My_SVD_K3_3D_plotting(K3_Impulse,U, fitting_errors, xlabel_str, ylabel_str, x_vals, y_vals)
if save_fig_flag
    MySaveFig_Juyue(gcf,'K3_SVD_SameSpatialSym','3D_Decom','nFigSave',2,'fileType',{'png','fig'})
end
%% do SVD on the second-order format
My_SVD_K3_2D_Appro(K3_Impulse, 1, x_vals, y_vals, xlabel_str, ylabel_str, save_fig_flag, 'SameSpatialSym');
% 
% % do the replo
% T = K3_Impulse_tight(:, n_sum+2:1:end, :) - K3_Impulse_tight(:, n_sum:-1:1, :);

