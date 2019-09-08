function glider_data_plot_utils_bar_plot_utils_sigPoint(x, p_sig, yLimMax)
pThresh = 0.05;
pThreshStrict = 0.01;
astHeight = yLimMax * 0.95;
% only plot those strict..?
dist = 0.15;
sign_ = [-1,1];
for ii = 1:1:length(x)
    % first, ask whether to draw.
    for jj = 1:1:2
        sig_mkr = '';
        if p_sig(ii, jj) < pThreshStrict
            sig_mkr = '**';
        elseif p_sig(ii, jj) < pThresh
            sig_mkr = '*';
        end
        text(ii + sign_(jj) * dist,astHeight, sig_mkr,'HorizontalAlignment', 'center', 'Color', [1 0 0],'FontSize', 10);
    end
end

% text(x(p_sig<pThresh & p_sig>pThreshStrict), astHeight*ones(sum(p_sig<pThresh & p_sig>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
% text(x(p_sig<pThreshStrict), astHeight*ones(sum(p_sig<pThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
end