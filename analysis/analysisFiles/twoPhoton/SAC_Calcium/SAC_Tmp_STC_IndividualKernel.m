%% 
function [cov_mat_eigenvector, cov_mat_without1o_eigenvector] = SAC_Tmp_STC_IndividualKernel(cov_mat, first_order_kernel, barUse)

f = 32.5;
maxTau = 10;
maxTau_Use =30;
nMultiBars = length(barUse);
cov_mat_sym = (cov_mat + cov_mat')/2;
cov_mat_sym_small = cov_mat_sym((barUse(1) - 1)* maxTau + 1: barUse(end)* maxTau, (barUse(1) - 1)* maxTau + 1: barUse(end)* maxTau);

first_kernel_small = first_order_kernel(:,barUse);

[cov_mat_eigenvector,cov_mat_without1o_eigenvector] = ...
            STC_Utils_EigenVectorAnalysisForCovMat_With1o(cov_mat_sym_small, first_kernel_small,...
            'f',f,'barUse', barUse, 'maxTau', maxTau, 'maxTau_Use', maxTau_Use,...
            'nMultiBars', nMultiBars,'genotype', 'SAC_calcium','bin_stim_flag', false);

end
