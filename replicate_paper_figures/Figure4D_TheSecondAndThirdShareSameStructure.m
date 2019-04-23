function Figure4D_TheSecondAndThirdShareSameStructure()

% gain kernels.
save_fig_flag = false;
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

%% averaging the data
dtxy_bank_2 = [-5:1:-1,1:1:5];
color_k2 = [114, 206, 245]/255;
color_k3 = [49, 168, 73]/255;

averaged_K2 = sum(flattenK2, 1);
averaged_K3 = sum(flattenK3, 1);

averaged_K2_norm = averaged_K2/norm(averaged_K2);
averaged_K3_norm = averaged_K3/norm(averaged_K3);
averaged_K3_norm = -averaged_K3_norm;
MakeFigure_Paper;
axes('Units', 'Points', 'Position', [100,400,160,50]);
% subplot(2,2,1);
plot(dtxy_bank_2, averaged_K2_norm, 'color', color_k2);
hold on
plot(dtxy_bank_2, averaged_K3_norm, 'color', color_k3);
plot(get(gca,'XLim'),[0,0],'k--');
plot([0,0], get(gca,'YLim'),'k--');
xlabel('\Delta\tau_{21}  [ms]');
ylabel('integrated kernel [a.u.]');
dtxy_bank_plot = [-5:1:5]';
set(gca, 'XTick',dtxy_bank_plot, 'XTickLabel',num2str(dtxy_bank_plot * 1/60* 1000,2));
legend('2^{nd} order','3^{rd} order');
% scatter(0,0,'MarkerEdgeColor',[0,0,0]);
ymax = max([max(abs(averaged_K2_norm)), max(averaged_K3_norm)]);
set(gca, 'YLim',[-ymax, ymax] * 1.2);
set(gca, 'XLim',[dtxy_bank_2(1), dtxy_bank_2(end)]);
% xtickangle(90)
ConfAxis('fontSize', 9, 'LineWidth', 0.5);
end
