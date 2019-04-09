function STC_Utils_PredRespAndResp_Plot(predResp, resp, varargin)
nOneBin = 50;
nBin = [16,16];
clean_extreme_value_flag = false;
edge_distribution = 'histeq';
ylabelStr = 'Current pA (mean subtracted)';
for ii = 1:2:length(varargin)
      eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

[binedx,binedy,binedz,n_x, n_y, n_z, sem, edgex, edgey] = BinXYZ(predResp{1},predResp{2},resp,nBin, edge_distribution, clean_extreme_value_flag);

% if there are less than 100 points. you should not draw it.
% only draw part of it. in terms of n_x, n_y. interms of z,100 .

% by n_x and n_y would be easier.
% use the connected?

ind_z = n_z > nOneBin;
masks = MyBWConncomp(ind_z,1); % find the largest contigous area...
% set the zeros part to be nan?
binedz(~masks) = 0;

%%
MakeFigure;
% subplot(5,5,[7,8,9,12,13,14,17,18,19,22,23,24])
subplot(5,5,[1,2,3,6,7,8,11,12,13,16,17,18])
% x_plot = binedx;
% y_plot = flipud(binedy);
% z_plot = flipud(binedz);
[x_grid, y_grid] =ndgrid(binedx, binedy);
[x_grid, y_grid] =ndgrid(edgex, edgey);
% z_grid = [binedz,nan(nBin (2),1)];  z_grid  = [z_grid; nan(1, nBin(1) + 1)];
z_grid  = binedz;
ImagescXYZBinned(x_grid, y_grid, z_grid,'binFlag',false,'labelFlag', true, ...
    'titleStr',['resp VS predicted resp'],'xLabelStr','1^{st} component','yLabelStr','2^{nd} component')

% contour plot
zmin = min(binedz(:));
zmax = max(binedz(:));
zinc = (zmax - zmin) / 10;
zlevs = zmin:zinc:zmax;
% 
hold on
[x_grid_countour,y_grid_countour] = ndgrid(binedx, binedy);
z_grid_countour = binedz;
% contour(x_grid_countour,y_grid_countour, z_grid_countour ,zlevs,'LineColor','k','LineWidth', 1);
% xlabel('1^{st} component');
% ylabel('2^{nd} component');
title('response VS predicted response');
ConfAxis

% [binedx_only,binedxz_only] = BinXY(predResp{1},resp_plot,'mode','x','nbins',20, 'edge_distribution',edge_distribution, 'clean_extreme_value_flag',clean_extreme_value_flag);
% [binedy_only,binedyz_only] = BinXY(predResp{2},resp_plot,'mode','x','nbins',20, 'edge_distribution',edge_distribution, 'clean_extreme_value_flag',clean_extreme_value_flag);

subplot(5,5,[21,22,23])
% scatter(binedx_only,binedxz_only,'.');
ScatterXYBinned(predResp{1},resp,nBin(1),nOneBin,'plotDashLineOtherSideFlag',true,'color','k','edge_distribution',edge_distribution, 'clean_extreme_value_flag', clean_extreme_value_flag);
xlabel('1^{st} component');
% title('Marginal')
ylabel(ylabelStr);
ConfAxis



subplot(5,5,[4,9,14,19]);
ScatterXYBinned(predResp{2},resp,nBin(2),nOneBin,'plotDashLineOtherSideFlag',true,'color','k','edge_distribution',edge_distribution, 'clean_extreme_value_flag', clean_extreme_value_flag);
% xlabel('2^{nd} component');

ylabel(ylabelStr);
set(gca,'YAxisLocation', 'right');
% put the position of ylabel to top
view(90,-90);
ConfAxis
end
