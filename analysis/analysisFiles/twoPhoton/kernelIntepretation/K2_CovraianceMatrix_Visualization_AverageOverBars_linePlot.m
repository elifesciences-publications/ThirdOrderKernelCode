function data = K2_CovraianceMatrix_Visualization_AverageOverBars_linePlot(cov_mat_mean,cov_mat_mean_noise, cov_mat_individual, varargin)

barUse = {[8,9,10],[9,10,11],[9,10,11],[8,9,10]};
dx_plot_bank = [0,1,2,3];
n_average_over_bars_bank = [2,3];
typeStr = {'T4_Pro', 'T4_Reg', 'T5_Pro', 'T5_Reg'};

alpha = 0.05;
dt_bank = [-12:1:12];
% correlation between them.
n_noise = length(cov_mat_mean_noise);
saveFigFlag = false;
plot_four_types_together_flag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% to draw them in the same scale, calculate first.
nType = length(typeStr);
dt_x_dx_plot_average_over_bar_all = cell(nType, 1);
resp_mean_all = cell(nType, 1);
resp_sem_all = cell(nType, 1);
shuffle_mean_all = cell(nType, 1);
shuffle_std_all = cell(nType, 1);
p_val_all = cell(nType, 1);


for tt = 1:1:nType
    
    x_bank_this_type = barUse{tt};
    cov_mat_mean_noise_this_type = cellfun(@(A)A{tt}, cov_mat_mean_noise,'UniformOutput', false);
    cov_mat_mean_this_type = cov_mat_mean{1}{tt};
    cov_mat_individual_this_type = cov_mat_individual{tt};
    
    % get all diagnal points to be zero
    n_length_cov = size(cov_mat_mean_this_type,1);
    cov_mat_mean_this_type(eye(n_length_cov ) == 1) = 0;
    for nn = 1:1:n_noise
        cov_mat_mean_noise_this_type{nn}(eye(n_length_cov ) == 1) = 0;
    end
    nRoi = length(cov_mat_individual_this_type);
    for rr = 1:1:nRoi
        cov_mat_individual_this_type{rr}(eye(n_length_cov) == 1) = 0;
    end
    [cov_mat_glider_aligned,  cov_mat_glider_aligned_noise] ...
        = K2_Visualization_Compute_Cov_Mat_Glider_Mean_MeanNoise(cov_mat_mean_this_type, cov_mat_mean_noise_this_type, varargin{:});
    
    [~,  cov_mat_glider_aligned_individual] ...
        = K2_Visualization_Compute_Cov_Mat_Glider_Mean_MeanNoise(cov_mat_mean_this_type, cov_mat_individual_this_type, varargin{:});
    
    %% prepare data strorage for different n.
    dt_x_dx_plot_average_over_bar_all{tt} = cell(length(n_average_over_bars_bank), 1);
    resp_mean_all{tt} = cell(length(n_average_over_bars_bank), 1);
    resp_sem_all{tt} = cell(length(n_average_over_bars_bank), 1);
    shuffle_mean_all{tt} = cell(length(n_average_over_bars_bank), 1);
    shuffle_std_all{tt} = cell(length(n_average_over_bars_bank), 1);
    p_val_all{tt} = cell(length(n_average_over_bars_bank), 1);
    
    for nn = 1:1:length(n_average_over_bars_bank)
        
        %% prepare data storage for different dx
        MakeFigure;
        
        dt_x_dx_plot_average_over_bar_all{tt}{nn} = cell(length(dx_plot_bank), 1);
        resp_mean_all{tt}{nn} = cell(length(dx_plot_bank), 1);
        resp_sem_all{tt}{nn} = cell(length(dx_plot_bank), 1);
        shuffle_mean_all{tt}{nn} = cell(length(dx_plot_bank), 1);
        shuffle_std_all{tt}{nn} = cell(length(dx_plot_bank), 1);
        
        for dxx = 1:1:length(dx_plot_bank)
            % for each average method and different dxx, you get all the
            % value.
            [dt_x_dx_plot_average_over_bar, shuffle_mean, shuffle_std, p_val] = ...
                K2_Visualization_AverageOverBars_Computation(cov_mat_glider_aligned, cov_mat_glider_aligned_noise, ...
                'x_bank', x_bank_this_type, 'dx_plot',dx_plot_bank(dxx),'n_average_over_bars',n_average_over_bars_bank(nn),'dt_bank',dt_bank ,'dt',dt, 'nMultiBars',nMultiBars);
            [~, resp_mean, resp_std, ~] = ...
                K2_Visualization_AverageOverBars_Computation(cov_mat_glider_aligned, cov_mat_glider_aligned_individual, ...
                'x_bank', x_bank_this_type, 'dx_plot',dx_plot_bank(dxx),'n_average_over_bars',n_average_over_bars_bank(nn),'dt_bank',dt_bank, 'dt',dt, 'nMultiBars',nMultiBars);
            resp_sem = resp_std/sqrt(nRoi);
            
            
            
            dt_x_dx_plot_average_over_bar_all{tt}{nn}{dxx} = dt_x_dx_plot_average_over_bar;
            resp_mean_all{tt}{nn}{dxx}                     = resp_mean;
            resp_sem_all{tt}{nn}{dxx}                      = resp_sem;
            shuffle_mean_all{tt}{nn}{dxx}                  = shuffle_mean;
            shuffle_std_all{tt}{nn}{dxx}                   = shuffle_std;
            p_val_all{tt}{nn}{dxx}                         = p_val;
            
            n_bar_plot = size(dt_x_dx_plot_average_over_bar, 2);
            maxValue = max(abs(dt_x_dx_plot_average_over_bar(:))) * 1.2;
            for qq = 1:1:n_bar_plot
                subplot(length(dx_plot_bank), n_bar_plot, (dxx - 1) * n_bar_plot + qq)
                K2_Visualization_AverageOverBars_LinePlot_OneGlider...
                    (dt_bank, dt_x_dx_plot_average_over_bar(:,qq), resp_sem(:,qq), shuffle_std(:,qq), shuffle_mean(:,qq), p_val(:,qq), maxValue, alpha);
                % remember the dx, bar position and ave over.
                titleStr = ['dx', num2str(dx_plot_bank(dxx)), 'Ave', num2str(n_average_over_bars_bank(nn)), 'Bar', num2str(x_bank_this_type(qq))];
                if dxx == 1
                title(titleStr);
                else
                    title(['dx', num2str(dx_plot_bank(dxx))]);
                end
                
            end
        end
        
        if saveFigFlag == true
            MySaveFig_Juyue(gcf,['K2_Vis_','AveOverBars_line', typeStr{tt}],titleStr,'nFigSave',2,'fileType',{'png','fig'});
        end
    end
end

data.dt_x_dx_plot_average_over_bar     = dt_x_dx_plot_average_over_bar_all;
data.resp_mean                         = resp_mean_all;
data.resp_sem                          = resp_sem_all;
data.shuffle_mean                      = shuffle_mean_all;
data.shuffle_std                       = shuffle_std_all;
data.p_val                             = p_val_all;

%% only work for n
%
if plot_four_types_together_flag == 1 && length(n_average_over_bars_bank) == 1 &&  n_bar_plot == 1
    
    allValue = zeros(nType,length(dt_bank),length(dx_plot_bank));
    for tt = 1:1:4
        for  dxx = 1:1:length(dx_plot_bank)
            allValue(tt, :,dxx) = data.dt_x_dx_plot_average_over_bar{tt}{1}{dxx};
        end
    end
    
    maxValue = 1.2 * max(abs(allValue(:)));
    MakeFigure;
    type_str = {'T4 Pro', 'T4 Reg', 'T5 Pro', 'T5 Reg'};
    for tt = 1:1:nType
        
        
        for dxx = 1:1:length(dx_plot_bank)
            
            dt_x_dx_plot_average_over_bar = data.dt_x_dx_plot_average_over_bar{tt}{1}{dxx};
            resp_sem = data.resp_sem{tt}{1}{dxx};
            shuffle_std = data.shuffle_std{tt}{1}{dxx};
            shuffle_mean = data.shuffle_mean{tt}{1}{dxx};
            p_val = data.p_val{tt}{1}{dxx};
            
            subplot(length(dx_plot_bank), nType, (dxx - 1) * nType + tt);
            if dxx == 3 && tt == 1
                label_flag = true;
            else
                label_flag = false;
            end
            
            if tt == nType
                dx_label_flag = true;
            else
                dx_label_flag = false;
            end
            K2_Visualization_AverageOverBars_LinePlot_OneGlider...
                (dt_bank, dt_x_dx_plot_average_over_bar, resp_sem, shuffle_std, shuffle_mean, p_val, maxValue, alpha,...
                'label_flag', label_flag, 'dx_label_flag', dx_label_flag, 'dx', dxx );
            
            % for the title
            if dxx == 1
                title([type_str{tt}]);
            end
            
            if saveFigFlag == true
                MySaveFig_Juyue(gcf,'K2_Vis_averOverBars_linePlot_noSigTest',[],'nFigSave',2,'fileType',{'png','fig'});
            end
            
        end
    end
end

end