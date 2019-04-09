function Analaysis_Function_Get_Mean_CovMat_Visualization(file_path_all, kernel_identifier, varargin)
cov_mat_noise_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
[cov_mat_mean, ~, ~] = Analaysis_Function_Get_Mean_CovMat(file_path_all, kernel_identifier, cov_mat_noise_flag); % half a minute to calculate this average. not too bad.
% you can do all kinds of analysis on the mean_cov_mat
% this should be a function ? think about it later.
typeStr = {'T4 Pro','T4 Reg','T5 Pro', 'T5 Reg'};
bar_plot = {[8:13],[8:13],[9:14],[7:12]};
nType = 4;
for tt = 1:1:nType
    MainName = [kernel_identifier.ROI_indenfication_method,'_',kernel_identifier.kernel_extraction_method,'_' typeStr{tt}];
    MakeFigure;
    kernel_param_second = kernel_path_management_utils_kernelstr_to_kernelparam({'second'}); maxTau = kernel_param_second.maxTau;
    quickViewCovMat_SelectBars(cov_mat_mean{tt},bar_plot{tt},maxTau, 32);
    
    set(gcf,'NumberTitle','off');
    set(gcf,'Name', MainName);
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,'cov_mat' ,'nFigSave',2,'fileType',{'fig','png'});
    end
    
    K2_CovarianceMatrix_Visualization( cov_mat_mean{tt},'MainName',MainName,'saveFigFlag',saveFigFlag)
end
end
