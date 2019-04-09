function glider_data_plot_utils_bar_plot_utils_error_bar(x, y, error)
% only plot those strict..?
dist = 0.15;
sign_ = [-1,1];
for ii = 1:1:length(x)
    % first, ask whether to draw.
    for jj = 1:1:2
        plot([ii + sign_(jj) * dist, ii + sign_(jj) * dist], [y(ii,jj) + error(ii,jj), y(ii,jj) - error(ii,jj)],'k');
    end
end

% text(x(p_sig<pThresh & p_sig>pThreshStrict), astHeight*ones(sum(p_sig<pThresh & p_sig>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
% text(x(p_sig<pThreshStrict), astHeight*ones(sum(p_sig<pThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
end