function FigurePlot_Poster_WithinScene_Histogram(X, h, legend_str)
axes('Units', h.Units, 'Position', h.Position);

h_corr = cell(2, 1);
h_corr{1} = histogram(X{1}, 'Normalization','probability'); h_corr{1}.FaceColor = [0,0,0];
hold on
h_corr{2} = histogram(X{2}, 'Normalization','probability'); h_corr{2}.FaceColor = [0,0.5,0];
% set transparency...
xlabel('correlation');
ylabel('frequency');
legend(legend_str)
ConfAxis
end