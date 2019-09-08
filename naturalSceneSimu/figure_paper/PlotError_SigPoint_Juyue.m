function PlotError_SigPoint_Juyue(x, p_sig, yLimMax)
pThresh = 0.05;
pThreshStrict = 0.01;
astHeight = yLimMax * 0.95;
text(x(p_sig<pThresh & p_sig>pThreshStrict), astHeight*ones(sum(p_sig<pThresh & p_sig>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
text(x(p_sig<pThreshStrict), astHeight*ones(sum(p_sig<pThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
end