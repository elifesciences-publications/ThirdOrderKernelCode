function SAC_Temp_Opponency(filename, fileID_name_saveFig, bin_stim_flag, down_sample_response_flag, varargin)
barUse = [4, 5, 6]; % this will change from cell to cell. 3.
saveFigFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii}, '= varargin{', num2str(ii + 1),'};'])
end

%%
[resp, stim, f] = SAC_Temp_Preprocessing_Stim_Resp(filename,bin_stim_flag, down_sample_response_flag);
nMultiBars = size(stim, 2);
maxTau = ceil(500/(1000/f));
maxTau_Use = ceil(maxTau * 3/4);
dx_bank = - (length(barUse) - 1):1: (length(barUse) - 1);

dt_max = ceil(150/(1000/f)); % 150ms
dt_bank = [-dt_max:1:dt_max]; %
dt = [-dt_max:1:dt_max];
tMax = ceil(150/(1000/f)); % first 150 ms.

%% smaller barUse
cov_mat = Main_KernelExtraction_ReverseCorr({resp}, stim, {1:length(resp)}, ...
    'order', 2, 'donoise', 0, 'maxTau', maxTau);
cov_mat = cov_mat{1};
cov_mat = (cov_mat + cov_mat')/2;
dx_dt = K2_Covariance_Visualization_Calculate_DXDT(cov_mat, 'x_bank', barUse, 'dx_bank', dx_bank, 'dt', dt, 'dt_bank', dt_bank, 'tMax', tMax, ...
    'nMultiBars', nMultiBars);
MakeFigure;
subplot(1,2,1)
K2_CovarianceMatrix_Visualization_dx_dt_plot(dx_dt, dt_bank, dx_bank);
title('Direction Selectivity - Full DXDT')
% label
subplot(1,2,2)
K2_CovarianceMatrix_Visualization_dx_dt_plot(dx_dt - fliplr(dx_dt), dt_bank, dx_bank);
title('Direction Selectivity - DXDT Difference'); % Direction Selectivity.
if saveFigFlag
    MySaveFig_Juyue(gcf,fileID_name_saveFig,['dx_dt'],'nFigSave',2,'fileType',{'png','fig'});
end
%%

end
