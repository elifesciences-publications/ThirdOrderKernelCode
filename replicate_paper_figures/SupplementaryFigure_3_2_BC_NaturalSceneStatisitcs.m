function SupplementaryFigure_3_2_BC_NaturalSceneStatisitcs()
regenerate_data_flag = false;
%%
FWHM_bank = [15, 25, 35, 45, 55, 65, 75];
n = length(FWHM_bank);


%% because it takes a long time to generate stim_statistics
if regenerate_data_flag
    stim_statistics = cell(n, 1);
    for ii = 1:1:n
        stim_statistics{ii} = collect_all_individual_scenes_statistics('FWHM', FWHM_bank(ii));
    end
else
    load('D:\ThirdOrderKernel_intermediate_data\natural_scene_statistics')
end
%% plot histogram of all of them. particular, skewness.
% set up color scheme
color_bank = brewermap(n, 'BuPu');
color_bank = flipud(color_bank);
color_bank(2,:) = [1,0,0];

%% organize the stim_statistics from structure to array.
stim_statistics_mat = cell(n, 1);
for ii = 1:1:n
    stim_statistics_mat{ii} = [stim_statistics{ii}.variance(:), stim_statistics{ii}.skewness(:),stim_statistics{ii}.kurtosis(:), stim_statistics{ii}.mean(:)];
end

MakeFigure;
statisticts_str = {'variance (c^2)', 'skewness','kurtosis','mean'};
xlim_ = {[0,0.4],[-5,5]};
%% This might be wrong. because bin width has to be fixed...
edges = {[0:0.01:0.4], [-5:0.15:5]};
for ii = 1:1:2
    subplot(2,3,ii);
    for jj = 1:1:n
        [statistics_counts,edges_used ]= histcounts( stim_statistics_mat{jj}(:, ii), edges{ii}, 'Normalization','probability');
        edges_middle = [edges_used(2:end) + edges_used(1:end - 1)]/2;
        % instead of plotting the
        hold on
        plot(edges_middle, statistics_counts,'color',color_bank(jj, :));
        xlabel(statisticts_str{ii});
        ylabel('frequency');
        
        ConfAxis;
        set(gca,'XLim',xlim_{ii});
        set(gca,'YScale', 'linear');
        %         set(gca,'YScale', 'log')
    end
    legend('15\circ','25\circ','35\circ','45\circ','55\circ','65\circ','75\circ');
end

end



