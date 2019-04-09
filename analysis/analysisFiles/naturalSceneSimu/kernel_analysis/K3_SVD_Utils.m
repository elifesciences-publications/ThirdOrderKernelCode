function K3_SVD_Utils(K3_Visualization, tMax,  dtxx_bank, dtxy_bank, clim, numsubplot_size, numsubplot)
% MakeFigure;
% maxValue = max(abs(K3_Visualization(:)));
for ii = 1:1:length(dtxx_bank)
    subplot(numsubplot_size(1), numsubplot_size(2), numsubplot(ii))
    quickViewOneKernel(K3_Visualization(:,:,ii), 1, 'labelFlag', false, 'set_clim_flag', true, 'clim', clim);
    %     if ii == 3
    %         xlabel('\tau3 - \tau1');
    %     end
    set(gca, 'XTick', 1: length(dtxy_bank), 'XTickLabel', strsplit(num2str(dtxy_bank)));
    %     ylabel('\tau1');
    %     yLim = get(gca, 'YLim');
    %     % plot the dt = 0 line...
    %     hold on
    %     tau3_tau1 = find(dtxy_bank == 0);
    %     plot([tau3_tau1,tau3_tau1], [0, tMax], 'k--')
    %     tau3_tau2 = find(dtxy_bank == dtxx_bank(ii));
    %     plot([tau3_tau2,tau3_tau2], [0, tMax], 'k--');
    %     tau1_tau2_middle = (dtxx_bank(ii)/2) + tau3_tau1;
    %     plot([tau1_tau2_middle,tau1_tau2_middle], [0, tMax], 'r--');
    %     ConfAxis
    title(['\tau2 - \tau1 = ', sprintf('%d',dtxx_bank(ii))]);
    % title, the middle line and the label.
end