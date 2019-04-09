function K2_CovarianceMatrix_Visualization_Correlation_Of_KernelEle(cov_mat,varargin)
%% dx is fixed. change dt and x
dt_plot_bank = [-8:1:8];
dx_plot_bank = [1,2];
dt_bank = [-12:1:12];
x_bank = [9:12]; % that is reasonable.
title_str = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

n_roi = length(cov_mat);
% you also want to know what is there type. can you know that? no here.
% from here, you do not know where do they come from.
n_entris = length(dt_plot_bank) * length(dx_plot_bank) * length(x_bank);
corr_2o = zeros(n_entris, n_roi);
tic
for rr = 1:1:n_roi
    corr_2o(:,rr) = K2_CovarianceMatrix_Visualization_ReorganizeGliderResp(cov_mat{rr},dt_bank, dt_plot_bank, x_bank, dx_plot_bank);
end
toc

corr_of_corr_2o = corr(corr_2o');
MakeFigure; quickViewOneKernel(corr_of_corr_2o,1,'labelFlag', false);
% start plotting the lines.
xLim = get(gca,'XLim');
yLim = get(gca,'YLim');
% first, draw some dash line for different dx...
n_entry_one_dx = length(dt_plot_bank) * length(x_bank);
% lines between different dx
for ii = 1:1:length(dx_plot_bank)
    hold on
    dashline_p = ii * n_entry_one_dx + 0.5;
    plot(xLim, [dashline_p , dashline_p ],'k');
    plot([dashline_p , dashline_p],yLim,'k');
end
% text for dx
for ii = 1:1:length(dx_plot_bank)
    str_dx = ['dx : ', num2str(dx_plot_bank(ii))];
    text(-20, (ii-1) * n_entry_one_dx +  floor(n_entry_one_dx /2), str_dx);
    text((ii-1) * n_entry_one_dx +  floor(n_entry_one_dx /2), -20, str_dx);
end

% lines between different x
n_entry_one_dt = length(dt_plot_bank);
for ii = 1:1:length(dx_plot_bank) * length(x_bank)
    hold on
    dashline_p = ii * n_entry_one_dt + 0.5;
    plot(xLim, [dashline_p , dashline_p ],'k-.');
    plot([dashline_p , dashline_p],yLim,'k-.');
end
% you have to loop this.
for ii = 1:1:length(dx_plot_bank)
    for jj = 1:1:length(x_bank)
        str_x = ['x : ', num2str(x_bank(jj))];
        text(-3,  (ii - 1)* n_entry_one_dx + (jj-1) * n_entry_one_dt +  floor(n_entry_one_dt/2), str_x);
        text((ii - 1)* n_entry_one_dx + (jj-1) * n_entry_one_dt +  floor(n_entry_one_dt/2), -10,  str_x);
    end
    
end

% lines between different dt. (direction)
n_entry_one_dt = length(dt_plot_bank);
for ii = 1:1:length(dx_plot_bank) * length(x_bank)
    hold on
    dashline_p = ceil(n_entry_one_dt/2) + (ii - 1) * n_entry_one_dt;
    plot(xLim, [dashline_p , dashline_p ],'g-.');
    plot([dashline_p , dashline_p],yLim,'g-.');
end

set(gca,'XTick',[]);
set(gca,'YTick',[]);
% get the label correct.

title(title_str)

end

function corr_of_2o_corr = K2_CovarianceMatrix_Visualization_ReorganizeGliderResp(cov_mat, dt_bank, dt_plot_bank, x_bank, dx_plot_bank )

gliderRespPred = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat);
dt_x_dx_plot = zeros(length(dt_plot_bank), length(x_bank),length(dx_plot_bank));
dt_plot_ind = ismember(dt_bank,dt_plot_bank);

for xx = 1:1:length(x_bank)
    for dxx = 1:1:length(dx_plot_bank)
        dx_plot = dx_plot_bank(dxx);
        dt_x_dx_plot(:,xx,dxx) = gliderRespPred(dt_plot_ind, x_bank(xx), x_bank(xx) + dx_plot);
    end
end

corr_of_2o_corr = dt_x_dx_plot(:);
end




