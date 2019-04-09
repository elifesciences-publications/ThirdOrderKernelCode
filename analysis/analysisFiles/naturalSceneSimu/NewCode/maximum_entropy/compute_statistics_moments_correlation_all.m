function data = compute_statistics_moments_correlation_all(image_path, mode, varargin)
solution_path = [];
n_highest_moments = 3;
K = 4;
N = 8;
symmetrize_flag = 0;
K_measure = 31;
lower_bound_flag = 0;
prefixed_discretization_flag = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

S = GetSystemConfiguration;
image_data_path = fullfile(S.natural_scene_simulation_path,'image',image_path, 'FWHM25');
image_info = dir(fullfile(image_data_path, '*.mat'));
n_image = length(image_info);
n_ver = 251;

if strcmp(mode, 'pairwise_correlation')
    data = zeros(K_measure, n_ver, n_image);
else
    data = zeros(4 + K - 1, n_ver, n_image);
end
%%
tic
for ii = 1:1:n_image
    I = load(fullfile(image_data_path, image_info(ii).name));
    if prefixed_discretization_flag
        Imed = load(fullfile(S.natural_scene_simulation_path,'image',solution_path, 'FWHM25',  image_info(ii).name));
    end
    if strcmp(mode, 'syn_image')
        image_solution_full_path = fullfile(S.natural_scene_simulation_path,'image',solution_path , 'FWHM25');
        syn_med = load(fullfile(image_solution_full_path, image_info(ii).name));
    end
    for jj = 1:1:n_ver
        switch mode
            case 'image'
                if prefixed_discretization_flag
                   med = Imed.med(jj);
                else
                    med = [];
                end
                x = I.I(jj, :);
                data(:, jj,ii) = compute_image_statistics_onerow_moments_correlation(x, 'N', N,...
                    'symmetrize_flag',symmetrize_flag,'zero_mean_flag',zero_mean_flag,'lower_bound_flag',lower_bound_flag,...
                    'prefixed_discretization_flag',prefixed_discretization_flag, 'med', med, 'upsample_flag', 0);
            case 'solution'
                med = I.med(jj);
                data(:, jj,ii) = compute_solution_statistics_onerow_moments_correlation(med, n_highest_moments);
            case 'syn_image'
                % you need to load the corresponding image....
                med = syn_med.med(jj);
                x = I.I(jj,:);
                % This does not work as expected...
                data(:, jj,ii) = compute_image_statistics_onerow_moments_correlation(x, 'prefixed_discretization_flag', 1, 'med', med,...,
                    'symmetrize_flag',symmetrize_flag,'zero_mean_flag',zero_mean_flag,'lower_bound_flag',lower_bound_flag);
            case 'pairwise_correlation'
                x = I.I(jj, :);
                [acf, lag] = autocorr(x, K_measure);
                data(:, jj,ii) = acf(2:end);
            case 'long_samples'
                med = I.med(jj);
                data(:, jj,ii) = compute_solution_statistics_onerow_moments_longsamples(med, n_highest_moments,'zero_mean_flag',zero_mean_flag);

                
        end
    end
end
toc
end