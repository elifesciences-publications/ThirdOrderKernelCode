function cov_mat_small_deconv_mat = STC_Utils_DeconvSecondKernel_FullCov_Small(cov_mat_this,ca_psf, nsr,maxTau_half,varargin)
nMultiBars = 20;
nMultiBars_Use = nMultiBars; % only use 6;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if mod(nMultiBars_Use,2) %
    error('expected to be even');
else
    barUse = 11 - nMultiBars_Use/2: 10 + nMultiBars_Use/2;
end
maxTau = size(cov_mat_this,1)/nMultiBars;

kernel_small_deconv = cell(nMultiBars_Use, nMultiBars_Use);

% first, you only need to compute half of it. not the full thing.
for jj = 1:1:nMultiBars_Use
    for ii = jj:1:nMultiBars_Use
        indi = (barUse(ii) - 1) * maxTau + 1:  barUse(ii) * maxTau;
        indj = (barUse(jj) - 1) * maxTau + 1:  barUse(jj) * maxTau;
        kernel2o = squeeze(cov_mat_this(indi,indj));
        kernel_deconv = STC_Utils_DeconvSecondKernel(kernel2o, ca_psf, nsr);
        kernel_small_deconv{ii, jj} = kernel_deconv(1:maxTau_half,1:maxTau_half);
    end
end

%% then put the other half.
for jj = 1:1:nMultiBars_Use
    for ii = 1:1:jj - 1
        kernel_small_deconv{ii, jj} = kernel_small_deconv{jj,ii}';
    end
end



%% good!
cov_mat_small_deconv_mat = cell2mat(kernel_small_deconv);

% cov_mat_small_deconv_mat = zeros(maxTau_half * nMultiBars, maxTau_half *
% nMultiBars);

end