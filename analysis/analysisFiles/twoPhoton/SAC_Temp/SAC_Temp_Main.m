function SAC_Temp_Main(filename, fileID_name, bin_stim_flag, down_sample_response_flag, varargin)
% This is an overarching function, everything should go through this? not
% really..
[resp, stim, f] = SAC_Temp_Preprocessing_Stim_Resp(filename,bin_stim_flag, down_sample_response_flag);
nMultiBars = size(stim, 2);
maxTau = ceil(500/(1000/f));
maxTau_Use = ceil(maxTau * 3/4);
barUse = 1 : nMultiBars;
saveFigFlag = false;
sig_test_flag = false;
genotype = 'SAC';
for ii = 1:2:length(varargin)
    eval([varargin{ii}, '= varargin{', num2str(ii + 1),'};'])
end
%% extract first order kernel
first_kernel = Main_KernelExtraction_ReverseCorr({resp}, stim, {1:length(resp)}, ...
    'order', 1, 'donoise', 0, 'maxTau', maxTau);
first_kernel = first_kernel{1};
first_kernel_smaller = first_kernel(1: maxTau_Use ,  barUse);
MakeFigure;
quickViewOneKernel(first_kernel,1, 'genotype', genotype , 'f', f, 'bin_stim_flag', bin_stim_flag, 'colorbarFlag', false);
if saveFigFlag
    MySaveFig_Juyue(gcf,[fileID_name],['1o'],'nFigSave',2,'fileType',{'png','fig'});
end
%% save or not?
%% extract second order kernel
% cov_mat_noise = cell(100,1);
if sig_test_flag
    cov_mat_noise = Main_KernelExtraction_ReverseCorr({resp}, stim, {1:length(resp)}, ...
        'order', 2, 'donoise', 1, 'maxTau', maxTau);
else
    cov_mat_noise = cell(100,1);
end
cov_mat = Main_KernelExtraction_ReverseCorr({resp}, stim, {1:length(resp)}, ...
    'order', 2, 'donoise', 0, 'maxTau', maxTau);
cov_mat = cov_mat{1};

% This could plot the function, do the significant test,

cov_mat_sym = STC_Utils_SigTest_Utils_SymmetrizeCovMat(cov_mat,'upper_half');
% half covmat
MakeFigure;
cov_mat_sym_small = quickViewCovMat_SelectBars(cov_mat_sym, barUse, maxTau, maxTau_Use ,'nMultiBars', nMultiBars,...
    'plotFlag', true, 'bin_stim_flag', bin_stim_flag, 'genotype', 'SAC', 'labelFlag', true);
if saveFigFlag
    MySaveFig_Juyue(gcf,[fileID_name],['cov_mat_short'],'nFigSave',2,'fileType',{'png','fig'});
end


% STC_Utils_EigenVectorAnalysisForCovMat(cov_mat_sym_small, first_kernel_smaller,'nMultiBars', length(barUse), 'genotype',  genotype, 'f', f, 'barUse', barUse, 'plotFlag', true,'bin_stim_flag', bin_stim_flag);
% if saveFigFlag
%     MySaveFig_Juyue(gcf,[fileID_name],['stc_short'],'nFigSave',2,'fileType',{'png','fig'});
% end

[cov_mat_eigenvector,cov_mat_without1o_eigenvector] = STC_Utils_EigenVectorAnalysisForCovMat_With1o(cov_mat_sym_small, first_kernel_smaller,'f',f,'barUse', barUse, 'maxTau', maxTau, 'maxTau_Use', maxTau_Use, 'nMultiBars', nMultiBars,'genotype',  genotype,'bin_stim_flag', bin_stim_flag);
if saveFigFlag
    MySaveFig_Juyue(gcf,[fileID_name],['stc_short'],'nFigSave',2,'fileType',{'png','fig'});
end

%% LN prediction
[predResp_2o, resp_LN_2o] = STC_Utils_PredResp_ARMA_SuperLong_Resp(resp - mean(resp),stim,1:length(resp), cov_mat_eigenvector, 'order',2, 'nOneBin', 30, 'nBin', [10,10], ...
    'setBarUseFlag', true, 'barUse', barUse, 'nMultiBars', nMultiBars, 'maxTau', maxTau_Use,'plot_flag', true);
subplot(5,5,[1,2,3,6,7,8,11,12,13,16,17,18]);
title('first component + second component');
subplot(5,5,24:25)
[predResp_1o, resp_LN_1o] = STC_Utils_PredResp_ARMA_SuperLong_Resp(resp - mean(resp),stim,1:length(resp), first_kernel,'order',1, 'nOneBin', 30, 'nBin', [10,10], ...
    'setBarUseFlag', true, 'barUse', barUse, 'nMultiBars', nMultiBars, 'maxTau', maxTau,'plot_flag', true);
if saveFigFlag
    MySaveFig_Juyue(gcf,[fileID_name],['LN_short'],'nFigSave',2,'fileType',{'png','fig'});
end
%% LN prediction on the the
[predResp_2o, resp_LN_2o] = STC_Utils_PredResp_ARMA_SuperLong_Resp(resp - mean(resp),stim,1:length(resp), cov_mat_without1o_eigenvector, 'order',2, 'nOneBin', 30, 'nBin', [10,10], ...
    'setBarUseFlag', true, 'barUse', barUse, 'nMultiBars', nMultiBars, 'maxTau', maxTau_Use,'plot_flag', true);
subplot(5,5,[1,2,3,6,7,8,11,12,13,16,17,18]);
title('1o Kernel + first component');
ylabel('1^{st} component')
subplot(5,5,[21,22,23])
xlabel('1o Kernel');
if saveFigFlag
    MySaveFig_Juyue(gcf,[fileID_name],['LN_1o'],'nFigSave',2,'fileType',{'png','fig'});
end
% STC_Utils_SigTest_Main(cov_mat, cov_mat_noise, first_kernel, 'f',f,...
%     'barUse', barUse, 'maxTau', maxTau, 'maxTau_Use', maxTau_Use, 'nMultiBars', nMultiBars, 'bin_stim_flag',bin_stim_flag,...
%     'fileID_name', fileID_name, 'sig_test_flag', sig_test_flag, 'saveFigFlag',saveFigFlag, 'genotype', genotype);

%% prediction. the original one... use smaller cov_mat...
% STC_Utils_LN_Fitting_Main_temp(cov_mat, first_kernel, resp, stim, 'barUse', barUse, 'maxTau', maxTau, 'maxTau_Use', maxTau_Use, 'nMultiBars', nMultiBars,...
%     'setBarUseFlag', true, 'plotFlag', true);
%% do not compute variance explained and unexplained for now.
end