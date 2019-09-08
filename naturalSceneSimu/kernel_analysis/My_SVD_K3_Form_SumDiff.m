function [K3_Impulse_Concate_IntegratedOutThird_Sym_LowRes, K3_Impulse_Concate_IntegratedOutThird_Sym] = My_SVD_K3_Form_SumDiff(K3, n_sum)
save_fig_flag = 0;

maxTau = 64;
tMax = 49;
tau_sum = [-n_sum:n_sum];
tau_diff = [1:n_sum - 1]; 

ylabel_str = '\Delta\tau_{21} + \Delta\tau_{23}';
xlabel_str = '\Delta\tau_{21} - \Delta\tau_{23}';
y_vals = tau_sum;
x_vals = tau_diff(1: floor(length(tau_diff)/2)) + 0.5;
half_y_vals = 1:n_sum;
half_x_vals = floor((n_sum - 1)/2);

%% change into tau_23 and tau 13
[mesh_sum, mesh_diff] = ndgrid(tau_sum, tau_diff);
tau_23_mesh = zeros(size(mesh_sum));
tau_13_mesh = zeros(size(mesh_diff));
for ss = 1:1:length(tau_sum)
    for dd = 1:1:length(tau_diff)
        tau_23_mesh(ss, dd) = (mesh_sum(ss, dd) - mesh_diff(ss, dd))/2;
        tau_13_mesh(ss, dd) = (mesh_sum(ss, dd) + mesh_diff(ss, dd))/2;
    end
end

%% arrange kernel into new format
K3_Impulse = zeros(tMax, length(tau_sum), length(tau_diff));
for ii = 1:1:length(tau_sum)
    for jj = 1:1:length(tau_diff)
        if floor(tau_23_mesh(ii, jj)) ==  tau_23_mesh(ii, jj) && floor(tau_13_mesh(ii, jj)) ==  tau_13_mesh(ii, jj)
            dtxx = tau_23_mesh(ii, jj) - tau_13_mesh(ii, jj);
            dtxy = -tau_13_mesh(ii, jj);
            [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);        
            K3_Impulse(1:sum(~isnan(ind)),ii, jj) = K3(wind(:) == 1); % most recent bars.  
        end
    end
end

n_diff = floor(length(tau_diff)/2);
K3_Impulse_tight = zeros(tMax, length(tau_sum), n_diff);
for ii = 1:1:length(tau_sum)
    if mod(tau_sum(ii), 2) == 0
        ind = 2:2:length(tau_diff);
    else
        ind = 1:2:length(tau_diff) - 1;
    end
    K3_Impulse_tight(:, ii, :) = K3_Impulse(:,ii, ind);
end

%% concatenate the converging and the diverging. Integrate out the DIFF dimension.
K3_Impulse_Concate = cat(3, K3_Impulse_tight(:, n_sum+2:end, :), -K3_Impulse_tight(:, n_sum:-1:1, :));
K3_Impulse_Concate_IntegratedOutThird = squeeze(sum(K3_Impulse_Concate, 3));
K3_Impulse_Concate_IntegratedOutThird_Sym = [-fliplr(K3_Impulse_Concate_IntegratedOutThird), K3_Impulse_Concate_IntegratedOutThird];

%% Also average over two nearby columns.
tmp = reshape(K3_Impulse_Concate_IntegratedOutThird_Sym, [tMax, 2, n_sum]);
K3_Impulse_Concate_IntegratedOutThird_Sym_LowRes = squeeze(mean(tmp, 2));
K3_Impulse_Concate_IntegratedOutThird_Sym_LowRes = -K3_Impulse_Concate_IntegratedOutThird_Sym_LowRes; % get the consistent direction as the diagram.
%% SVD on the third dimension.
% My_SVD_K3_2D_Appro(K3_Impulse_Concate_IntegratedOutThird, 1, half_y_vals, 1:tMax, ylabel_str, 'time since the most recent', save_fig_flag, 'SUMDIFF_Concate');


%% how about averaging all and have the SVD?
% What visualization do you need, plan out...
% My_SVD_K3_Form_SumDiff_Concate_demo(K3_Impulse_Concate, n_sum, n_diff)
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'K3_SVD_SUMDIFF_Concate','Demo','nFigSave',2,'fileType',{'png','fig'})
% end
% 
% [U, fitting_errors] = My_SVD_K3_3D_Appro(K3_Impulse_Concate, 1);
% My_SVD_K3_3D_plotting(K3_Impulse_Concate,U, fitting_errors, '', ylabel_str, [1:2*n_diff], half_y_vals, 1);
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'K3_SVD_SUMDIFF_Concate','Demo_Aprx1','nFigSave',2,'fileType',{'png','fig'})
% end
%     
% [U, fitting_errors] = My_SVD_K3_3D_Appro(K3_Impulse_Concate, 2);
% My_SVD_K3_3D_plotting(K3_Impulse_Concate,U, fitting_errors, '', ylabel_str, [1:2*n_diff], half_y_vals, 2);
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'K3_SVD_SUMDIFF_Concate','Demo_Aprx2','nFigSave',2,'fileType',{'png','fig'})
% end

% %% plotting, deomenstration.
% My_SVD_K3_Form_SumDiff_demo(K3_Impulse, K3_Impulse_tight, tau_sum, tau_diff);
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'K3_SVD_SUMDIFF','Demo','nFigSave',2,'fileType',{'png','fig'})
% end
% 
% %% do SVD on the third-order format.
% [U, fitting_errors] = My_SVD_K3_3D_Appro(K3_Impulse_tight);
% My_SVD_K3_3D_plotting(K3_Impulse_tight,U, fitting_errors, xlabel_str, ylabel_str, x_vals, y_vals)
% if save_fig_flag
%     MySaveFig_Juyue(gcf,'K3_SVD_SUMDIFF','3D_Decom','nFigSave',2,'fileType',{'png','fig'})
% end
% 
% %% do SVD on the second-order format
% My_SVD_K3_2D_Appro(K3_Impulse_tight, 1, x_vals, y_vals, xlabel_str, ylabel_str, save_fig_flag, 'SUMDIFF');

