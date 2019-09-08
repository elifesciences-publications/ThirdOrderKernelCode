function NS_NoiseReduction_Statistics_V2(statistics, noise_reduction, varargin)
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
NS_ns_statistics_density2d_visual(binedz, xLabelStr, yLabelStr, edge_preselect{1}, edge_preselect{2}, ...
        'clim_flag', true, 'clim', [-max(binedz(:)),max(binedz(:))]);
colorbar
title(titleStr);
ConfAxis

subplot(5,5, 25);
NS_ns_statistics_density2d_visual(n_z, xLabelStr, yLabelStr, edge_preselect{1}, edge_preselect{2}, ...
        'clim_flag', true, 'clim', [-max(n_z(:)),max(n_z(:))]);
title('density')

subplot(5,5,[21,22,23])
ScatterXYBinned(statistics{1},noise_reduction,nBin(1),nOneBin,'plotDashLineFlag',false,'color','k','edge_distribution',edge_distribution, 'edge_preselect', edge_preselect{1},...
    'clean_extreme_value_flag', clean_extreme_value_flag);
xlabel(xLabelStr);
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
view(90,90); %% This is wrong all the time? That is scary....
ConfAxis

%% you have plot a nice density map. where it is?
end
