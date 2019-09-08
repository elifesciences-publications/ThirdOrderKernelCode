
function dt_x_dx_plot_average_over_bar = K2_Visualization_AverageOverBars_Compute_dt_x_dx(gliderRespPred, varargin)

dt = [-12:12];
dt_bank = [-8:8];
x_bank = [8:13];
n_average_over_bars = 2; % could be three.
dx_plot = 0;
nMultiBars = 10;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% dx_x_dx_plot should be smaller/
% calculate effective x_bank.

x_bank = x_bank((x_bank + dx_plot) <= nMultiBars);

dt_x_dx_plot = zeros(length(dt_bank), length(x_bank));
dt_plot_ind = ismember(dt,dt_bank);
% FOR SAC, This can be out of range for x_bank = [1:10], dx_bank = 3; 10,
% %from some bars, it does not have corresponding right bars.

for xx = 1:1:length(x_bank)
    dt_x_dx_plot(:,xx) = gliderRespPred(dt_plot_ind,x_bank(xx), x_bank(xx) + dx_plot);
end

% you will get the original. now average near by together.
dt_x_dx_plot_average_over_bar = zeros(length(dt_bank), length(x_bank) - n_average_over_bars + 1);
for xx = 1:1:length(x_bank) - n_average_over_bars + 1
    dt_x_dx_plot_average_over_bar(:,xx) = sum(dt_x_dx_plot(:, xx : xx + n_average_over_bars - 1),2);
end
