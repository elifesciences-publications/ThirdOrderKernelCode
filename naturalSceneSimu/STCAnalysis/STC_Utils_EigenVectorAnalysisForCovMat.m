function [V,D] = STC_Utils_EigenVectorAnalysisForCovMat(cov_mat, firstKernel,varargin)
%STC_Utils_EigenVectorAnalysisForCovMat(cov_mat, firstKernel,'plotFlag', true,'nMultiBars',20);
firstKernelStr = '1o Kernel';
typeStr = '';
MainName = 'EigenVectorOfCovarianceMatrix';
saveFigFlag = false;
plotFlag = false;
nMultiBars = 20;
genotype = 'T4T5';
f = 60; % 60Hz.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if ~exist('barUse', 'var')
    barUse = 1:nMultiBars;
end

maxTau = size(cov_mat,1)/nMultiBars;
[V,D] = eig(cov_mat);
%% Change the format here.
if plotFlag
    MakeFigure;
    subplot(3,2,1)
    % you have to remember the bar to use/
    quickViewOneKernel(firstKernel,1, 'genotype', genotype, 'f', f, 'colorbarFlag', false, 'barUse', barUse);
    title([typeStr, ' ', firstKernelStr]);
    
    subplot(3,2,2); % have more space.
    diagD = diag(D);
    plot(diag(D),'.');
    set(gca, 'XLim',[-10,length(D) + 10]); % get more space.
    % amplify the largest and the smallest in the end.
    hold on
    scatter([1:2],diagD(1:2),'r.');
    %     scatter([legnth(diagD),diagD(1:2)],'filled','r');
    title('eigenvalue of covariance matrix')
    
    
    for ii = 1:1:3
        E = reshape(V(:,ii),[maxTau, nMultiBars]);
        subplot(3,2,ii+ 2)
        % calculate the similarity with first order kernel
        corr_1o_eigvec = corr(firstKernel(:), E(:));
        if corr_1o_eigvec < 0
            E = -E;
            corr_1o_eigvec = - corr_1o_eigvec ;
        end
        quickViewOneKernel(E,1, 'genotype', genotype, 'f', f, 'colorbarFlag', false, 'barUse', barUse);
        title({sprintf('%d th eigenvectors, eigenvalue = %.3f', ii, diagD(ii)),sprintf('corr with 1o = %.3f',  corr_1o_eigvec)});
    end
    
    % only plot the first two significant eigenvectors...
    %
    %     for ii = 1:1:3
    %         E = V(:,end - ii + 1);
    %         subplot(3,3,ii + 3)
    %         quickViewOneKernel(reshape(E,[maxTau, nMultiBars]),1)
    %         title(sprintf('%d th eigenvector, %.3f', ii, diagD(end - ii + 1)));
    %         ConfAxis;
    %     end
    %    % also cac
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,typeStr ,'nFigSave',2,'fileType',{'fig','png'});
    end
end
end