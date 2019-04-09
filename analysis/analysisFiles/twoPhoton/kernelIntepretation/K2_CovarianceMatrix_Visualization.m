function K2_CovarianceMatrix_Visualization(cov_mat,varargin)
% this would be only one or four? one makes more sense.
% you just have to change the name. not a big deal.
% saveFigFlag = false;
% MainName = 'SecondOrder';
% maxTau = 64;
% nMultiBars = 20;
% tMax = 20; % you have to find a better interval to integral.
% typeStr = [];

K2_CovarianceMatrix_Visualization_x_x_dt(cov_mat,varargin{:});
K2_CovarianceMatrix_Visualization_dx_dt_x(cov_mat,varargin{:});
K2_CovarianceMatrix_Visualization_dt_x_dx(cov_mat,varargin{:});