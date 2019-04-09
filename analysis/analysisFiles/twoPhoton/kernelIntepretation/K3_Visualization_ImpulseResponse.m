function [K3_visualization_impulse,K3_visualization_glider] = K3_Visualization_ImpulseResponse(K3, varargin)
dtxx_bank = 1:1:4;
dtxy_bank = -16:1:16;
tMax = 64;
tMaxShow = 61;
maxTau = 64;
plot_flag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% change the plot to the most recent tau.
K3_visualization_impulse = zeros(tMax, length(dtxy_bank),length(dtxx_bank));
K3_visualization_glider = zeros(length(dtxy_bank),length(dtxx_bank));
for ii = 1:1:length(dtxx_bank)
    for jj = 1:1:length(dtxy_bank)
        dtxx = dtxx_bank(ii);
        dtxy = dtxy_bank(jj);
        [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);
        % Tau1
        %         K3_visualization_impulse(~isnan(ind),jj, ii) = K3(wind(:) == 1);
        K3_visualization_impulse(1:sum(~isnan(ind)),jj, ii) = K3(wind(:) == 1);
    end
end
K3_visualization_impulse = K3_visualization_impulse(1:tMaxShow, :,:);
for ii = 1:1:length(dtxx_bank)
    K3_visualization_glider(:,ii) = sum(K3_visualization_impulse(:,:,ii), 1);
end
% MakeFigure;
if plot_flag
    maxValue = max(abs(K3_visualization_impulse(:)));
    for ii = 1:1:length(dtxx_bank)
        subplot(length(dtxx_bank),1, ii )
        quickViewOneKernel(K3_visualization_impulse(:,:,ii), 1, 'labelFlag', false, 'set_clim_flag', true, 'clim', maxValue);
        if ii == 3
            xlabel('\tau3 - \tau1');
        end
        set(gca, 'XTick', 1: length(dtxy_bank), 'XTickLabel', strsplit(num2str(dtxy_bank)));
        ylabel('\tau1');
        yLim = get(gca, 'YLim');
        % plot the dt = 0 line...
        hold on
        tau3_tau1 = find(dtxy_bank == 0);
        plot([tau3_tau1,tau3_tau1], [0, tMax], 'k--')
        tau3_tau2 = find(dtxy_bank == dtxx_bank(ii));
        plot([tau3_tau2,tau3_tau2], [0, tMax], 'k--');
        tau1_tau2_middle = (dtxx_bank(ii)/2) + tau3_tau1;
        plot([tau1_tau2_middle,tau1_tau2_middle], [0, tMax], 'r--');
        ConfAxis
        title(['\tau2 - \tau1 = ', sprintf('%d',dtxx_bank(ii))]);
        % title, the middle line and the label.
    end
end
% plot the average over time.



end
