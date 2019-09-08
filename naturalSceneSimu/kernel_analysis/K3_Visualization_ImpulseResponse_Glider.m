function K3_Visualization_ImpulseResponse_Glider(K3, dtxx_bank, dtxy_bank)
K3_Visualization = K3_Visualization_ImpulseResponse(K3, 'tMax', 10,'dtxx_bank', dtxx_bank, 'dtxy_bank',dtxy_bank, 'plot_flag', false);
K3_glider = flipud(squeeze(sum(K3_Visualization, 1))');
dtxx_bank_str = fliplr(dtxx_bank);
quickViewOneKernel(K3_glider, 1, 'labelFlag', false);
xlabel('\tau3 - \tau1'); set(gca,'XTick', 1:size(K3_glider, 2), 'XTickLabel', strsplit(num2str(dtxy_bank)))
ylabel('\tau2 - \tau1'); set(gca,'YTick',1:size(K3_glider, 1), 'YTickLabel', strsplit(num2str(dtxx_bank_str)));
ConfAxis
end