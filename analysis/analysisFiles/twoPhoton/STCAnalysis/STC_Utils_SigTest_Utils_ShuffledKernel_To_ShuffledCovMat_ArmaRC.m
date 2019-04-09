function cov_mat_noise = STC_Utils_SigTest_Utils_ShuffledKernel_To_ShuffledCovMat_ArmaRC(kernel,varargin)
nMultiBars = 20;
n_noise = 1000; % should be large enough. 99.5 confidence interval? upper limit.
symmetrize_method = 'flip';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '=', num2str(varargin{ii + 1}),';'])
end

kernel_noise_full = cell(n_noise,1);
cov_mat_noise = cell(n_noise, 1);
for nn = 1:1:n_noise
    for qq = 1:nMultiBars
        kernel_noise_full{nn}{qq} = kernel{qq}(:,nn,:); % THIS IS THE FORMAT YOU ARE USING. KERNEL{qq}(maxTau^2, numberOfshuffledKernel, nMultibars/)
    end
    cov_mat_noise{nn} = STC_Utils_SecondKernelToCovMat(kernel_noise_full{nn});
 end

end