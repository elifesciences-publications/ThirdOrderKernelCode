function n = grid_approximation_show(data, varargin)
thresh_n_datapoints = 0.001;
n_bin = 500;
edges = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% data = contrast{ff}(:,[1,20]);
% extract histogram data.
% MakeFigure;
if ~isempty(edges)
    n = hist3(data,'Edges', edges);
    imagesc(edges{1}, edges{2}, log(n./sum(n(:))));
    colobar_handle = colorbar;
    colobar_handle.Label.String = 'log(probability)';
else
    n = hist3(data, 'NBins',[n_bin, n_bin]);
    n1 = n';
    n1(size(n, 1) + 1, size(n, 2) + 1) = 0;
    xb = linspace(min(data(:,1)), max(data(:,1)), size(n, 1) + 1);
    yb = linspace(min(data(:,2)), max(data(:,2)), size(n, 1) + 1);
    
    % count on one dimension.
    c1 = sum(n1,1);
    c2 = sum(n1,2);
    
    ind = (c1 > round(thresh_n_datapoints * size(data,1)))  & (c2 > round(thresh_n_datapoints * size(data,2)))';
    pcolor(xb(ind), yb(ind), log(n1(ind,ind)));

end
% lineStyles = linspecer(100);

lineStyles = brewermap(20,'Blues');
colormap(lineStyles);

end

% hist3(X,'Edges',edges)