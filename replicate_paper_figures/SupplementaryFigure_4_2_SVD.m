function SupplementaryFigure_4_2_SVD()
clear
clc

%% load kernel.
kernel_extraction_method = 'reverse_correlation';
process_stim_flag = false;
process_stim_FWHM = [];
kernel = Load_Kernel_For_NS(process_stim_flag , process_stim_FWHM, kernel_extraction_method, 'full_kernel_flag', 1);
k2_sym = kernel.k2_sym;
k3_sym = kernel.k3_sym;


%% get the second-order, color plot, with color bar.
dtxy_bank  = [-5:-1,1:5];
tMax = 49;
flattenK2 = My_SVD_K2_Flattened(k2_sym(:),'dtxy_bank',  [dtxy_bank(dtxy_bank < 0), dtxy_bank(dtxy_bank > 0)],...
    'tMax',tMax );
%% get the third-order, color plot, with color bar.
n_sum = 10;
[flattenK3,flattenK_high_res] = My_SVD_K3_Form_SumDiff(k3_sym, n_sum);
dtxy_bank_3 = [-5:0.5:-0.5, 0.5:0.5:5];

%% do SVD, normalize, plot them on the same axis..
[K2_U, K2_S, K2_V] = svd(flattenK2);
[K3_U, K3_S, K3_V] = svd(flattenK3);
[K2_norm, K3_norm] = normalize_component(K2_U, K2_V, K3_U, K3_V);
plot_component_together_both_SVD(K2_norm, K3_norm,K2_S, K3_S, dtxy_bank, dtxy_bank, tMax);


%% plotting the impulse response.
dt = 1/60;
flattenK2_with_unit = flattenK2/dt.^2;
flattenK3_with_unit = flattenK3/dt.^3;
flattenK_high_res_with_unit = flattenK_high_res/dt.^3;
MakeFigure_Paper; 
axes('Units', 'Points', 'Position', [100,550,120,120]);
quickViewOneKernel(flattenK2_with_unit,1, 'labelFlag',false, 'set_clim_flag', true, ' clim', max(abs(flattenK2_with_unit(:))), 'colorbarFlag', false);
set(gca, 'YTick', [1,17,33,49], 'YTickLabel',{'0', '0.25', '0.5', '0.75'});
set(gca, 'XTick', [1:n_sum], 'XTickLabel',{});
ConfAxis('fontSize', 9, 'LineWidth', 0.5);
title('The second-order kernel(Supplementary Figure 4-2 D)')
box on

axes('Units', 'Points', 'Position', [100,400,120,120]);
quickViewOneKernel(flattenK_high_res_with_unit,1, 'labelFlag',false, 'set_clim_flag', true, ' clim', max(abs(flattenK_high_res_with_unit(:))), 'colorbarFlag', false);
set(gca, 'YTick', [1,17,33,49], 'YTickLabel',{'0', '0.25', '0.5', '0.75'});
set(gca, 'XTick', [1:n_sum], 'XTickLabel',{});
ConfAxis('fontSize', 9, 'LineWidth', 0.5);
title('The third-order kernel (Supplementary Figure 4-2 B)')

box on

axes('Units', 'Points', 'Position', [100,250,120,120]);
quickViewOneKernel(flattenK3_with_unit,1, 'labelFlag',false, 'set_clim_flag', true, ' clim', max(abs(flattenK3_with_unit(:))), 'colorbarFlag', false);
set(gca, 'YTick', [1,17,33,49], 'YTickLabel',{'0', '0.25', '0.5', '0.75'});
set(gca, 'XTick', [1:n_sum], 'XTickLabel',{});
ConfAxis('fontSize', 9, 'LineWidth', 0.5);
title('The third-order kernel (Supplementary Figure 4-2 C)')
box on



%% same thing, plotted for color bar.
axes('Units', 'Points', 'Position', [100,100,120,120]);
quickViewOneKernel(flattenK2_with_unit,1,'labelFlag',false, 'set_clim_flag', true, ' clim', max(abs(flattenK2_with_unit(:))), 'colorbarFlag', false);
set(gca, 'YTick', [1,17,33,49], 'YTickLabel',{'0', '0.25', '0.5', '0.75'});
cbh = colorbar();
set(cbh, 'YTick', [-50,0,50])

axes('Units', 'Points', 'Position', [250,100,120,120]);
quickViewOneKernel(flattenK_high_res_with_unit,1,'labelFlag',false, 'set_clim_flag', true, ' clim', max(abs(flattenK_high_res_with_unit(:))), 'colorbarFlag', false);
set(gca, 'YTick', [1,17,33,49], 'YTickLabel',{'0', '0.25', '0.5', '0.75'});
set(gca, 'XTick', [1:2:9, 12:2:2*n_sum], 'XTickLabel',{});
cbh = colorbar();
set(cbh, 'YTick', [-500,0,500]);

axes('Units', 'Points', 'Position', [400,100,120,120]);
quickViewOneKernel(flattenK3_with_unit,1, 'labelFlag',false, 'set_clim_flag', true, ' clim', max(abs(flattenK3_with_unit(:))), 'colorbarFlag', false);
set(gca, 'YTick', [1,17,33,49], 'YTickLabel',{'0', '0.25', '0.5', '0.75'});
set(gca, 'XTick', [1:n_sum], 'XTickLabel',{});
cbh = colorbar();
box on
set(cbh, 'YTick', [-500,0,500]);

% MySaveFig_Juyue(gcf,'Kernel_FlattenForSVD','V2', 'nFigSave',2,'fileType',{'png','pdf'});
end