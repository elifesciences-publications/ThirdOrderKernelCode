%% calculate the general measures of correlation
function gmc_estimate = GMC_Utils_GMC_Est(x, y)
% [h, ~] = GMC_Utils_FindOptimalH_Main(x, y);

% n_h_out = 5;
x_lim = [min(x), max(x)];
h = diff(x_lim)/1000;
dx = diff(x_lim)/200;
num_out_limit = 0;

%% find optimal h and dx. 
%%
x_min = x_lim(1) - num_out_limit * dx;
x_max = x_lim(2) + num_out_limit * dx;
x_discretized = [x_min:dx:x_max]';

% x_min_integration_ind = num_out_limit  + n_h_out * 5 + 1;
% x_max_integration_ind = length(x_discretized) - (num_out_limit + n_h_out * 5) ;
x_min_integration_ind = 1;
x_max_integration_ind = length(x_discretized);
f_x = GMC_Utils_kde_kernel(x_discretized,x, h);

% conditioned distirbution.

phi_y_given_x = GMC_Utils_PhiYGivenX(x_discretized, x, y, h);


y_sample_mean = mean(y);
y_sample_var = var(y);

var_k = 1; % you are using gaussian with mean 1.

% integration_limit
numerator_term1 = (phi_y_given_x.^2) ./ f_x; numerator_term1(isnan(numerator_term1)) = 0;
numerator_term1 = sum(numerator_term1(x_min_integration_ind: x_max_integration_ind)) * dx;
numerator_term2 = (y_sample_mean + h * 0).^2;
var_y_estimator =  y_sample_var + h.^2 * var_k;

gmc_estimate = (numerator_term1 - numerator_term2)/var_y_estimator;


MakeFigure;
subplot(2,2,1);
scatter(x, y,'k.'); hold on
% plot(x_discretized, phi_y_given_x);
mean_y_given_x = phi_y_given_x./f_x;
plot(x_discretized(x_min_integration_ind: x_max_integration_ind), mean_y_given_x(x_min_integration_ind: x_max_integration_ind))
subplot(2,2,2);
plot(x_discretized(x_min_integration_ind: x_max_integration_ind), mean_y_given_x(x_min_integration_ind: x_max_integration_ind))

% MakeFigure;
% plot(x_discretized(x_min_integration_ind: x_max_integration_ind), f_x(x_min_integration_ind: x_max_integration_ind));

end
% get a data and take a look.

