function stim_cont = Simu_Util_Generate_Stim_Sinewave(k_x, k_t, dir, x_resolu, t_resolu, t_total, x_total)
% t_total = 3; % 3 second.
% x_total = 30;

n_x = round(x_total/x_resolu); % 6 discrete spatial locations/
n_t = round(t_total/t_resolu); % 10 discrete temporal locations.

x = (0:n_x)' * x_resolu;
t = (0:n_t) * t_resolu;

stim_cont = sin(dir * 2 * pi * k_x * x + 2 * pi * k_t * t);

% %%
% MakeFigure; 
% imagesc(stim_cont(:,1:100));colormap(gray); set(gca, 'CLim', [-1, 1]);
% set(gca, 'YDir', 'normal');