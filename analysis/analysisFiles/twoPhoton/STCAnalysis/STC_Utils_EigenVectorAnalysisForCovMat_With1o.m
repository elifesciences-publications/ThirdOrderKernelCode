function [cov_mat_eigenvector,cov_mat_without1o_eigenvector] = STC_Utils_EigenVectorAnalysisForCovMat_With1o(cov_mat, first_kernel,varargin)
%STC_Utils_EigenVectorAnalysisForCovMat(cov_mat, first_kernel,'plotFlag', true,'nMultiBars',20);
first_kernelStr = '1o Kernel';
typeStr = '';
MainName = 'EigenVectorOfCovarianceMatrix';
saveFigFlag = false;
plotFlag = true;
nMultiBars = 20;
genotype = 'T4T5';
f = 60; % 60Hz.
bin_stim_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if ~exist('barUse', 'var')
    barUse = 1:nMultiBars;
end
maxTau = size(cov_mat,1)/nMultiBars;

%% project the first order kernel out.
% first, organize the original kernel.
[cov_mat_eigenvector_all,cov_mat_eigenvalue_all] = eig(cov_mat);
% first two eigenvectors.
cov_mat_eigenvector = zeros(maxTau , length(barUse),2); corr_1o = zeros(2,1);
cov_mat_eigenvector(:,:,1) = reshape(cov_mat_eigenvector_all(:,1),[maxTau, length(barUse)]);
[cov_mat_eigenvector(:,:,1), corr_1o(1)] = ChangeEigenvectorsDirection(first_kernel, cov_mat_eigenvector(:,:,1));
cov_mat_eigenvector(:,:,2) = reshape(cov_mat_eigenvector_all(:,2),[maxTau, length(barUse)]);
[cov_mat_eigenvector(:,:,2), corr_1o(2)] = ChangeEigenvectorsDirection(first_kernel, cov_mat_eigenvector(:,:,2));


%% Project out eigenvectors
cov_mat_without_1o = STC_Utils_ProjectOutOneDirection(cov_mat, first_kernel);
[cov_mat_without1o_eigenvector_all, cov_mat_without1o_eigenvalue_all] = eig(cov_mat_without_1o);
cov_mat_without1o_eigenvector = zeros(maxTau , length(barUse),2); corr_1o_without_1o = zeros(2,1);
normalize_first_kernel = first_kernel/sqrt(first_kernel(:)' * first_kernel(:));
cov_mat_without1o_eigenvector(:,:,1) = normalize_first_kernel; % normalize the maginitude how?
corr_1o_without_1o(1) = 1;
cov_mat_without1o_eigenvector(:,:,2) = reshape(cov_mat_without1o_eigenvector_all(:,1),[maxTau, length(barUse)]);
[cov_mat_without1o_eigenvector(:,:,2), corr_1o_without_1o(2)] = ChangeEigenvectorsDirection(first_kernel, cov_mat_without1o_eigenvector(:,:,2));

%% Change the format here.
if plotFlag
    %
    MakeFigure;
    
    PlotEigenvectorsAndEigenValues(cov_mat_eigenvector, cov_mat_eigenvalue_all, corr_1o, [1,2,3], ...
        'barUse',barUse, 'bin_stim_flag', bin_stim_flag, 'genotype',genotype);
    PlotEigenvectorsAndEigenValues(cov_mat_without1o_eigenvector, cov_mat_without1o_eigenvalue_all, corr_1o_without_1o, [4,5,6], ...,
        'is_1o_projected_out_flag', true,'barUse',barUse, 'bin_stim_flag',bin_stim_flag, 'genotype',genotype);
    
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,typeStr ,'nFigSave',2,'fileType',{'fig','png'});
    end
end
end

function PlotEigenvectorsAndEigenValues(cov_mat_eigenvector, cov_mat_eigenvalue_all, corr_1o,subplot_number, varargin)
barUse = [];
genotype = 'SAC';
f = 60; % 60Hz.
bin_stim_flag = false;
is_1o_projected_out_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
diagD = diag(cov_mat_eigenvalue_all);
for ii = 1:1:2
    subplot(2,3,subplot_number(ii))
    E = cov_mat_eigenvector(:,:,ii);
    quickViewOneKernel(E,1, 'genotype', genotype, 'f', f, 'colorbarFlag', false, 'barUse', barUse, 'bin_stim_flag', bin_stim_flag, 'genotype',genotype);
    if ~is_1o_projected_out_flag
        title({sprintf('%d th eigenvectors, eigenvalue = %.3f', ii, diagD(ii)),sprintf('corr with 1o = %.3f',  corr_1o(ii))});
    else
        if ii == 1
            title('1o kernel');
        else
            title({sprintf('%d th eigenvectors, eigenvalue = %.3f', 1, diagD(1)),sprintf('corr with 1o = %.3f',  corr_1o(ii))});
        end
    end
end

subplot(2,3,subplot_number(3)); % have more space.
plot(diagD,'.');
set(gca, 'XLim',[-10,length(cov_mat_eigenvalue_all) + 10]); % get more space.
% amplify the largest and the smallest in the end.
hold on
if ~is_1o_projected_out_flag
    scatter([1:2],diagD(1:2),'r.');
else
    scatter(1,diagD(1),'r.');
    
end
title('eigenvalue of covariance matrix')
end

function [E, corr_1o_eigvec] = ChangeEigenvectorsDirection(first_kernel,E)
corr_1o_eigvec = corr(first_kernel(:), E(:));
if corr_1o_eigvec < 0
    E = -E;
    corr_1o_eigvec = - corr_1o_eigvec;
end
end