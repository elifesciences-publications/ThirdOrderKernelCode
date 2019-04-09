function SAC_Temp_Opponency_WithCovMat(cov_mat, varargin)
barUse = [4, 5, 6, 7, 8]; % this will change from cell to cell. 3.
saveFigFlag = false;
nMultiBars = 10;
f = 37.5;
for ii = 1:2:length(varargin)
    eval([varargin{ii}, '= varargin{', num2str(ii + 1),'};'])
end

%%

maxTau = ceil(500/(1000/f));
maxTau_Use = ceil(maxTau * 3/4);
dx_bank = - (length(barUse) - 1):1: (length(barUse) - 1);

dt_max = ceil(150/(1000/f)); % 150ms
dt_bank = [-dt_max:1:dt_max]; %
dt = [-dt_max:1:dt_max];
tMax = ceil(150/(1000/f)); % first 150 ms.

%% smaller barUse
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

%%

end