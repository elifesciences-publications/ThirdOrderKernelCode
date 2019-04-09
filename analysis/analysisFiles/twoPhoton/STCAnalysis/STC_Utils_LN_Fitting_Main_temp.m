%% LN model
function STC_Utils_LN_Fitting_Main_temp(cov_mat, first_kernel, resp, stim,varargin)
barUse = [];
maxTau = [];
maxTau_Use = [];
nMultiBars = [];
plotFlag = true;
setBarUseFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii}, '= varargin{', num2str(ii + 1),'};'])
end

cov_mat_sym = STC_Utils_SigTest_Utils_SymmetrizeCovMat(cov_mat,'average');
% half covmat
cov_mat_sym_small = quickViewCovMat_SelectBars(cov_mat_sym, barUse, maxTau, maxTau_Use ,'nMultiBars', nMultiBars, 'plotFlag', false);
[cov_mat_eigenvector_all, D] = eig(cov_mat_sym_small); cov_mat_eigenvector = zeros(maxTau_Use , length(barUse),2);

cov_mat_eigenvector(:,:,1) = reshape(cov_mat_eigenvector_all(:,1),[maxTau_Use , length(barUse)]);
cov_mat_eigenvector(:,:,2) = reshape(cov_mat_eigenvector_all(:,2),[maxTau_Use , length(barUse)]);

for ii = 1:1:2
    cov_mat_eigenvector(:,:,ii) = reshape(cov_mat_eigenvector_all(:,ii),[maxTau_Use , length(barUse)]);
    E = cov_mat_eigenvector(:,:,ii); F = first_kernel(1:maxTau_Use, barUse);
    corr_with_1o =  corr(E(:), F(:));
    if corr_with_1o<0
        cov_mat_eigenvector(:,:,ii) = - cov_mat_eigenvector(:,:,ii);
    end
end

%% there are points basically in every bin.
% second order kernel prediction
% if you select certain bars. the stim should be different here?
[predResp_2o, resp_LN_2o] = STC_Utils_PredResp_ARMA_SuperLong_Resp(resp - mean(resp),stim,1:length(resp), cov_mat_eigenvector, 'order',2, 'nOneBin', 30, 'nBin', [10,10], ...
    'setBarUseFlag', true, 'barUse', barUse, 'nMultiBars', nMultiBars, 'maxTau', maxTau_Use,'plot_flag', true);
subplot(5,5,24:25)
[predResp_1o, resp_LN_1o] = STC_Utils_PredResp_ARMA_SuperLong_Resp(resp - mean(resp),stim,1:length(resp), first_kernel,'order',1, 'nOneBin', 30, 'nBin', [10,10], ...
    'setBarUseFlag', true, 'barUse', barUse, 'nMultiBars', nMultiBars, 'maxTau', maxTau,'plot_flag', true);

%% first, ask about variance explained. not the first and second order kernel
% LN model or two LN model.



end
