function K2_CovarianceMatrix_Visualization_x_x_dt(cov_mat,varargin)
% you should change this into different small functions. and do not con.
saveFigFlag = false;
MainName = 'SecondOrder';

nMultiBars = 20;
maxTau = size(cov_mat,1)/nMultiBars;
typeStr = [];

dt = [-8:1:8];
tMax = 20; % you have to find a better interval to integral.

xBank = [7:14];
dxBank = [-5:5];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% typeStr = {'T4 Pro','T4 Reg', 'T5 Pro','T5 Reg'};


gliderRespPred = K2_CovarianceMatrix_Visualization_Compute_GliderRespPred(cov_mat,varargin{:});
K2_CovarianceMatrix_Visualization_Plot_x_x_dt(gliderRespPred,varargin{:})
