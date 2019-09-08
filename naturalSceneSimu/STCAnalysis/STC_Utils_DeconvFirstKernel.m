function  kernel_deconv = STC_Utils_DeconvFirstKernel(kernel, ca_psf, nsr)
[maxTau,nMultiBars] = size(kernel);
kernel_deconv = zeros(size(kernel));
for qq = 1:1:nMultiBars
    kernel_deconv(:,qq) = deconvwnr(kernel(:,qq),ca_psf,nsr);
end