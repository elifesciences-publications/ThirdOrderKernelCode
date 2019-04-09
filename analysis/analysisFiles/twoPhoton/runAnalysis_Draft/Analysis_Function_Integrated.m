function Analysis_Function_Integrated(file_path_all,varargin)
kernel_extraction_method = 'ARMA_RC'; % you should think about it.
RoiIdentificationMethod = 'HHCA';
cross_validation_flag = false;
saveFigFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% kernel info
kernel_identifier.ROI_indenfication_method = RoiIdentificationMethod;
kernel_identifier.kernel_extraction_method = kernel_extraction_method;
kernel_identifier.cross_validation_flag    = cross_validation_flag;

for ff = 1:1:length(file_path_all)
    file_path = file_path_all{ff};
    
    %     Analysis_Function_Simulation_STC(file_path, kernel_identifier,'saveFigFlag', saveFigFlag)
    try
        Analysis_Function_IndividualFly_Plot_IndividualRoi_Draft(file_path, kernel_identifier,'saveFigFlag',true)
    catch
    end
end
% tic
% [first_kernel, first_kernel_mean] = Analaysis_Function_Get_Mean(file_path_all, kernel_identifier, 'first');
% save('averagedfirstkernel','first_kernel','first_kernel_mean','kernel_identifier','-v7.3');
%
% % this would work...
% [cov_mat, cov_mat_mean] = Analaysis_Function_Get_Mean(file_path_all, kernel_identifier, 'second');
% save('averagedsecondkernel','cov_mat','cov_mat_mean','kernel_identifier','-v7.3');
%
%
% [cov_mat_noise, cov_mat_noise_mean] = Analaysis_Function_Get_Mean(file_path_all, kernel_identifier, 'second_noise');
% save('averagedsecondkernel_noise','cov_mat_noise','cov_mat_noise_mean','kernel_identifier','-v7.3');


% MakeFigure;
% for tt = 1:1:4
%     subplot(2,2,tt)
%     quickViewOneKernel(first_kernel_mean{1}{tt},1)
% end




%% get cov_mat_mean
% Analaysis_Function_Get_Mean_CovMat_Visualization(file_path_all, kernel_identifier, varargin{:});
% just skip them...
% [cov_mat_mean, roi_data, cov_mat, cov_mat_mean_noise, cov_mat_noise] = Analaysis_Function_Get_Mean_CovMat(file_path_all, kernel_identifier, true);
% % you also want to look at the averaged first order kernel
% for tt = 1:1:4
%     cov_mat_mean_noise_this_type = cellfun(@(A)A{tt}, cov_mat_mean_noise,'UniformOutput', false);
%     K2_CovarianceMatrix_Visualization_SigTest_Draft(cov_mat_mean{tt}, cov_mat_mean_noise_this_type)
% end
