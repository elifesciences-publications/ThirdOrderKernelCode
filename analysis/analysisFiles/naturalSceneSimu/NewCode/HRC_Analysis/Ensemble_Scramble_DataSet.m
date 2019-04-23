function Ensemble_Scramble_DataSet(generate_synthetic_image_flag, generate_data_flag, analyze_data_flag, kernel_extraction_method, use_all_flag)
%%
switch kernel_extraction_method
    case 'HRC'
        which_kernel_type = 'HRC_binary_dense';
        ylabel_str = 'HRC output';
    case 'STE'
        which_kernel_type = 'STE_binary';
        ylabel_str = 'Motion Energy Model output';
end
n_image_per_set = 1000;
S =  GetSystemConfiguration;
% image_name = 'statiche0_ensemble_scrambling_ori_image'; % for scrambling.
if use_all_flag
    image_name = 'statiche0_ensemble_2ndpreserved_allimages'; % all images are used.
    image_property = 'preserved2nd_all';
else
    image_name = 'statiche0_ensemble_2ndpreserved_selectedimages'; % selected 1000 images are used.
    image_property = 'preserved2nd_selected';
end
image_storage_folder = fullfile(S.natural_scene_simulation_path, 'image',image_name);
set_num = 0; % you have to change this number manaully. that is fine. test test test.
scene_name = ['image_set_', int2str(set_num)];


%% 
if generate_synthetic_image_flag
    error('need to fix the directories before using this')
    % for scrambling.
%     ensemble_scrambling_utils_generate_image_set(set_num, n_image_per_set, image_storage_folder,scene_name);
    % preserve second order structure.
     ensemble_preserve_2nd_utils_generate_image_set(set_num, n_image_per_set, image_storage_folder, scene_name, use_all_flag)
end

%%
if generate_data_flag
    error('need to fix the directories before using this')
%     velocity.distribution = 'gaussian';
%     velocity.range = 114;
        velocity.distribution = 'binary';
        velocity.range = [0:10:1000];
    
    seed_num = set_num;
    image_source_full_path = fullfile(image_storage_folder, [scene_name, '.mat']);
    I_syn = load(image_source_full_path);
    switch velocity.distribution
        case 'gaussian'
            tic
            Generate_VisualStim_And_VelEstimation_GiveScene_RandomVel(I_syn.I, scene_name, velocity,...
                'kernel_extraction_method', kernel_extraction_method, 'seed_num', seed_num)
            toc
            
        case 'binary'
            tic
            Generate_VisualStim_And_VelEstimation_GiveScene(I_syn.I, scene_name, velocity,...
                'kernel_extraction_method', kernel_extraction_method, 'seed_num', seed_num, 'storage_filename', image_property)
            toc
    end
    file_save_folder = ['D:\Natural_Scene_Simu\',which_kernel_type];
    if  ~exist(file_save_folder, 'dir')
        mkdir(file_save_folder);
    end
    movefile('D:\Natural_Scene_Simu\visual_stimulus',   file_save_folder);
    
    %% move the file into correct position.
end

if analyze_data_flag
    
    spatial_average_flag = true;
    synthetic_type_bank = {[],  image_property};
    num_ns = 1 ;
    visual_stimulus_relative_path = synthetic_type_bank;
    visual_stimulus_relative_path{num_ns} = 'nsFWHM25';
    
    %% load data
    n_data_set = length(synthetic_type_bank);
    data_set = cell(n_data_set, 1);
    for ii = 1:1:n_data_set
        data = Analysis_Utils_GetData_OneRowAllPhase_GauVel(visual_stimulus_relative_path{ii},...
            which_kernel_type,'spatial_average_flag', spatial_average_flag);
        data_set{ii} = Analysis_Utils_GetAllData_EnforceSymmetry(data);
        
    end
    %% plot
    color_different_scenes = brewermap(2, 'Accent');
    MakeFigure;
    subplot(2,2,1)
    hold on
    mean_v2_store = cell(2, 1);
    for ii = [1,2]
        mean_v2 = mean(data_set{ii}.v2, 2);
        std_v2 = std(data_set{ii}.v2, 1, 2);
        v_real = data_set{ii}.v_real(:,1);
        
        % sort v_real.
        [v_real_sort, idx_sort] = sort(v_real);
        mean_v2_sort = mean_v2(idx_sort);
        mean_v2_store{ii} = mean_v2_sort;
        std_v2_sort = std_v2(idx_sort);
        
        PlotXvsY(v_real_sort, mean_v2_sort,'error', std_v2_sort,...
            'graphType', 'line','color',color_different_scenes(ii,:));
        
    end
    plot(v_real_sort, mean_v2_store{1},'color',color_different_scenes(1,:));
    ConfAxis
    set(gca, 'XAxisLocation','origin', 'YAxisLocation', 'origin');
    legend('natural scene', image_property)
    set(gca, 'YTick',[]);
    Velocity_ScatterPlot_Utils('image velocity [deg/sec]', ylabel_str, 'XTick', [-1000,-500,500,1000], 'xLim', [-1100, 1100]);
end

