function  [data, data_mean,  roi_data, roiSelected] = Analaysis_Function_Get_Mean(file_path_all, kernel_identifier, kernel_to_get_string)
% cov_mat_noise will be too large to show
nfile = length(file_path_all);
roiSelected = cell(nfile, 1); % true;
% n_noise = 100; % hard coded.
roi_data_selected = cell(nfile,1);

if strfind(kernel_to_get_string, 'noise')
    n_noise = 100;
else
    n_noise = 1;
end
% this would have a lot of term. 1 hour finish this function...
data_selected = cell(n_noise,1);
for nn = 1:1:n_noise
    data_selected{nn} = cell(nfile, 1);
end
data_mean = cell(n_noise, 1); % should turn to matrix structure;
data = cell(n_noise,1); % matrix structure;
% cov_mat_noise = cell(n_noise, 1); cov_mat__mean_noise = cell(n_noise, 1);
for ff = 1:1:nfile
    % for one particular fly
    filepath = file_path_all{ff};
    try
        roiSelected_this = Analysis_Function_RoiSelection_V1_Draft(filepath, kernel_identifier);
        roi_data_this = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','roi_data_edge_only');
        nROI_selected = sum(roiSelected_this);
        roi_data_selected_this = roi_data_this(roiSelected_this);
        
        %%
        if nROI_selected > 0
            if strcmp(kernel_to_get_string,'second_noise')
                % calculate data_selected_this directly...
                data_selected_this = Analysis_Function_Temp_Kernel_Extraction(filepath, kernel_identifier, 'second_noise', roiSelected_this);
            else
                data_this = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data', kernel_to_get_string);
                data_selected_this = cell(n_noise, 1);
                for nn = 1:1:n_noise
                    data_selected_this{nn} = data_this{nn}(:,:,roiSelected_this);
                end
            end
            % for the third order kernel. mirror kernel has to be extracted
            % for alignment
            if strfind(kernel_to_get_string, 'third')
                kernel_to_get_string_mirror = kernel_path_management_utils_3okernel_string_mirror(kernel_to_get_string);
                data_this_mirror = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data', kernel_to_get_string_mirror);
                data_selected_this_mirror = cell(n_noise, 1);
                for nn = 1:1:n_noise
                    data_selected_this_mirror{nn} = data_this_mirror{nn}(:,:,roiSelected_this);
                end
            end
        end
        
        %% align the selected kernel
        data_algined_selected_this = cell(n_noise, 1);
        for nn = 1:1:n_noise
            %% align here or not. for average, you have to align, you are not selecting data, you are get mean value.
            data_algined_selected_this{nn} = cell(nROI_selected ,1);
            for rr = 1:1:nROI_selected
                if strfind(kernel_to_get_string, 'third')
                    data_algined_selected_this{nn}{rr} = Roi_Center_Alignment_ThirdOrderKernel...
                        (roi_data_selected_this{rr},data_selected_this{nn}(:,:,rr), data_selected_this_mirror{nn}(:,:,rr));
                else
                    data_algined_selected_this{nn}{rr} = Roi_Center_Alignment_Kernel(roi_data_selected_this{rr},data_selected_this{nn}(:,:,rr),  kernel_to_get_string);
                    
                end
                data_selected{nn}{ff} = data_algined_selected_this{nn};
            end
        end
        roi_data_selected{ff} = roi_data_selected_this;
        roiSelected{ff} = roiSelected_this;
    catch err
    end
end % this step takes some time, how to optimize it?

%% these are all the flies you have.
% you also want to remember the selected kernels.
% before mean value.
roi_data = cat(1, roi_data_selected{:});
for nn = 1:1:n_noise
    data_this_shuffle = data_selected{nn};
    data{nn} = cat(1,data_this_shuffle{:});
end

edgeType = cellfun(@(roi) roi.typeInfo.edgeType, roi_data);
nType = 4;
for nn = 1:1:n_noise
    data_mean{nn} = cell(nType,1);
    for tt = 1:1:nType
        ind_this_type = edgeType == tt;
        data_this_type_cell_this_shuffle = data{nn}(ind_this_type); data_this_type_this_shuffle = cat(3, data_this_type_cell_this_shuffle{:});
        data_mean{nn}{tt} = mean(data_this_type_this_shuffle,3);
    end
end