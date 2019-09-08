function K2_CovarianceMatrix_Visualization_dt_x_dx(cov_mat,varargin)
% this should also give out matrix...
% you should change this into different small functions. and do not con.
saveFigFlag = false;
MainName = 'SecondOrder';
nMultiBars = 20;
maxTau = size(cov_mat,1)/nMultiBars;
typeStr = [];

dt = [-12:1:12]; % is this dt long enough? should be. should be good enought. dt 200 ms.
tMax = 20; % you have to find a better interval to integral. change this later on.

xBank = [6:15]; % has to been aligned...
dxBank = [0:5]; % dxBank? this has to be second order kernel, instead of covariance matrix...
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% group these two together.
gliderRespPred = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat,varargin{:});
K2_CovarianceMatrix_Visualization_Plot_dt_x_dx(gliderRespPred,varargin{:})
