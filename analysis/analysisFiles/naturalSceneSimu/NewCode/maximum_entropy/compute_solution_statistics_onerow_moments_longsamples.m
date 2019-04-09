function  data = compute_solution_statistics_onerow_moments_longsamples(med, n_highest_moments,varargin)
%% get all data possible
N = med.N;
K = med.K;
gray_value = med.gray_value;
x_solved = med.x_solved;
zero_mean_flag = 1;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

[~,~, time_series]  ...
    = MaxEntDist_ConsMoments_Utils_Sampling_OneScene(x_solved, gray_value, N, K, 1, 'plot_flag',0,'n_highest_moments',n_highest_moments,...
    'n_sample', 10000);
data_sample_short_ori = compute_image_statistics_onerow_moments_correlation(time_series','prefixed_discretization_flag', 1,...
    'upsample_flag',0,'N', N, 'K', 1, 'med',med,'zero_mean_flag',zero_mean_flag);


data = data_sample_short_ori(1:4);
end
