function NS_NoiseReduction_Statistics(statistics, noise_reduction, varargin)
nOneBin = 50;
nBin = [16,16];
clean_extreme_value_flag = false;
edge_distribution = 'histeq';
titleStr = 'noise reduction';
yLabelStr = [];
xLabelStr = [];
edge_preselect = [];
for ii = 1:2:length(varargin)
      eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

[binedx,binedy,binedz,n_x, n_y, n_z, sem, edgex, edgey] = BinXYZ(statistics{1},statistics{2},noise_reduction,nBin, edge_distribution, clean_extreme_value_flag, edge_preselect);
ind_z = n_z > nOneBin;
% masks = MyBWConncomp(ind_z,1); % find the largest contigous area...
 masks = ind_z;
% set the zeros part to be nan?
binedz(~masks) = 0;
n_z_plot = n_z; n_z_plot(~masks) = 0;
%%
MakeFigure;
subplot(5,5,[1,2,3,6,7,8,11,12,13,16,17,18])
[x_grid, y_grid] = ndgrid(binedx, binedy);
z_grid = binedz;
% do not use this grid. use imagesc.
ImagescXYZBinned(x_grid, y_grid, z_grid,'binFlag',false,'labelFlag', true, ...
    'titleStr',titleStr,'xLabelStr',xLabelStr,'yLabelStr',yLabelStr)
colorbar
set(gca, 'XLim', [0, max(binedx)] , 'YLim', [min(statistics{2}), max(binedy)]);

subplot(5,5, 25);
ImagescXYZBinned(x_grid, y_grid, n_z_plot,'binFlag',false,'labelFlag', true, ...
    'titleStr','density','xLabelStr',xLabelStr,'yLabelStr',yLabelStr)
xlabel([]);
ylabel([]);

% contour plot
% zmin = min(binedz(:));
% zmax = max(binedz(:));
% zinc = (zmax - zmin) / 10;
% zlevs = zmin:zinc:zmax;
% % 
% hold on
% [x_grid_countour,y_grid_countour] = ndgrid(binedx, binedy);
% z_grid_countour = binedz;
% contour(x_grid_countour,y_grid_countour, z_grid_countour ,zlevs,'LineColor','k','LineWidth', 1);
% % xlabel('1^{st} component');
% % ylabel('2^{nd} component');
% title('response VS predicted response');
% ConfAxis

% [binedx_only,binedxz_only] = BinXY(predResp{1},resp_plot,'mode','x','nbins',20, 'edge_distribution',edge_distribution, 'clean_extreme_value_flag',clean_extreme_value_flag);
% [binedy_only,binedyz_only] = BinXY(predResp{2},resp_plot,'mode','x','nbins',20, 'edge_distribution',edge_distribution, 'clean_extreme_value_flag',clean_extreme_value_flag);

subplot(5,5,[21,22,23])
% scatter(binedx_only,binedxz_only,'.');
ScatterXYBinned(statistics{1},noise_reduction,nBin(1),nOneBin,'plotDashLineFlag',false,'color','k','edge_distribution',edge_distribution, 'edge_preselect', edge_preselect{1},...
    'clean_extreme_value_flag', clean_extreme_value_flag);
xlabel(xLabelStr);
% title('Marginal')
ylabel(titleStr);
hold on; plot(get(gca, 'XLim'), [0,0], 'k--');

ConfAxis
set(gca, 'XLim', [0, max(binedx)]);

subplot(5,5,[4,9,14,19]);
ScatterXYBinned(statistics{2},noise_reduction,nBin(2),nOneBin,'plotDashLineFlag',false,'color','k','edge_distribution',edge_distribution, 'edge_preselect', edge_preselect{2},...
    'clean_extreme_value_flag', clean_extreme_value_flag);
set(gca, 'XLim', [min(statistics{2}), max(binedy)]);
hold on; plot(get(gca, 'XLim'), [0,0], 'k--');
ylabel(titleStr);
set(gca,'YAxisLocation', 'right');
% put the position of ylabel to top
view(90,-90);
ConfAxis

%% you have plot a nice density map. where it is?
end
