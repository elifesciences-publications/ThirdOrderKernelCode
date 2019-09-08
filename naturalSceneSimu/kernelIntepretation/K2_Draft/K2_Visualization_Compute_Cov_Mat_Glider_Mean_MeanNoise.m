function [cov_mat_glider_aligned,  cov_mat_glider_aligned_noise] ...
    = K2_Visualization_Compute_Cov_Mat_Glider_Mean_MeanNoise(cov_mat_aligned, cov_mat_noise_aligned, varargin)

n_noise = length(cov_mat_noise_aligned); % cov_mat_noise will be a cell array.
cov_mat_glider_aligned = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat_aligned, varargin{:});
cov_mat_glider_aligned_noise = zeros([size(cov_mat_glider_aligned),n_noise]);

% this one takes some time.
for nn = 1:1:n_noise
    cov_mat_glider_aligned_noise(:,:,:,nn) = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat_noise_aligned{nn}, varargin{:});
end

end