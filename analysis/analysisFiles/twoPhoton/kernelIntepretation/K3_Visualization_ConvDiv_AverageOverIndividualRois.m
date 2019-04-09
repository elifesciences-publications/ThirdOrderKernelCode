function [third_visualization_mean, third_visualization_p, third_visualization_sem] ...
    = K3_Visualization_ConvDiv_AverageOverIndividualRois(third_kernel_mean, third_kernel_individual_roi, varargin)
dx_bank = {[0,1],[0,-1],[0,2],[0,-2]};
dx_bank_plot = {[0,-2],[0,-1],[0,1],[0,2]};
p_thresh = 0.01;
barUse = [];
mode_use = 'x_fixed';
n_bars_averaged_over = 2;
dt_vary = (1:5)';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

dt_vary_max = max(dt_vary);
%% calculate the correlation
third_visualization_mean =   K3_Visualization_Format_1213(third_kernel_mean, ...
    'dx_bank', dx_bank, 'dx_bank_plot', dx_bank_plot,'dt_vary_max',dt_vary_max,...
    'barUse', barUse,'mode', mode_use, 'plot_flag', false, varargin{:});
nRoi = length(third_kernel_individual_roi{1});
third_visualization_roi = cell(nRoi,1);
for rr = 1:1:nRoi
    third_kernel_this_roi = cell(4,1); % four dx_bank. 01 0-1 02 0-2
    for ii = 1:1:4
        third_kernel_this_roi{ii} = third_kernel_individual_roi{ii}{rr};
    end
    third_visualization_roi{rr} = K3_Visualization_Format_1213(third_kernel_this_roi, ...
        'dx_bank', dx_bank, 'dx_bank_plot', dx_bank_plot,'dt_vary_max',dt_vary_max,...
        'barUse', barUse,'mode', mode_use, 'plot_flag', false, varargin{:});
end


%% reorganize the data
n_bar_use_new = length(third_visualization_roi{rr});
third_visualization_roi_dx_bank_type_first = cell(n_bar_use_new ,1); % reorganize the
for qq = 1:1:n_bar_use_new
    third_visualization_roi_dx_bank_type_first{qq} = zeros([size(third_visualization_mean{qq}),nRoi]);
    for rr = 1:1:nRoi
        third_visualization_roi_dx_bank_type_first{qq}(:,:,rr) = third_visualization_roi{rr}{qq};
    end
end
%% calculate the standard error of mean. sem
third_visualization_sem =  cell(n_bar_use_new ,1);
for qq = 1:1:n_bar_use_new
    third_visualization_std_this_bar = std(third_visualization_roi_dx_bank_type_first{qq},1, 3);
    third_visualization_sem{qq} = third_visualization_std_this_bar/sqrt(nRoi);
end


%% do a ztest anyway.
% third_visualization_x_fixed_std =  cell(length(barUse),1); % useless.
third_visualization_h =  cell(n_bar_use_new,1);
third_visualization_p = cell(n_bar_use_new,1);
for qq = 1:1:n_bar_use_new
    [n_dt,n_dx] = size(third_visualization_mean{qq});
    %     third_visualization_x_fixed_std{qq} = zeros(n_dt, n_dx);
    third_visualization_h{qq} = zeros(n_dt, n_dx);
    third_visualization_p{qq} = zeros(n_dt, n_dx);
    for ii = 1:1:n_dt
        for jj = 1:1:n_dx
            %             third_visualization_x_fixed_std{qq}(ii,jj) = std(squeeze(third_visualization_x_fixed_roi{qq}(ii,jj,:)));
            [third_visualization_h{qq}(ii,jj),third_visualization_p{qq}(ii,jj)] = ...
                ttest(squeeze(third_visualization_roi_dx_bank_type_first{qq}(ii,jj,:)), 0, 'Alpha',p_thresh);
        end
    end
end
end