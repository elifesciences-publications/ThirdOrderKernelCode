function CorrelationInMovingNS_Utils_Plot_Main_Temp(stim_corr_data, v_real,varargin)
save_fig_flag = false;
main_name = [];
corr_name = {'Two Point DT 1','Two Point DT 2', 'Two Point DT 3','Two Point DT 4',...
    'Diverging DT 1','Diverging DT 2','Diverging DT 3','Diverging DT 4',...
    'Converging DT 1','Converging DT 2', 'Convering DT 3','Converging DT 4','Elbow','Late Knight'};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% 
corr_str = {'2o_1_+', '2o_1_-','2o_2_+','2o_2_-'};
corr_name_this = {'Two Point DT 1', 'Two Point DT 1', 'Two Point DT 2', 'Two Point DT 2'};
% 
data_2o = [stim_corr_data(:,ismember(corr_name,corr_name_this{1}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{2}),2),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{3}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{4}),2)];
stim_corr_relation_plot_temp(v_real,data_2o, corr_str);
if save_fig_flag 
    MySaveFig_Juyue(gcf, main_name, '2o_only','nFigSave',2,'fileType',{'png','fig'});
end
%% how about the third
corr_str = {'div_1_+', 'div_1_-','div_2_+','div_2_-'};
corr_name_this = {'Diverging DT 1', 'Diverging DT 1', 'Diverging DT 2', 'Diverging DT 2'};

data_3o = [stim_corr_data(:,ismember(corr_name,corr_name_this{1}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{2}),2),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{3}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{4}),2)];
stim_corr_relation_plot_temp(v_real,data_3o, corr_str);
if save_fig_flag 
    MySaveFig_Juyue(gcf, main_name, 'div_only','nFigSave',2,'fileType',{'png','fig'});
end
%%
corr_str = {'conv_1_+', 'conv_1_-','conv_2_+','conv_2_-'};
corr_name_this = {'Converging DT 1', 'Converging DT 1', 'Converging DT 2', 'Converging DT 2'};
data_3o = [stim_corr_data(:,ismember(corr_name,corr_name_this{1}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{2}),2),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{3}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{4}),2)];

data_3o = [stim_corr_data(:,9,1),stim_corr_data(:,9,2),stim_corr_data(:,10,1),stim_corr_data(:,10,2)];
stim_corr_relation_plot_temp(v_real,data_3o, corr_str);
if save_fig_flag 
    MySaveFig_Juyue(gcf, main_name, 'cov_only','nFigSave',2,'fileType',{'png','fig'});
end
%% 
corr_str = {'2o_1_+', '2o_1_-','div_1_+', 'div_1_-'};
corr_name_this = {'Two Point DT 1', 'Two Point DT 1', 'Diverging DT 1', 'Diverging DT 1'};

data_2o_3o = [stim_corr_data(:,ismember(corr_name,corr_name_this{1}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{2}),2),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{3}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{4}),2)];
data_2o_3o = [stim_corr_data(:,1,1),stim_corr_data(:,1,2),stim_corr_data(:,5,1),stim_corr_data(:,5,2)];
stim_corr_relation_plot_temp(v_real,data_2o_3o, corr_str);
if save_fig_flag 
    MySaveFig_Juyue(gcf, main_name, '2o_div','nFigSave',2,'fileType',{'png','fig'});
end
%%
corr_str = {'2o_1_+', '2o_1_-','conv_1_+', 'conv_1_-'};
corr_name_this = {'Two Point DT 1', 'Two Point DT 1', 'Converging DT 1', 'Converging DT 1'};

data_2o_3o = [stim_corr_data(:,ismember(corr_name,corr_name_this{1}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{2}),2),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{3}),1),...
           stim_corr_data(:,ismember(corr_name,corr_name_this{4}),2)];
stim_corr_relation_plot_temp(v_real,data_2o_3o, corr_str);
if save_fig_flag 
    MySaveFig_Juyue(gcf, main_name, '2o_cov','nFigSave',2,'fileType',{'png','fig'});
end
%% plot the directive selective second order and third order...
corr_str = {'2o_1', '2o_2','conv_1','div_1'};
corr_name_this = {'Two Point DT 1', 'Two Point DT 2', 'Converging DT 1', 'Diverging DT 1'};

stim_corr_data_ds = (stim_corr_data(:,:,1) - stim_corr_data(:,:,2))/2;
data_2o_3o_ds = [stim_corr_data_ds(:,ismember(corr_name,corr_name_this{1})),...
           stim_corr_data_ds(:,ismember(corr_name,corr_name_this{2})),...
           stim_corr_data_ds(:,ismember(corr_name,corr_name_this{3})),...
           stim_corr_data_ds(:,ismember(corr_name,corr_name_this{4}))];
stim_corr_relation_plot_temp(v_real,data_2o_3o_ds, corr_str);

if save_fig_flag 
    MySaveFig_Juyue(gcf, main_name, '2o_3o_direction_selective','nFigSave',2,'fileType',{'png','fig'});
end
% corr_str = {'2o_1', '2o_2','conv_1 - div_1','div_1'};
% stim_corr_data_ds = (stim_corr_data(:,:,1) - stim_corr_data(:,:,2))/2;
% data_2o_3o_ds = [stim_corr_data_ds(:,1),stim_corr_data_ds(:,2),stim_corr_data_ds(:,5) - stim_corr_data_ds(:,9),stim_corr_data_ds(:,9)];
% stim_corr_relation_plot_temp(v_real,data_2o_3o_ds, corr_str);

end