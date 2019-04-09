function [V,D] = STC_Utils_EigenVectorAnalysisForCovMat_CompareEigenWithFirst(cov_mat, firstKernel,varargin)
%STC_Utils_EigenVectorAnalysisForCovMat(cov_mat, firstKernel,'plotFlag', true,'nMultiBars',20);
firstKernelStr = '1o Kernel';
typeStr = '';
MainName = 'EigenVectorOfCovarianceMatrix';
saveFigFlag = false;
plotFlag = false;
nMultiBars = 20;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

maxTau = size(cov_mat,1)/nMultiBars;
[V,D] = eig(cov_mat);
%%
if plotFlag
    MakeFigure;
    subplot(3,3,1)
    quickViewOneKernel(firstKernel,1);
    title([typeStr, ' ', firstKernelStr]);
    subplot(3,3,2);
    % first order kernel. where can you find them?
    diagD = diag(D);
    plot(diag(D),'.');
    % amplify the largest? in the end?
    title('eigenvalue of covariance matrix')
    
    % only plot the first two...
    
    E1 = reshape(V(:, end),[maxTau, nMultiBars]);
    subplot(3,3,4);
    quickViewOneKernel(E1,1)
    title(sprintf('%d th eigenvector, %.3f', 1, diagD(end - 1 + 1)));
    subplot(3,3,5);
    % you have to make sure that the firstKernel and E1 has power.....
    rescale_firstKernel = firstKernel * std(E1(:))/std(firstKernel(:));
    quickViewOneKernel(E1 - rescale_firstKernel,1)
    title(sprintf('%d th eigenvector - first kernel', 1));
    
    subplot(3,3,6);
    quickViewOneKernel(-E1 -  rescale_firstKernel,1)
    title(sprintf('-(%d th eigenvector) - first kernel', 1));
    
    E2 = reshape(V(:, end - 1),[maxTau, nMultiBars]);
    rescale_firstKernel = firstKernel * std(E2(:))/std(firstKernel(:));
    subplot(3,3,7);
    quickViewOneKernel(E2,1)
    title(sprintf('%d th eigenvector, %.3f', 2, diagD(end - 2 + 1)));
    
    subplot(3,3,8);
    quickViewOneKernel(E2 - rescale_firstKernel,1)
    title(sprintf('%d th eigenvector - first kernel', 2));
    
    subplot(3,3,9);
    quickViewOneKernel(-E2 - rescale_firstKernel,1)
    title(sprintf('-(%d th eigenvector) - first kernel', 2));
    
    
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,typeStr ,'nFigSave',2,'fileType',{'fig','png'});
    end
end
end