function K3_Visualization_ConDiv_AverageOverBars(third_mean, third_data_each_type, varargin)
n_bars_averaged_over = 3;
barUse_Bank = {[8:12],[8:12], [9:13], [7:11]};

dx_bank_plot = {[0,-2],[0,-1],[0,1],[0,2]};
dx_bank = {[0,1],[0,-1],[0,2],[0,-2]};
dt_vary = (1:10)';
p_thresh = 0.05;
typeStr = {'T4 Pro', 'T4 Reg', 'T5 Pro', 'T5 Reg'};

saveFigFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

nType = 4;
third_visualization_x_ave_mean = cell(nType, 1);
third_visualization_x_ave_p = cell(nType, 1);
third_visualization_x_ave_sem = cell(nType, 1);

for tt = 1:1:4
    %% get the third order kernel for this type
    tic
    barUse = barUse_Bank{tt};
    third_kernel_mean_this_type =   third_mean{tt};
    third_kernel_individual_roi_this_type =  third_data_each_type{tt};
    
    %     %% color plot for individual positions.
    %     [third_visualization_x_fixed_mean_this_type, third_visualization_x_fixed_p_this_type] ...
    %         = K3_Visualization_ConvDiv_AverageOverIndividualRois(third_kernel_mean_this_type, third_kernel_individual_roi_this_type,...
    %         'dx_bank', dx_bank, 'dx_bank_plot', dx_bank_plot,...
    %         'barUse', barUse,'mode', 'x_fixed', 'plot_flag', false);
    %
    %     MakeFigure;
    %     for qq = 1:1:length(barUse)
    %         subplot(2,length(barUse),qq)
    %         K3_Visualizatoin_Utils_One_Plot_X_Fixed_Plot(third_visualization_x_fixed_mean_this_type{qq}, barUse(qq), dx_bank_plot, dt_vary);
    %         hold on
    %         K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(third_visualization_x_fixed_p_this_type{qq} < p_thresh);
    %         title(['x_{position} = ', num2str(barUse(qq))]);
    %     end
    
    %% third order converging or diverging for averaged positions,
    [third_visualization_x_ave_mean_this_type, third_visualization_x_ave_p_this_type, third_visualization_x_ave_sem_this_type] ...
        = K3_Visualization_ConvDiv_AverageOverIndividualRois(third_kernel_mean_this_type, third_kernel_individual_roi_this_type,...
        'dx_bank', dx_bank, 'dx_bank_plot', dx_bank_plot,...
        'barUse', barUse,'mode', 'x_fixed_average_over_bars', 'plot_flag', false, 'n_bars_averaged_over',n_bars_averaged_over, 'dt_vary', dt_vary);
    
    n_barUse_averaged_over_bars = length(barUse) - n_bars_averaged_over + 1;
    %     % color plot
    %     for qq = 1:1:n_barUse_averaged_over_bars
    %         subplot(2,length(barUse),qq + length(barUse))
    %         K3_Visualizatoin_Utils_One_Plot_X_Fixed_Plot(third_visualization_x_ave_mean_this_type{qq}, barUse(qq), dx_bank_plot, dt_vary);
    %         hold on
    %         K2_CovarianceMatrix_Visualization_Utils_Image_SigPoint(third_visualization_x_ave_p_this_type{qq} < p_thresh);
    %         title(['x_p=', num2str(barUse(qq)), ' ave ', num2str(n_bars_averaged_over)]);
    %         % change the title.
    %     end
    third_visualization_x_ave_mean{tt} = third_visualization_x_ave_mean_this_type;
    third_visualization_x_ave_p{tt} = third_visualization_x_ave_p_this_type;
    third_visualization_x_ave_sem{tt} =  third_visualization_x_ave_sem_this_type;
    
    %     if save_fig_flag
    %         MySaveFig_Juyue(gcf,'ThirdKernelVisualization_x_fixed_ave_color', typeStr{tt},'nFigSave',2,'fileType',{'png','fig'});
    %     end
    %
    % individual line plot.
    n_dt = length(dt_vary);
    n_dx_bank_plot = length(dx_bank_plot);
    dt_bank = [- dt_vary(end:-1:1); dt_vary]';
    
    for  qq = 1:1:n_barUse_averaged_over_bars
        maxValue = 1.2 * max(abs(third_visualization_x_ave_mean_this_type{qq}(:)));
        MakeFigure;
        % converging at different position. first half is converging.
        conv_or_div = {'conv', 'div'}; % converge first. diverge second.
        for jj = 1:1:2
            for ii = 1:1:n_dx_bank_plot/2
                % for different dx_bank_plot. 1 end 4, or 2 and 3... kind of
                % dangerous.
                if strcmp(conv_or_div{jj}, 'conv')
                    row_ind = [1:n_dt; n_dt:-1:1];
                else
                    row_ind = [2 * n_dt : -1: n_dt + 1; n_dt + 1: 1 : 2* n_dt];
                end
                % shorter spatial scale first.
                ii_inv = 2 - ii + 1;
                column_ind = [ii_inv; n_dx_bank_plot - ii_inv + 1];
                resp_mean_this = [third_visualization_x_ave_mean_this_type{qq}(row_ind(1,:), column_ind(1)); third_visualization_x_ave_mean_this_type{qq}(row_ind(2,:), column_ind(2))];
                resp_sem_this  = [third_visualization_x_ave_sem_this_type{qq}(row_ind(1,:), column_ind(1)); third_visualization_x_ave_sem_this_type{qq}(row_ind(2,:), column_ind(2))];
                p_this         = [third_visualization_x_ave_p_this_type{qq}(row_ind(1,:), column_ind(1)); third_visualization_x_ave_p_this_type{qq}(row_ind(2,:), column_ind(2))];
                subplot(n_dx_bank_plot/2, 2, (ii -1) * 2 + jj); % converging
                K3_Visualization_LinePlot_OneGlider(dt_bank, resp_mean_this, resp_sem_this, p_this, maxValue, 'alpha', p_thresh);
            end
        end
        
    end
    toc
end

% four line_plot_together

%%
MakeFigure;
all_value = zeros([size(third_visualization_x_ave_mean{1}{1}), nType]);
for tt = 1:1:4
    all_value(:,:,tt) = third_visualization_x_ave_mean{tt}{1};
end
maxValue = max(abs(all_value(:)));

for tt = 1:1:4
    conv_or_div = {'conv', 'div'}; % converge first. diverge second.
    for jj = 1:1:2
        
        % for different dx_bank_plot. 1 end 4, or 2 and 3... kind of
        % dangerous.
        if strcmp(conv_or_div{jj}, 'conv')
            row_ind = [1:n_dt; n_dt:-1:1];
        else
            row_ind = [2 * n_dt : -1: n_dt + 1; n_dt + 1: 1 : 2* n_dt];
        end
        column_ind = [2,3];
        resp_mean_this = [third_visualization_x_ave_mean{tt}{qq}(row_ind(1,:), column_ind(1)); third_visualization_x_ave_mean{tt}{qq}(row_ind(2,:), column_ind(2))];
        resp_sem_this  = [third_visualization_x_ave_sem{tt}{qq}(row_ind(1,:), column_ind(1)); third_visualization_x_ave_sem{tt}{qq}(row_ind(2,:), column_ind(2))];
        p_val_this     = [third_visualization_x_ave_p{tt}{qq}(row_ind(1,:), column_ind(1)); third_visualization_x_ave_p{tt}{qq}(row_ind(2,:), column_ind(2))];
        subplot(4, 2, (tt -1) * 2 + jj); % converging
        if tt == 4 && jj == 2
            label_flag = true;
        else
            label_flag = false;
        end
        K3_Visualization_LinePlot_OneGlider(dt_bank, resp_mean_this, resp_sem_this, p_val_this, maxValue,'alpha', p_thresh, 'label_flag', label_flag);
        
        if jj == 1
            t = text(- n_dt - 5, 0, typeStr{tt});
            t.FontSize = 20;
            
        end
        
        if tt == 1
            t = text(n_dt + 0.5, 100, conv_or_div{jj});
            t.FontSize = 20;
        end
    end
    
end
if saveFigFlag
    MySaveFig_Juyue(gcf,'K3_Vis_ave_lin_plot_4Type', '','nFigSave',2,'fileType',{'png','fig'});
end

end
