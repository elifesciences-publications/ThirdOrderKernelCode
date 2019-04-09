% you should have a different function, which integrate them together.
function K2_CovarianceMatrix_Visualization_One_Plot(gliderRespPred, plotting_mode, varargin)
% mode : 'dt_x_dx', 'x_x_dt', 'dx_dt_x', 'dx_dt_x_flip'

% first, check what is the input...
nMultiBars = 20;
saveFigFlag = false;
MainName = 'SecondOrder';
typeStr = [];
% these parameter is more or less fixed.
dt_bank = [-8:1:8];
x_bank = [8:13];
dx_bank = [-5:5];
%
dt_plot = [0];
dx_plot = [1];
x_plot = [12];
%
title_main_name = [];
% scale of color bar.
set_color_scale_flag = false;
max_value = [];
%
plot_significant_point_flag = false;
gliderRespPred_sig = [];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[dt_bank_length,nMultiBars, ~] = size(gliderRespPred);
dt = (1:dt_bank_length) - (dt_bank_length + 1)/2;
switch plotting_mode
    
    case 'dt_x_dx'
        %% dx is fixed. change dt and x.
        
        dt_x_dx_plot = zeros(length(dt_bank), length(x_bank));
        dt_plot_ind = ismember(dt,dt_bank);
        
        x_bank = x_bank((x_bank + dx_plot) <= nMultiBars);

        for xx = 1:1:length(x_bank)
            dt_x_dx_plot(:,xx) = gliderRespPred(dt_plot_ind,x_bank(xx), x_bank(xx) + dx_plot);
        end
        
        quickViewOneKernel(dt_x_dx_plot,1,'labelFlag',false);
        title([title_main_name,' dx = ', num2str(dx_plot)],'FontSize',30);
        
        %% xlabel
        ylabel('dt');
        xlabel('bar #');
        set(gca, 'YTick',1:length(dt_bank), 'YTickLabel', strsplit(num2str(dt_bank)));
        set(gca, 'XTick', 1:length(x_bank), 'XTickLabel', strsplit(num2str(x_bank)));
        hold on
        plot([0,length(x_bank) + 1],[find(dt_bank == 0), find(dt_bank == 0)],'k--');
        
        % if significant point.
        if plot_significant_point_flag
            hold on
            dt_x_dx_plot_sig = zeros(length(dt_bank), length(x_bank));
            for xx = 1:1:length(x_bank)
                dt_x_dx_plot_sig(:,xx) = gliderRespPred_sig(dt_plot_ind, x_bank(xx), x_bank(xx) + dx_plot);
            end
            K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(dt_x_dx_plot_sig);
        end
        
        
    case 'x_x_dt'
        % dt is fix. plot
        x_x_dt_plot = zeros(length(x_bank),nMultiBars);
        for xx = 1:1:length(x_bank)
            x_this = x_bank(xx);
            x_x_dt_plot(xx, x_this + dx_bank) =squeeze(gliderRespPred(dt == dt_plot, x_this,x_this + dx_bank)); % use zeros.
        end
        
        quickViewOneKernel(x_x_dt_plot,1,'labelFlag',false);
        hold on
        plot([x_bank(1) - 1,x_bank(end) + 1],[1 - 1,length(x_bank) + 1],'k-');
        plot([0,nMultiBars + 1],[length(x_bank)/2 + 0.5,length(x_bank)/2 + 0.5],'k-');
        
        
        title([title_main_name, sprintf('dt = %d', dt_plot)]);
        set(gca,'XTick',1:2:20,'XTickLabel',strsplit(num2str(1:2:20)));
        xlabel('spatial position');
        
        set(gca,'YTick',1:length(x_bank),'YTickLabel',strsplit(num2str(x_bank)));
        ylabel('spatial position');
        
        if plot_significant_point_flag
            hold on
            x_x_dt_plot_sig = zeros(length(x_bank),nMultiBars);
            for xx = 1:1:length(x_bank)
                x_this = x_bank(xx);
                x_x_dt_plot_sig(xx, x_this + dx_bank) =squeeze(gliderRespPred_sig(dt == dt_plot, x_this,x_this + dx_bank)); % use zeros.
            end
            K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(x_x_dt_plot_sig);
        end
        
    case 'dt_dx_x'
        dt_plot_ind = ismember(dt,dt_bank);
        dt_dx_x_plot = squeeze(gliderRespPred(dt_plot_ind, x_plot, x_plot + dx_bank));
        
        quickViewOneKernel(dt_dx_x_plot,1,'labelFlag',false);
        hold on
        
        title([title_main_name, sprintf(' spatial position = %d',  x_plot)]);
        
        set(gca,'XTick',1:length(dx_bank),'XTickLabel',strsplit(num2str(dx_bank)));
        xlabel('dx');
        
        set(gca,'YTick',1:length(dt_bank),'YTickLabel',strsplit(num2str(dt_bank)));
        ylabel('dt');
        hold on
        plot([find(dx_bank == 0),find(dx_bank == 0)],[0,length(dt_bank)+ 1],'k-');
        plot([0,length(dx_bank)+ 1],[find(dt_bank == 0),find(dt_bank == 0)],'k-');
        
        if plot_significant_point_flag
            hold on
            dt_dx_x_plot_sig = squeeze(gliderRespPred_sig(ismember(dt, dt_bank), x_plot, x_plot + dx_bank));
            K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(dt_dx_x_plot_sig);
        end
end

set(gca,'FontSize',10,'box','off','FontName','Arial');
ax = gca;
ax.LineWidth = 2;
ax.YLabel.FontSize = 20;
ax.XLabel.FontSize = 20;
ax.Title.FontSize = 20;

if set_color_scale_flag
    set(gca,'CLim',[-max_value,max_value]);
end
end