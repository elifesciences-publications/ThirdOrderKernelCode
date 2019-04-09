function dx_dt_val = K2_Covariance_Visualization_Calculate_DXDT(cov_mat, varargin)
% start from the cov_mat_
dt = [-12:12];
dt_bank = [-8:8];
% do not use x_bank anymore...
dx_bank = [-10:1:10]; % negative dx...
nMultiBars = 20;
use_center_of_rf_flag = true;
% 7:13;
x_bank = [7:13];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

cov_mat_glider = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat, 'dt', dt, 'nMultiBars', nMultiBars, 'tMax',tMax);

dx_dt_val = zeros(length(dt_bank),length(dx_bank));
dt_use_ind = ismember(dt,dt_bank);
if use_center_of_rf_flag
    for dxx = 1:1:length(dx_bank)
        dx = dx_bank(dxx);
        % they are always in the middle.
        column_indices = x_bank + dx;
        x_bank_use_indices = column_indices <= max(x_bank) & column_indices >= min(x_bank);
        x_bank_use = x_bank(x_bank_use_indices); 
        
        val_this_dx = zeros(length(dt_use_ind),length(x_bank_use));
        for xx = 1:1:length(x_bank_use)
            val_this_dx(:,xx) = cov_mat_glider(dt_use_ind,  x_bank_use(xx),  x_bank_use(xx)+dx);
        end
        % get rid of the small one and the large one... should be easy.
        dx_dt_val(:,dxx) = mean(val_this_dx, 2);
        
    end
    
else
    % prepare the cov_mat so that indexing is easier for cycles.
    cov_mat_glider_double = cat(3,cov_mat_glider,cov_mat_glider);
    cov_mat_glider_double_vec = reshape(cov_mat_glider_double, size(cov_mat_glider_double,1),[]); % it works.
    
    dx_use_dx_0 = [eye(nMultiBars), zeros(nMultiBars,nMultiBars)];
    % you should shift this around.
    for dxx = 1:1:length(dx_bank)
        dx = dx_bank(dxx);
        dx_use_ind =  circshift(dx_use_dx_0,dx,2) == 1;
        val_all_x = cov_mat_glider_double_vec(dt_use_ind,dx_use_ind); % add them together... too much noise.
        
        dx_dt_val(:,dxx) = mean(val_all_x, 2); % calculate mean value
        % what if you average over smaller range.
    end
end

% MakeFigure;
% quickViewOneKernel(dx_dt_val,1)

end

