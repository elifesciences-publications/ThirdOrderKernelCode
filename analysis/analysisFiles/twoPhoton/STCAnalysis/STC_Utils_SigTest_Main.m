function STC_Utils_SigTest_Main(cov_mat, cov_mat_noise, first_kernel, varargin);
barUse = [1:10];
maxTau = 500;
maxTau_Use = 350;
saveFigFlag = false;
nMultiBars = 10;
fileID_name = [];
roi_this = 1;
sig_test_flag = false;
f = 1000;
genotype = 'SAC';
bin_stim_flag = 'false';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


%% get data
n_noise = length(cov_mat_noise);
%% look at the kernel
MakeFigure;
quickViewCovMat_SelectBars(cov_mat, barUse, maxTau, maxTau_Use ,'plotFlag', true, 'nMultiBars', nMultiBars, 'bin_stim_flag',bin_stim_flag, 'genotype', 'SAC', 'labelFlag', true);
if saveFigFlag
    MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['cov_mat_short'],'nFigSave',2,'fileType',{'png','fig'});
end

% MakeFigure;
% quickViewCovMat(cov_mat,'nMultiBars', nMultiBars, 'bin_stim_flag',bin_stim_flag, 'genotype', 'SAC', 'labelFlag', true);
% if saveFigFlag
%     MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['cov_mat_full'],'nFigSave',2,'fileType',{'png','fig'});
% end


%% STC analysis starts
% full covmat analyze cleaner data. 
cov_mat_sym = STC_Utils_SigTest_Utils_SymmetrizeCovMat(cov_mat,'upper_half');
% STC_Utils_EigenVectorAnalysisForCovMat(cov_mat_sym, first_kernel,'nMultiBars', nMultiBars, 'genotype',  genotype, 'f', f, 'plotFlag', true);
% if saveFigFlag
%     MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_full'],'nFigSave',2,'fileType',{'png','fig'});
% end

% half covmat
cov_mat_sym_small = quickViewCovMat_SelectBars(cov_mat_sym, barUse, maxTau, maxTau_Use ,'nMultiBars', nMultiBars, 'plotFlag', false);
STC_Utils_EigenVectorAnalysisForCovMat(cov_mat_sym_small, first_kernel(1: maxTau_Use ,  barUse),'nMultiBars', length(barUse), 'genotype',  genotype, 'f', f, 'barUse', barUse, 'plotFlag', true);
if saveFigFlag
    MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_short'],'nFigSave',2,'fileType',{'png','fig'});
end
%
%     STC_Utils_EigenVectorAnalysisForCovMat_CompareEigenWithFirst( cov_mat_sym_small ,  first_kernel(1: maxTau_Use ,  barUse ),'plotFlag',true, 'nMultiBars', length(barUse));
%     if saveFigFlag
%         MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_short_compare_with_first'],'nFigSave',2,'fileType',{'png','fig'});
%     end
if sig_test_flag
    cov_mat_noise_sym_small = cell(n_noise, 1);
    for nn = 1:1:n_noise
        cov_mat_noise_sym = STC_Utils_SigTest_Utils_SymmetrizeCovMat(cov_mat_noise{nn},'upper_half');
        cov_mat_noise_sym_small{nn} = quickViewCovMat_SelectBars(cov_mat_noise_sym, barUse, maxTau, maxTau_Use ,'nMultiBars', nMultiBars, 'plotFlag', false);
    end
    
    STC_Utils_SigTest_Utils_NestedSigTest(cov_mat_sym_small,cov_mat_noise_sym_small, 'n_nested_max',1, ...
        'saveFigFlag', saveFigFlag, 'MainName', fileID_name); % within the noise.
   
end
%% LN fitting.

% [cov_mat_eigenvector_all,D] = eig(cov_mat_sym_small); cov_mat_eigenvector = zeros(maxTau_Use , length(barUse),2);
% For this neuron, it is the first two
% for ii = 1:1:2
%     cov_mat_eigenvector(:,:,ii) = reshape(cov_mat_eigenvector_all(:,end - ii + 1),[maxTau_Use , length(barUse)]);
% end
% 
% for ii = 1:1:2
%     cov_mat_eigenvector(:,:,ii) = reshape(cov_mat_eigenvector_all(:,ii),[maxTau_Use , length(barUse)]);
% end
% 
% STC_Utils_PredResp_ARMA(flickSave.respData,flickSave.stimData, flickSave.stimIndexed, cov_mat_eigenvector, ...
%     'nMultiBars', length(barUse), 'barUse',barUse, 'maxTau', maxTau_Use, 'edge_distribution', 'histeq','nOneBin',30,'nBin', [10,10]);
% if saveFigFlag
%     MySaveFig_Juyue(gcf,[fileID_name,'#',num2str(roi_this)],['stc_ln'],'nFigSave',2,'fileType',{'png','fig'});
% end
% close all
end