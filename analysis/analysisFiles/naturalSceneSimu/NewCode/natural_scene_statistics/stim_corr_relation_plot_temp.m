function stim_corr_relation_plot_temp(v_real, data, corr_str)
% four is better....
thresh_n_datapoints = 0;
MakeFigure;
supplot_num = [2,8,14,20];
for ii = 1:1:4
    subplot(4,5, supplot_num(ii))
    h = histogram(data(:,ii));
    centers = h.BinEdges(1:end-1) + 1/2 * h.BinWidth;
    p = h.Values;
    semilogy(centers, p,'lineWidth',1.5,'color',[0,0,0]);
    title(corr_str{ii});
end

supplot_num = [1,6,11,16];
for ii = 1:1:4
    subplot(4,5, supplot_num(ii))
    %         scatter(v_real, data(:,ii),'r.')
    Utils_ScatterPlot_VReal_VEst(v_real, data(:,ii))
    ylabel(corr_str{ii});
    corr_value = corr(data(:,ii), v_real);
    text(1,1,num2str(corr_value),'Units', 'normalized');
    if ii == 4
        xlabel('v_{real}');
    else
        set(gca,'XTick',[]);
    end
end

subplot_num = [2,3,4,5;7,8,9,10;12,13,14,15;17,18,19,20];
for ii = 1:1:4
    for jj = ii + 1:1:4
        subplot(4,5, subplot_num(ii, jj));
        % you need another scatter plot
        scatter(data(:,jj), data(:,ii),'k.');
        set(gca,'XTick',[]);
        if ~(jj == ii + 1)
            set(gca,'YTick',[]);
        end
        corr_value = corr(data(:,ii), data(:, jj));
        text(1,1,num2str(corr_value),'Units', 'normalized');
    end
end



for ii = 1:1:4
    for jj = ii + 1:1:4
        subplot(4,5, subplot_num(jj, ii));
        grid_approximation_show(data(:,[ii,jj]),'n_bin', 40,'thresh_n_datapoints', thresh_n_datapoints);
        %         set(gca,'XTick',[]);set(gca,'YTick',[]);
        if jj == 4
            xlabel(corr_str{ii});
        end
    end
end


end
function Utils_ScatterPlot_VReal_VEst(v_real, v)
distribution = 'gaussian';
switch distribution
    case 'gaussian'
%         ScatterXYBinned(v_real, v, 25, 50, 'color',[0,0,0],'lineWidth',1,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','histeq');
        ScatterXYBinned(v_real, v, 25, 50, 'color',[0,0,0],'lineWidth',1,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','linear');
    case 'uniform'
        ScatterXYBinned(v_real, v, 25, 50, 'color',[0,0,0],'lineWidth',1,'markerType','o','setAxisLimFlag',1,'plotDashLineFlag',1, 'edge_distribution','linear');
    case 'binary'
        scatter(v_real, v, 'r.');
end
% xlabel('real velocity'); ylabel('');

end