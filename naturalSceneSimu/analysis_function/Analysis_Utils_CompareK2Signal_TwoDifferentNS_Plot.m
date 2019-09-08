function Analysis_Utils_CompareK2Signal_TwoDifferentNS_Plot(all_scene, one_scene, which_kernel_type,spatial_average_str)
% separate plotting and data is easier if you want to plot it better.
%%
MakeFigure;
subplot(2,2,1)
v_real_range = all_scene.v_real_range;
ratio_meaned = all_scene.ratio_meaned;
ratio_std = all_scene.ratio_std;
% PlotXY_Juyue(v_real_range, ratio_meaned,'errorBarFlag',true,'sem',ratio_std,'colorError',[0,0,1],'colorMean',[0,0,1]);
PlotXY_Juyue(v_real_range, ratio_meaned,'errorBarFlag',true,'sem',ratio_std,'colorError',[0,0,0],'colorMean',[0,0,0]);
xlabel('image velocity');
ylabel('ratio natural scene / scrambled phase scene');
% titile('of standard deviation natural scene ')
ylim = get(gca, 'YLim');
set(gca, 'YLim',[0,ylim(2)]);
set(gca, 'XLim',[0,1000]);
ConfAxis

subplot(2,2,3)
% PlotXY_Juyue(v_real_range, ratio_meaned,'errorBarFlag',true,'sem',ratio_std,'colorError',[0,0,1],'colorMean',[0,0,1]);
PlotXvsY(v_real_range, ratio_meaned,'error',ratio_std,'graphType', 'line','color',[0,0,0])
xlabel('image velocity');
ylabel('ratio natural scene / scrambled phase scene');
% titile('of standard deviation natural scene ')
ylim = get(gca, 'YLim');
set(gca, 'YLim',[0,ylim(2)]);
set(gca, 'XLim',[0,1000]);
ConfAxis
%%
subplot(2,2,2)

v_real_range = one_scene.v_real_range;
v2_mean = one_scene.v2_mean;
v2_std = one_scene.v2_std;
v_real_range_sym = cell(2, 1);
v2_mean_sym = cell(2, 1);
v2_std_sym = cell(2, 1);
for ii = 1:1:2
    v_real_range_sym{ii} = [-v_real_range{ii}(end:-1:2);v_real_range{ii}];
    v2_mean_sym{ii}  = [-v2_mean{ii}(end:-1:2);v2_mean{ii}];
    v2_std_sym{ii} = [-v2_std{ii}(end:-1:2);v2_std{ii}]; 
end
% color_bank = {[0,0,0],[1,0,0]};
color_bank = lines(2);
for ii = 1:1:2
    PlotXY_Juyue(v_real_range_sym{ii}, v2_mean_sym{ii},'errorBarFlag',true,'sem',v2_std_sym{ii},'colorError',color_bank(ii,:),'colorMean',color_bank(ii,:));
    
    %     MyScatter_DoubleErrBars(v_real_range{ii}, v2_mean{ii}, [], v2_std{ii} , 'color',color_bank{ii});
    hold on
    title('mean value and standard deviation, within scene');
    xlabel('image velocity');
    ylabel('second order motion estimation');
    box off
end
set(gca, 'XLim',[-1000,1000]);
ConfAxis


subplot(2,2,4)
v_real_range = one_scene.v_real_range;
v2_mean = one_scene.v2_mean;
v2_std = one_scene.v2_std;
color_bank = {[0,0,0],[1,0,0]};
for ii = 1:1:2
    PlotXvsY(cell2mat(v_real_range_sym'), cell2mat(v2_mean_sym'),'error', cell2mat(v2_std_sym'),'graphType', 'line')
    
    hold on
    title('mean value and standard deviation, within scene');
    xlabel('image velocity');
    ylabel('second order motion estimation');
    box off
end
legend('natural scene','phase-scrambled scene');
set(gca, 'XLim',[-1000,1000]);

ConfAxis

% MySaveFig_Juyue(gcf,'Summary_Plot',[which_kernel_type, spatial_average_str], 'nFigSave',2,'fileType',{'png','eps'});

% mean value is smaller. not symmetric. very interesting.
