function [ks, kr] = kernel_extraction_ARMA_ReverseCorrelation(respData,stimData,stimIndexes,varargin)

maxTau = 32; % small guy.. % shuffle?
order = 2;
nMultiBars = 20; % hard coded it. use all of it.
dx = 1;
alpha = 0.71; % do a reverse correlation, you need
test_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% tic
% % you do not have to compute this respData.
% [OLSMat] = tp_Compute_OLSMat(respData,stimData,stimIndexes,'maxTau',maxTau,'order',order,'arma_flag',true,'maxTau_r',1,'dx',dx);
% toc
%%
% do these for all respData_ARMA for all
for rr = 1:1:length(respData_ARMA)
    respData_ARMA{rr} = respData{rr} - alpha * [0;respData{rr}(1:end - 1)];
end
kernels_arma_reverse = tp_kernels_ReverseCorrGPU(respData_ARMA,stimIndexes,stimData,'order',order,'maxTau',maxTau);
% second order kernel... went over several dx and x
kernels_arma_reverse = tp_kernels_ReverseCorrGPU(respData_ARMA,stimIndexes,stimData,'order',order,'maxTau',maxTau);


%% very interesting. how about the OLS directly?
if test_flag
    if order == 1
        kernels_reverse = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimData,'order',1,'maxTau',maxTau);
        [kernels_arma_ols,kr] = kernel_extraction_ARMA_draft(respData,stimData,stimIndexes,'maxTau',maxTau,'order',1);
        MakeFigure;
        subplot(2,2,1)
        quickViewOneKernel(kernels_arma_reverse,1);
        title('arma reverse correlation');ConfAxis
        subplot(2,2,2)
        ConfAxis
        quickViewOneKernel(kernels_arma_ols,1)
        title('arma ols'); ConfAxis
        
        subplot(2,2,3)
        quickViewOneKernel(kernels_reverse,1)
        title('reverse correlation');ConfAxis
        
        subplot(2,2,4);
        quickViewOneKernel(kernels_arma_reverse - kernels_arma_ols,1);
        title('arma reverse correlation -  arma ols');ConfAxis
    end
end
% give it a try, and compare these two method.
end