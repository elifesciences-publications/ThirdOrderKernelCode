function NS_ns_statistics_density2d_visual(X, xlabelstr, ylabelstr, x_edges, y_edges, varargin)
clim_flag = false;
clim = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
X = X';
imAlpha = ones(size(X));
imAlpha(isnan(X))=0;
imagesc(X,'AlphaData',imAlpha);
set(gca,'color',1*[0.8, 0.8, 0.8]);

set(gca, 'XTick', [1:2:length(x_edges)] - 0.5, 'XTickLabel',num2str(x_edges(1:2:end), 3));
set(gca, 'YTick', [1:2:length(y_edges)] - 0.5, 'YTickLabel',num2str(y_edges([1:2:length(y_edges) ])));
set(gca, 'XLim', [0.5, length(x_edges) - 0.5]);
set(gca, 'YLim', [0.5, length(y_edges) - 0.5]);

xlabel(xlabelstr);
ylabel(ylabelstr);
colormap_gen;
colormap(mymap);
%% reverse
set(gca, 'Ydir','normal');
if clim_flag
    set(gca, 'CLim', clim);
end
end