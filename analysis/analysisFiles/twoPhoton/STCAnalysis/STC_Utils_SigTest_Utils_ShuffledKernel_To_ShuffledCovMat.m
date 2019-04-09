function cov_mat_noise = STC_Utils_SigTest_Utils_ShuffledKernel_To_ShuffledCovMat(kernel,varargin)
% THIS ONE SHOULD BE KEPT. SOMEHOW, THIS WAY TO COMPUTE NOISE WOULD INDUCE
% SYMMETRIC BUT NOT COMPARABLE RESULT WITH COVARANCE MATRIX.
nMultiBars = 20;
n_noise = 1000; % should be large enough. 99.5 confidence interval? upper limit.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '=', num2str(varargin{ii + 1}),';'])
end

maxTau_squared = size(kernel{1},1);
maxTau = round(sqrt(maxTau_squared));
n_noise_extraction = length(kernel); % this should be calculated...
n_noise_total = n_noise_extraction * nMultiBars;
noiseKernel = cat(2, kernel{:});

n_kernel_use = (nMultiBars.^2 - nMultiBars)/2 + nMultiBars;
cov_mat_noise  = cell(n_noise,1);
for nn = 1:1:n_noise
    % first, construct a covariance matrix using noisykernel.
    kernel_use_this = noiseKernel(:,randperm(n_noise_total, n_kernel_use));
    % arrange it.
    cov_mat_noise_this = STC_Utils_EigenValueSigTest_Utils_NoiseKernelToNoiseCov(kernel_use_this,'maxTau', maxTau);
    cov_mat_noise{nn} = (cov_mat_noise_this + cov_mat_noise_this')/2;
end
end