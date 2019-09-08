function cov_mat_noise = STC_Utils_EigenValueSigTest_Utils_NoiseKernelToNoiseCov(kernel_use,varargin)
maxTau = 64;
nMultiBars = 20;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
%
a = ones(nMultiBars,nMultiBars);
a = tril(a,0);
n_kernel_eff = ((nMultiBars^2 - nMultiBars)/2 + nMultiBars);
a(a > 0) = 1: n_kernel_eff;
b = a + a'; % diagnol has been added twice
b(eye(nMultiBars)> 0) = b(eye(nMultiBars)> 0)/2;
c = b(:);

% first, change kernel_use into cell
kernel_use_cell = mat2cell(kernel_use, maxTau^2,ones(n_kernel_eff,1));
cov_mat_noise_cell = reshape(kernel_use_cell(c),nMultiBars,nMultiBars);
cov_mat_noise_cell = cellfun(@(A) reshape(A,[maxTau,maxTau]),cov_mat_noise_cell,'UniformOutput',false);

cov_mat_noise = cell2mat(cov_mat_noise_cell);
