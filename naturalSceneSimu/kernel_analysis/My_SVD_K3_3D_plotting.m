function My_SVD_K3_3D_plotting(T, U, fitting_errors, xlabel_str, ylabel_str, x_vals, y_vals, R)
if R == 1
    plotting_R_1(T, U, fitting_errors, xlabel_str, ylabel_str, x_vals, y_vals);
elseif R == 2
    plotting_R_2(T, U, fitting_errors, xlabel_str, ylabel_str, x_vals, y_vals);
end
end
function plotting_R_2(T, U, fitting_errors, xlabel_str, ylabel_str, x_vals, y_vals)
MakeFigure;
% first dimension is easy...
x_plot = {1:length(U{1}), y_vals,x_vals};
x_label_str = {'time since most recent bar', ylabel_str, xlabel_str};
title_str = {'U_{1st component}','U_{2nd component}','U_{3rd component}'};
color_bank = [0,0,0; 1,0,0];
for ii = 1:1:3
    for jj = 1:1:2
        subplot(2,3,ii)
        plot(x_plot{ii}, U{ii}(:, jj), 'color', color_bank(jj, :)); hold on;
        xlabel(x_label_str{ii});
        title(title_str{ii});
        ConfAxis('fontSize', 15);
    end
    legend('1st Dimension', '2nd Dimension');
end
% organize
T_integrated = squeeze(sum(T, 1));
T_recover = cpdgen(U);
T_recover_integrated = squeeze(sum(T_recover, 1));
T_residual = T - T_recover;
T_residual_integrated = squeeze(sum(T_residual, 1));
T_plot = {T_integrated, T_recover_integrated, T_residual_integrated};
T_str = {['ori, energy: ', num2str(fitting_errors.impulse)],...
    ['aprx, energy: ', num2str(fitting_errors.recover), ' (', num2str(fitting_errors.recover/fitting_errors.impulse), ')'],...
    ['res, energy: ', num2str(fitting_errors.residual), ' (', num2str(fitting_errors.residual/fitting_errors.impulse), ')']};
thisMaxVal = max(abs(T_plot{1}(:)));
for ii = 1:1:3
    subplot(2, 3, ii + 3);
    imagesc(x_vals, y_vals, T_plot{ii});
    colormap_gen;
    colormap(mymap);
    set(gca,'Clim',[-thisMaxVal thisMaxVal]);
    xlabel(xlabel_str);
    ylabel(ylabel_str);
    title(T_str{ii})
    set(gca, 'clim')
    axis tight;
    if size(T_plot{ii}, 1) == size(T_plot{ii}, 2)
        axis equal;
    end
    ConfAxis('fontSize',15);
    box on
end

end
function plotting_R_1(T, U, fitting_errors, xlabel_str, ylabel_str, x_vals, y_vals)
MakeFigure;
% first dimension is easy...
x_plot = {1:length(U{1}), y_vals,x_vals};
x_label_str = {'time since most recent bar', ylabel_str, xlabel_str};
title_str = {'U_1','U_2','U_3'};
for ii = 1:1:3
    subplot(2,3,ii)
    plot(x_plot{ii}, U{ii}, 'k-');
    xlabel(x_label_str{ii});
    title(title_str{ii});
    hold on; plot([0,0],get(gca,'YLim'),'k--');
    ConfAxis('fontSize', 15);
end

% organize
T_integrated = squeeze(sum(T, 1));
T_recover = cpdgen(U);
T_recover_integrated = squeeze(sum(T_recover, 1));
T_residual = T - T_recover;
T_residual_integrated = squeeze(sum(T_residual, 1));
T_plot = {T_integrated, T_recover_integrated, T_residual_integrated};
T_str = {['ori, energy: ', num2str(fitting_errors.impulse)],...
    ['aprx, energy: ', num2str(fitting_errors.recover), ' (', num2str(fitting_errors.recover/fitting_errors.impulse), ')'],...
    ['res, energy: ', num2str(fitting_errors.residual), ' (', num2str(fitting_errors.residual/fitting_errors.impulse), ')']};
thisMaxVal = max(abs(T_plot{1}(:)));
for ii = 1:1:3
    subplot(2, 3, ii + 3);
    imagesc(x_vals, y_vals, T_plot{ii});
    colormap_gen;
    colormap(mymap);
    set(gca,'Clim',[-thisMaxVal thisMaxVal]);
    xlabel(xlabel_str);
    ylabel(ylabel_str);
    title(T_str{ii})
    set(gca, 'clim')
    axis tight;
    if size(T_plot{ii}, 1) == size(T_plot{ii}, 2)
        axis equal;
    end
    ConfAxis('fontSize',15);
    box on
end
end