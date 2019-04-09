function ImagescXYZBinned(x,y,z,varargin)
binFlag = false; % which means it has already been binned.
nOneBin = [];
titleStr = [];
xLabelStr = [];
yLabelStr = [];
labelFlag = false;
% first, decide whether you want to bin it or not.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if binFlag
    % second, plot it out
    [x_plot,y_plot,z_plot,n_x, n_y, n_z] = BinXYZ(x, y, z, nBin);
    ind_z = n_z > nOneBin;
    masks = MyBWConncomp(ind_z,1);
    % set the zeros part to be nan?
    z_plot(~masks) = 0;
else
    % z should be two dimesinal matrix/
    x_plot = x;
    y_plot = y;
    z_plot = z;
end

% plot this by scale...
% interesting... as damon.
% using path?
pcolor(x_plot,y_plot,z_plot);
% pcolor(y_plot,x_plot,z_plot');
if labelFlag
    title(titleStr);
    xlabel(xLabelStr);
    ylabel(yLabelStr);
end
xmax = max(abs(x_plot));
ymax = max(abs(y_plot));
z_max = max(abs(z_plot(:)));

axis_max = max([ xmax, ymax]) * 1.1;
% set(gca,'XLim',[-axis_max, axis_max]);
% set(gca,'YLim',[-axis_max, axis_max]);
set(gca,'ZLim',[-z_max,z_max]);
set(gca,'CLim',[-z_max,z_max]);
set(gca,'Color',[1,1,1]);
colormap_gen;
colormap(mymap);
% colorbar
ConfAxis;

shading flat

end