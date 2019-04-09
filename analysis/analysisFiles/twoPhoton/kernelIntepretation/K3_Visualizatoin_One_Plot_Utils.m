function  data_for_plotting = K3_Visualizatoin_One_Plot_Utils(corrValue_3o, dx_bank, corrParam_third, varargin)
x_bank= [8]; % for exmaple, plot location 8.
dt_vary = (1:5)';
dt_fixed = 0;
which_tau_fixed = [2,3];
% left/right matters here.
dx_bank_plot = {[0,-1];[0,1]}; % potentially could be {[0,-2],[0,-1],[0,1],[0,2]}; % is that posible to incorporate 00 here.? noooo
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% up part. tau3 - tau2 = 0 and tau2 - tau1 is chaning;
data_for_plotting = cell(length(dx_bank_plot),1);

% have this to be a small untility function!
for dxx = 1:1:length(dx_bank_plot)
    dx_this = dx_bank_plot{dxx};
    
    ind_dx = cellfun(@(dx) isequal(dx_this, dx), dx_bank ); % that is what you have. do you want to do this? yes.
    data_for_plotting{dxx} = zeros(length(dt_vary), length(x_bank)); % it si
    for dtt = 1:1:length(dt_vary)
        dt_this = dt_vary(dtt);
        dt_pair_this = zeros(1,2);
        % CREAT DT_PAIR_THIS
        if isequal(which_tau_fixed, [1,2])
            dt_pair_this(1) = dt_fixed; dt_pair_this(2) = dt_this;
        elseif   isequal(which_tau_fixed,[1,3])
            dt_pair_this(2) = dt_fixed; dt_pair_this(1) = dt_this;
        elseif  isequal(which_tau_fixed, [2,3])
            dt_pair_this(1) = dt_this; dt_pair_this(2) = dt_this + dt_fixed;
        end
        ind_third = cellfun(@(single_corr_param) isequal(dt_pair_this,single_corr_param.dt), corrParam_third);
        data_for_plotting{dxx}(dtt, :) = corrValue_3o{ ind_dx }(ind_third,x_bank);
    end
end