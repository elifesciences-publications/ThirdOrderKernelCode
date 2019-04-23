function AppendixFigure1BC_induced_skewness()
solve_med_flag = 1;

%% arguments.
contrast_upper_bound_bank = [0.5:0.5:2.5];
contrast_lower_bound_bank = [-1:0.1:-0.2]; %%

N = 512;
n = length(contrast_upper_bound_bank);
m = length(contrast_lower_bound_bank);
gray_value_bank = cell(n * m, 1);
for ii = 1:1:n
    for jj = 1:1:m
        idx = sub2ind([n, m], ii,jj);
        contrast_upper_bound = contrast_upper_bound_bank(ii);
        contrast_lower_bound = contrast_upper_bound * contrast_lower_bound_bank(jj);
        gray_value_bank{idx} = linspace(contrast_lower_bound, contrast_upper_bound, N)';
    end
end

% other values.
K = 1;
n_highest_moments = 2;
plot_flag = 0;
mean_value = 0;
variance_value = 0.1;
cov_true = zeros( (K^2- K)/2, 1);

%% solving the function.
med = cell(n * m, 1);
rng(1)
x_start_initial =  randn(K * n_highest_moments +  (K^2 - K)/2 + 1, 1) * 0.01;

if solve_med_flag
    tic
    for ii = 1:1:n * m
        gray_value = gray_value_bank{ii};
        N = length(gray_value);
        mu_true = varskew2moments(mean_value , variance_value, 0);
        mu_true = mu_true(1:2);
        %%
        [x_solved, f_val, solved_flag, time_nonlinear] = MaxEntDis_ConsMoments_MinimizePotential_Utils_Main...
            (mu_true, cov_true, gray_value, N, K, 'plot_flag', plot_flag,'x_start_initial', x_start_initial,'n_highest_moments',n_highest_moments);
        
        med{ii}.gray_value = gray_value;
        med{ii}.resolution_n_pixel = [];
        med{ii}.correlation_true = [];
        med{ii}.cov_true = cov_true;
        med{ii}.mu_true = mu_true;
        med{ii}.x_solved = x_solved;
        med{ii}.N = N;
        med{ii}.K = K;
        med{ii}.solved_flag = solved_flag;
        med{ii}.f_val = f_val;
        med{ii}.time = time_nonlinear;
    end
    toc
end
%% plotting.

solved_statistics = zeros(4, n, m);
solve_probability = cell(n, m);

for ii = 1:1:n
    for jj = 1:1:m
        
        idx = sub2ind([n, m], ii,jj);
        x_solved = med{idx}.x_solved;
        gray_value = med{idx}.gray_value; gray_value = gray_value(:);
        N = med{idx}.N;
        [~, ~, p_i, ~] = MaxEntDis_ConsMoments_Utils_PlotResult(x_solved, gray_value, [], [], n_highest_moments, N, K,'plot_flag',false);
        p_1 = mean(p_i,2);
        mean_distribution = dot(p_1, gray_value);
        variance_distribution = variance_p(p_1, gray_value);
        skewness_distribution = skewness_p(p_1, gray_value);
        kurtosis_distribution = kurtosis_p(p_1, gray_value);
        
        solved_statistics(:, ii, jj) = [mean_distribution;variance_distribution;skewness_distribution;kurtosis_distribution];
        solve_probability{ii, jj} = p_1;
    end
end
color_bank_range = brewermap(10, 'Spectral'); % Could you use spectral??
for ii = [3]
    MakeFigure;
    subplot(2,2,1)
    hold on
    for jj = 1:1:m
        gray_value = med{sub2ind([n, m], ii, jj)}.gray_value; gray_value = gray_value(:);
        bin_size = mean(diff(gray_value));
        plot(gray_value, solve_probability{ii, jj}/bin_size, 'color', color_bank_range(jj,:));
        h1 = plot([min(gray_value), min(gray_value)], get(gca, 'YLim'), '--', 'color', color_bank_range(jj,:)); h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
        h2 = plot([max(gray_value), max(gray_value)], get(gca, 'YLim'), '--', 'color', color_bank_range(jj,:));   h2.Annotation.LegendInformation.IconDisplayStyle = 'off';
        xlabel('contrast');
        ylabel('probability density');
        ConfAxis('LineWidth', 1.5);
    end
    
%     set(gca, 'YTick',prob_y_tick_density);
    title(['Change c_{min}/c_{max}']);
    legend_h = legend(num2str(contrast_lower_bound_bank(:),3));
    legend_h.Box = 'off';
    
    
    
    subplot(2,2,2); % skewness change with lower bound.
    plot(contrast_lower_bound_bank, squeeze(solved_statistics(3,ii,:)), 'k.-');
    xlabel('c_{min}/c_{max}');
    ylabel('skewness of MED');
    title(['variance: 0.1']);
    all_skewness = solved_statistics(3, ii,:);
    set(gca, 'YLim', [0,max(all_skewness(:)) * 1.5]);
    ConfAxis('LineWidth',2);
    
end
% 
% %%
% MakeFigure;
% subplot(2,2,1);
% imagesc(contrast_lower_bound_bank, contrast_upper_bound_bank, squeeze(solved_statistics(3, :, :)));
% ylabel('c_{max}');
% xlabel('c_{min}/c_{max}');
% set(gca,'YDir','normal');
% colorbar
% colormap('gray');
% title('skewness of MED');
% ConfAxis();
% box on
% MySaveFig_Juyue(gcf,'MED_SkewVSCont', 'Summary', 'nFigSave',2,'fileType',{'png','fig'});

