function [K3_Impulse, dtxy_bank_new,dtxx_bank_new] = K3_SVD_Utils_GetK3_Impulse( K3, dtxy_bank, dtxx_bank,mode,tMax, maxTau)
switch mode
    case 'combine'
        
        K3_Impulse = zeros(tMax, length(dtxy_bank),length(dtxx_bank));
        for ii = 1:1:length(dtxx_bank)
            for jj = 1:1:length(dtxy_bank)
                dtxx = dtxx_bank(ii);
                dtxy = dtxy_bank(jj);
                [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);
                K3_Impulse(1:sum(~isnan(ind)),jj, ii) = K3(wind(:) == 1);
            end
        end
    case 'conv'
        dtxy_conv_bank_right = dtxy_bank(dtxy_bank > 0);
        K3_impulse_conv_right = zeros(tMax,length(dtxy_conv_bank_right), length(dtxx_bank));
        
        for ii = 1:1:length(dtxx_bank)
            for jj = 1:1:length(dtxy_conv_bank_right)
                dtxx = dtxx_bank(ii);
                dtxy = dtxy_conv_bank_right(jj);
                [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);
                K3_impulse_conv_right(1:sum(~isnan(ind)),jj, ii) = K3(wind(:) == 1); % most recent bars.
            end
        end
        K3_impulse_conv_left = - K3_impulse_conv_right(:,end:-1:1,:);
        K3_Impulse = cat(2, K3_impulse_conv_left, K3_impulse_conv_right);
        dtxy_bank_new = [dtxy_conv_bank_right(end:-1:1),dtxy_conv_bank_right];
        dtxx_bank_new = dtxx_bank;
    case 'div'
        dtxy_bank_div_left = dtxy_bank(dtxy_bank < 0);
        K3_impulse_div_left = zeros(tMax,length(dtxy_bank_div_left), length(dtxx_bank));
        dtxx_bank = dtxx_bank(end:-1:1);
        for ii = 1:1:length(dtxx_bank)
            for jj = 1:1:length(dtxy_bank_div_left)
                dtxx = dtxx_bank(ii);
                dtxy = dtxy_bank_div_left(jj);
                [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);
                K3_impulse_div_left(1:sum(~isnan(ind)),jj, ii) = K3(wind(:) == 1);
            end
        end
        
        K3_impulse_div_right = - K3_impulse_div_left(:,end:-1:1,:);
        K3_Impulse = cat(2, K3_impulse_div_left,K3_impulse_div_right);
        %         dtxy_div_bank = [dtxy_bank_div_left, -dtxy_bank_div_left(end:-1:1)];
        dtxy_bank_new = [-dtxy_bank_div_left, -dtxy_bank_div_left(end:-1:1)];
        dtxx_bank_new = dtxx_bank;
end
end
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
end