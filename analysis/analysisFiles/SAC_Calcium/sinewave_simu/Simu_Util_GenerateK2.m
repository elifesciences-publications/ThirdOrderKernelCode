
function K2 = Simu_Util_GenerateK2(t_resolu, x_resolu, tau_max, xi_max)
%% max tau for time and space.
% tau_max = 1.5; % 1sec.
% xi_max = 30; % 30 unit. let us say. it is 30 degree.. not essential.

%% spatial filter. if input is x...
spatial_const = 10; %% 10 degree.
spatial_const_tau = 10; %% the time constant decreases every 10 degree.
time_const_fixed = 0.2; %% 0.5 second time const.

%% discretization.
n_xi = round(xi_max/x_resolu); % 6 discrete spatial locations/
n_tau = round(tau_max/t_resolu); % 10 discrete temporal locations.

xi = (0:n_xi)' * x_resolu;
tau = (0:n_tau)' * t_resolu;

n_x = length(xi);
n_t = length(tau);

%%
spatial_gain = spatial_filter(xi, spatial_const); %% the spatial gain at each spatial location.
time_const = time_const_fixed * temporal_const_change_with_x(xi, spatial_const_tau);

%% filter over space.
%% 
% MakeFigure; 
% for x1 = 1:1:n_x
%     plot(tau, temporal_filter(tau, time_const(x1))); hold on;
% end
% legend(num2str(time_const));

K2 = zeros(n_x, n_x, n_t, n_t);
for x1 = 1:1:n_x
    for x2 = 1:1:n_x 
        K2(x1, x2, :, :) = spatial_gain(x1) * spatial_gain(x2) * ...
            temporal_filter(tau, time_const(x1)) * temporal_filter(tau, time_const(x2))';
    end
end

end

function f = temporal_filter(tau, time_const)
f = 1/time_const * tau .* exp(-tau/time_const);
end

function f = spatial_filter(xi, spatial_const)
f = 1/(sqrt(2 *pi) * spatial_const) * exp(-1/2 * xi.^2/spatial_const.^2); %% This value could change.
end

% function f = spatial_filter_uniform(xi, spatial_const)
% f = ones(size(xi)); %% This value could change.
% end

function f = temporal_const_change_with_x(xi, spatial_const_tau)
% exponential decay.
f = exp(-xi./spatial_const_tau);
end
