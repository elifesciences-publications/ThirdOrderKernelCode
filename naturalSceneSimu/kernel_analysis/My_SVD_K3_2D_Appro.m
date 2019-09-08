function [U, S, V] = My_SVD_K3_2D_Appro(T_2D, plot_flag, x_vals, y_vals, xlabel_str, ylabel_str, save_fig_flag, main_name)
% always
% first, integrate the first dimension.
[U,S,V] = svd(T_2D);

if plot_flag
    plot_approximation_by_first(T_2D, x_vals, y_vals, xlabel_str, ylabel_str);
        if save_fig_flag
            MySaveFig_Juyue(gcf,main_name,'2D_Decom_1','nFigSave',2,'fileType',{'png','fig'});
        end
    plot_approximation_by_first_two(T_2D, x_vals, y_vals, xlabel_str, ylabel_str);
        if save_fig_flag
            MySaveFig_Juyue(gcf,main_name,'2D_Decom_2','nFigSave',2,'fileType',{'png','fig'});
        end
end
end

function plot_approximation_by_first(T_2D, x_vals, y_vals, xlabel_str, ylabel_str)
% T_2D = squeeze(sum(T, 1));
[U,S,V] = svd(T_2D);

MakeFigure;
subplot(2,3,1)
plot(y_vals, U(:, 1), 'k');
xlabel(ylabel_str);
title('U_1');
hold on; plot([0,0],get(gca,'YLim'),'k--');
plot(get(gca,'XLim'),[0,0],'k--');
ConfAxis('fontSize', 15);

subplot(2,3,2)
plot(x_vals, V(:, 1), 'k');
xlabel(xlabel_str);
title('V_1');
hold on; plot([0,0],get(gca,'YLim'),'k--');
plot(get(gca,'XLim'),[0,0],'k--');
ConfAxis('fontSize', 15);

subplot(2,3,3)
plot(diag(S), 'Marker','.', 'color',[0,0,0]);
xlabel('nth component');
%     set(gca, 'XLim', [0, min(size(T_2D))]);
title('S');
ConfAxis('fontSize', 15, 'MarkerSize', 20);

T_plot = {T_2D, U(:, 1) * V(:, 1)'* S(1,1), T_2D - U(:, 1) * V(:, 1)'* S(1,1)};
T_str = {'ori','aprx (by 1 component)','res'};
thisMaxVal = max(abs(T_plot{1}(:)));
for ii = 1:1:3
    subplot(2, 3, ii + 3)
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

function plot_approximation_by_first_two(T_2D, x_vals, y_vals, xlabel_str, ylabel_str)
% T_2D = squeeze(sum(T, 1));
[U,S,V] = svd(T_2D);

MakeFigure;
for ii = 1:1:2
    subplot(3,3,1 + (ii-1) * 3)
    plot(y_vals, U(:, ii), 'k');
    xlabel(ylabel_str);
    title(['U_', num2str(ii)]);
    hold on; plot([0,0],get(gca,'YLim'),'k--');
    ConfAxis('fontSize', 10);
    
    subplot(3,3,2 + (ii-1) * 3)
    plot(x_vals, V(:, ii), 'k');
    xlabel(xlabel_str);
    title(['V_', num2str(ii)]);
    hold on; plot([0,0],get(gca,'YLim'),'k--');
    ConfAxis('fontSize', 10);
    
    if ii == 1
        subplot(3,3,3)
        plot(diag(S), 'Marker','.', 'color',[0,0,0]);
        xlabel('nth component');
        %     set(gca, 'XLim', [0, min(size(T_2D))]);
        title('S');
        ConfAxis('fontSize', 15, 'MarkerSize', 20);
    end
end
T_recover = U(:, 1) * V(:, 1)' * S(1,1) + U(:, 2) * V(:, 2)' * S(2,2);
T_plot = {T_2D, T_recover, T_2D - T_recover};
T_str = {'ori','aprx (by 1&2 components)','res'};
thisMaxVal = max(abs(T_plot{1}(:)));

for ii = 1:1:3
    subplot(3, 3, ii + 6)
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
    ConfAxis('fontSize',12);
    box on
end

end