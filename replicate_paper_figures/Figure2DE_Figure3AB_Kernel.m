function Figure2DE_Figure3AB_Kernel()
% CodeFormation, Plot Kernels.
clear
clc
mode = 'ai_publish';
S = GetSystemConfiguration;

%% Load Kernel.
maxTau = 64;

% load kernel
kernel = load(fullfile(S.natural_scene_simulation_path, '\parameterdata\ori_reverse_correlation.mat'));
% symmetrize individual k2...

k2_individual = kernel.kernel.k2_ind;
k2_sym_individual = k2_individual;
k2_sym_mean  = kernel.kernel.k2_sym; % nblock is normalized.


k3_sym_individual = (kernel.kernel.k3_xxy_ind - kernel.kernel.k3_yyx_ind)/2;
nfly = size(k3_sym_individual,2);
k3_sym_individual = reshape(k3_sym_individual, [maxTau, maxTau, maxTau, nfly]);
k3_sym_mean = kernel.kernel.k3_sym;

% shuffled kernel
kernel_noise = load(fullfile(S.natural_scene_simulation_path, '\parameterdata\ori_reverse_correlation_noise.mat'));
k3_sym_noise = kernel_noise.kernel.k3_sym;
k2_sym_noise = kernel_noise.kernel.k2_sym;
% get the correct scale
dt = 1/60;
% second order kernel
k3_sym_individual = k3_sym_individual/(dt^3);
k3_sym_mean = k3_sym_mean/(dt^3);
k3_sym_noise = k3_sym_noise/(dt^3);
% third order kernel
k2_sym_mean = k2_sym_mean/(dt^2);
k2_sym_noise = k2_sym_noise/(dt^2);
k2_sym_individual = k2_sym_individual/(dt^2);
%% plot second order kernel. impulse response, and glider... get old code
switch mode
    case 'ai_publish'
        fondsize_tau = 4;
        fondsize_label = 6;
        
        horiztonal_position_kernel_bank = [1/2, 3, 4+3/4, 6 + 1/2] + 1/2;
%         horiztonal_position_impulse = [1/2, 3, 4+3/4 + 0.15/2, 6 + 1/2]+ 1/2;
        horiztonal_position_impulse = [1/2, 3, 4+3/4, 6 + 1/2]+ 1/2;

        horizontal_width_kernel_bank = [1.5, 1.75];
%         horiztonal_width_impulse = 1.5 * [1.1, 1.0, 0.9, 1.0];
        horiztonal_width_impulse = 1.5 * [1,1,1,1];

        vertical_position_bank = [7, 4, 1];
        vertical_height_impulse = [1+1/2, 2, 1];
        
        h = repmat(struct('Position',[],'Units', 'inches'), 3,4);
        h(1,1).Position = [horiztonal_position_kernel_bank(1),  vertical_position_bank(1),  horizontal_width_kernel_bank(1),vertical_height_impulse(1)];
        h(1,2).Position = [horiztonal_position_kernel_bank(2), vertical_position_bank(1), horizontal_width_kernel_bank(1), vertical_height_impulse(1)];
        h(1,3).Position = [horiztonal_position_kernel_bank(3), vertical_position_bank(1), horizontal_width_kernel_bank(2), vertical_height_impulse(1)];
        h(1,4).Position = [horiztonal_position_kernel_bank(4), vertical_position_bank(1), horizontal_width_kernel_bank(1), vertical_height_impulse(1)];

        
        for ii = 2:1:3
            for jj = 1:1:4
                h(ii, jj).Position = [horiztonal_position_impulse(jj), vertical_position_bank(ii), horiztonal_width_impulse(jj), vertical_height_impulse(ii)];
            end
        end
        
    case 'matlab_debug'
        fontsize_tau = 10;
        fontsize_label = 10;
        n_subplot_v = 3;
        n_subplot_h = 4;
        h = repmat(struct('Position',[],'Units', 'normalized'), 3,4);
        for ii = 1:1:n_subplot_v
            for jj = 1:1:n_subplot_h
                a = subplot(n_subplot_v, n_subplot_h, (ii - 1) * n_subplot_h + jj);
                h(ii,jj).Position = a.Position;
            end
        end
        
%         fileType = {'png'};
%         nFigSave = 1;
end
%%
%% second order kernel.
MakeFigure;
axes('Units', h(1, 1).Units,'Position', h(1, 1).Position);
maxTauShow_Kernel = 61;
k2_sym_mean_show = k2_sym_mean(1:maxTauShow_Kernel,1:maxTauShow_Kernel);
quickViewOneKernel(k2_sym_mean_show(:), 2, 'limPreSetFlag',false,'colorbarFlag',false);
set(gca, 'XAxisLocation','top');
xlabel('\tau2, right bar [s]');
ylabel('\tau1, left bar [s]');
High_Corr_PaperFig_Utils_SmallFontSize(); 
% add a color bar outside 0.25 to the right.
colorbar_position = [h(1, 1).Position(1)+ h(1, 1).Position(3) + 0.2, h(1, 1).Position(2), 0.2, h(1, 1).Position(4)];
h_colorbar = colorbar(gca, 'Units',h(1, 1).Units, 'Position', colorbar_position);
h_colorbar.Label.String = sprintf('filter strength \n ^o/c^2/s^3');


%% third order kernel
dtxx_bank = 1;
dtxy_bank = [0,1];
% re do the color bar.
K3_BehaviorKernel_Visualization_ThreeD(k3_sym_mean, dtxx_bank, dtxy_bank,'maxTauShow',maxTauShow_Kernel,'h', h(1,3));
%% plot the impulse response.
n_dt_xy_plot_range = 5;

% second order impulse response.
dtxy_bank = -n_dt_xy_plot_range:n_dt_xy_plot_range;
K2_Visualization_ImpulseResponse_Glider_V2(k2_sym_mean, k2_sym_individual, k2_sym_noise, 'tMax', 48,'dtxy_bank',dtxy_bank,'h',h(2:end, 1));

% third order impulse response
dtxx_bank = 1:3;
dtxy_bank = -8:8;
K3_Visualization_ImpulseResponse_Glider_V2(k3_sym_mean,k3_sym_individual,k3_sym_noise, ...
    'tMax', 46,'dtxx_bank', dtxx_bank, 'dtxy_bank',dtxy_bank, 'n_dt_xy_plot_range',n_dt_xy_plot_range,...
    'plot_flag', true,'h',h(2:end, 2:end));

end

% third order impulse response.
% dtxx_bank = 1:2;
% dtxy_bank = -4:4;
% K3_visualization_impulse = K3_Visualization_ImpulseResponse_Glider(k3_sym_mean,k3_sym_individual,k3_sym_noise, 'tMax', 46,'dtxx_bank', dtxx_bank, 'dtxy_bank',dtxy_bank, 'plot_flag', true);
% MySaveFig_Juyue(gcf,'Behavior_K3_Visualiztion_impulse','v0','nFigSave',2,'fileType',{'eps','svg'});
