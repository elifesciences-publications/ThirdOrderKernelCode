function  kernel_deconv = STC_Utils_DeconvSecondKernel(kernel, ca_psf, nsr)
half_length_diag_min = 2;
% you should deconv, and only use part of it!

% do deconvolution on the diagnal...one diag to another diag...
% you have to tailor your ca_psf as well....
[maxTau,maxTau,nMultiBars] = size(kernel);
kernel_deconv = zeros(size(kernel));
diagOffSet = [- maxTau + 1:1:maxTau - 1];

for ii = 1:1:maxTau * 2 - 1
    diag_ind = triu(true(maxTau,maxTau),diagOffSet(ii)) & tril(true(maxTau,maxTau),diagOffSet(ii));
    diag_val = kernel(diag_ind);
    
    % do it, it feels extremely interesting. on
    half_length_diag = floor(length(diag_val)/2);
    if half_length_diag >= half_length_diag_min % this is just a number...
        ind_cen_ca_psf = ceil(length(ca_psf)/2); % would always be center.
        ca_psf_half_used = min(half_length_diag - 1, ind_cen_ca_psf - 1);
        ca_psf_used = ca_psf(ind_cen_ca_psf - ca_psf_half_used: 1: ind_cen_ca_psf + ca_psf_half_used);
       
        diag_val_deconv = deconvwnr(diag_val, ca_psf_used, nsr);
    else
        diag_val_deconv = diag_val;
    end
    kernel_deconv(diag_ind) = diag_val_deconv;
end

end


% t = (0:1/stimHz:0.5 - 1/stimHz * 1)';
% t_rise = 0.005;
% t_decay = 0.3;
% ca_dy = (exp(-t/t_rise) - exp(-t/t_decay));
% ca_dy = ca_dy/(sum(ca_dy));
%
% ca_psf = [zeros(length(t) - 1,1); ca_dy];
% t_plot = -(length(t) - 1) * 1/ stimHz : 1/stimHz:max(t);