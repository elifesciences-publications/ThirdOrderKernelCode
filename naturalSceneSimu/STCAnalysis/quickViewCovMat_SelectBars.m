function kernel_plot =  quickViewCovMat_SelectBars(cov_mat_this,bar_plot,maxTau, maxTau_small, varargin)
plotFlag = true;
nMultiBars = 20;
genotype = 'T4T5';
labelFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% bar_plot = [8:13];
% maxTau = 64;
% maxTau_half = 32;
kernel_small = cell(nMultiBars,nMultiBars);
for ii = 1:1:nMultiBars
    for jj = 1:1:nMultiBars
        indi = (ii - 1) * maxTau + 1: ii * maxTau;
        indj = (jj - 1) * maxTau + 1: jj * maxTau;
        kernel2o = squeeze(cov_mat_this(indi,indj));
        kernel_small{ii, jj} = kernel2o(1:maxTau_small,1:maxTau_small);
    end
end
kernel_plot = cell2mat(kernel_small(bar_plot,bar_plot));
if plotFlag
    quickViewCovMat(kernel_plot,'nMultiBars',length(bar_plot), 'barUse', bar_plot, 'genotype', genotype,'labelFlag', labelFlag, 'bin_stim_flag',bin_stim_flag');
%     ConfAxis
end