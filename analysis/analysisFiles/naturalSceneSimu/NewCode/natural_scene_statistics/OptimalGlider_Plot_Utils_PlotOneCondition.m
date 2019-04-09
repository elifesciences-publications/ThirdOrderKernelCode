function OptimalGlider_Plot_Utils_PlotOneCondition(optimal_glider, predictor_num_bank, predictor_rank,  varargin)
main_name = [];
save_fig_flag = [];
corr_name = [];
corr_name_xlabel = {'T1','T2', 'T3','T4',...
    'Div1','Div2','Div3','Div4',...
    'Con1','Con2', 'Con3','Con4',...
    'Elbow','Late Knight','Early Knight','Elbow Late Break','Elbow Early Break'};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
corr_name_xlabel = corr_name; % very long name...
%%
MakeFigure
for ii = 1:1:length(predictor_num_bank)
    nn = predictor_num_bank(ii);
    subplot(3, 3, ii);
    bar(optimal_glider(nn).beta); colormap(gray);
    % confidence interval.
    for cc = 1:1:length(corr_name_xlabel)
        hold on
        plot([cc,cc],  optimal_glider(nn).beta_ci(cc,:), 'r');
    end
    
    hold on
    % plot two point, converging, diverging position
    
    max_value = max(abs(optimal_glider(nn).beta));
    
% okay, instead of plotting the 55 and 99. find out the position.
    ind_diverging = find(ismember(corr_name_xlabel, 'Diverging DT 1')); 
    ind_converging = find(ismember(corr_name_xlabel, 'Converging DT 1'));
    ind_late_knight = find(ismember(corr_name_xlabel, 'Late Knight'));
    plot([1,1],[-max_value,max_value],'g--');
    plot([ind_diverging,   ind_diverging],[-max_value,max_value],'g--');
    plot([ind_converging,  ind_converging],[-max_value,max_value],'g--');
    plot([ind_late_knight, ind_late_knight],[-max_value,max_value],'g--');

    set(gca, 'YLim', [-max_value, max_value]);
    text(-8, max_value * 1/2, ['r^2 = ', num2str(optimal_glider(nn).r_square)],'FontSize', 15);
    text(-8, 0, ['\lambda = ', num2str(optimal_glider(nn).lambda)],'FontSize', 15);
    text(-8, -max_value * 1/2, ['# predictors = ', num2str(nn)],'FontSize', 15);
    set(gca,'XAxisLocation', 'origin');
    box off
%     ylabel('\beta');
%     if ii > 4
%         set(gca,'XTick',1:length(corr_name_xlabel), 'XTickLabel',corr_name_xlabel);
%     else
        set(gca, 'XTick', []);

%     ConfAxis;
    
    if ii == 1
        
    end
end
subplot(3, 3, 1);
text(12,max(abs(optimal_glider(1).beta))* 1.5, main_name,'interpreter', 'none','FontSize', 20);
subplot(3,3,7)
ranking_name_str = 'predictors into regression(squentially):';
for ii = 1:1:length(corr_name_xlabel)
    ranking_name_str = cat(2, ranking_name_str, [',  ', cat(2, corr_name_xlabel{predictor_rank == ii})]);
end
text(-5,-max(abs(optimal_glider(5).beta)) * 1.8, ranking_name_str ,'interpreter', 'none','FontSize', 15);
%%
if save_fig_flag
    MySaveFig_Juyue(gcf, 'OG',main_name,'nFigSave',1,'fileType',{'png'});
end
end