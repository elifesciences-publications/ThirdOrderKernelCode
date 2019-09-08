function data_for_plot = K3_Visualizatoin_Utils_One_Plot_X_Fixed_Calculate(corrValue_3o, dx_bank, corrParam_third, varargin)

x_fixed = [8]; % for exmaple, plot location 8.
dt_vary = (1:5)';
dt_fixed = 0;
% left/right matters here. potentially could be {[0,-2],[0,-1],[0,1],[0,2]}; % is that posible to incorporate 00 here.? noooo
dx_bank_plot = {[0,-1];[0,1]};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% upper part. tau3 - tau2 = 0 and tau2 - tau1 is chaning;
which_tau_fixed = [2,3];
data_for_plotting_converging = K3_Visualizatoin_One_Plot_Utils(corrValue_3o, dx_bank, corrParam_third, ...
    'x_bank', x_fixed, 'dt_fixed', dt_fixed, 'dt_vary', dt_vary, 'dx_bank_plot', dx_bank_plot, 'which_tau_fixed',  which_tau_fixed);

%% lower part, tau3 - tau1 = 0, and tau2 - tau1 is changing.
which_tau_fixed = [1,3];
data_for_plotting_diverging = K3_Visualizatoin_One_Plot_Utils(corrValue_3o, dx_bank, corrParam_third, ...
    'x_bank', x_fixed, 'dt_fixed', dt_fixed, 'dt_vary', dt_vary, 'dx_bank_plot', dx_bank_plot, 'which_tau_fixed',  which_tau_fixed);

%% organize left/right mirror. up and down converging/dirvergin.
data_for_plot = [flipud(cat(2,data_for_plotting_converging{:})); % filp the upper part, so that it is dt = 5:4:3:2:1:1:2:3:4:5..
    cat(2,data_for_plotting_diverging{:})];

end

