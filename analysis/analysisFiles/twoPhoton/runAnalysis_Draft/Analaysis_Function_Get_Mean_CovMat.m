function  [cov_mat_mean, roi_data, cov_mat, cov_mat_mean_noise, cov_mat_noise] = Analaysis_Function_Get_Mean_CovMat(file_path_all, kernel_identifier, cov_mat_noise_flag)
% cov_mat_noise will be too large to show...
nfile = length(file_path_all);
roiSelected = cell(nfile, 1);
n_noise = 100; % hard coded.
%% load the roi_data_edge_only, to get DSI, ESI, repeatability and edgeType.

cov_mat_selected = cell(nfile,1);
roi_data_selected = cell(nfile,1);

%
cov_mat_mean = []; % should turn to matrix structure;
cov_mat = []; % matrix structure;
% cov_mat_noise = cell(n_noise, 1); cov_mat__mean_noise = cell(n_noise, 1);

if ~cov_mat_noise_flag
    cov_mat_mean_noise = [];
    cov_mat_noise = [];
else
    cov_mat_noise = cell(n_noise, 1); % every shuffled, will have nfile.
    cov_mat_noise_selected = cell(n_noise,1);
    cov_mat_mean_noise = cell(n_noise, 1);
    for nn = 1:1:n_noise
        cov_mat_noise_selected{nn} = cell(nfile, 1);
    end
    
end
for ff = 1:1:nfile
    % for one particular fly
    filepath = file_path_all{ff};
    
    try
    roiSelected_this = Analysis_Function_RoiSelection_V1_Draft(filepath, kernel_identifier);
    roi_data_this = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','roi_data_edge_only');
    cov_mat_this = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','second');
    
    %% compute the cov_mat_selected...
    nROI_selected = sum(roiSelected_this);
    roi_data_selected_this = roi_data_this(roiSelected_this);
    cov_mat_selected_this = cov_mat_this(:,:,roiSelected_this);
    % align the covmat, and make it into cell structure.
    cov_mat_algined_selected_this = cell(nROI_selected ,1);
    for rr = 1:1:nROI_selected
        cov_mat_algined_selected_this{rr} = Roi_Center_Alignment_CovMat(roi_data_selected_this{rr},cov_mat_selected_this(:,:,rr));
    end
    
    if cov_mat_noise_flag
        % laod it
        tic
        cov_mat_noise_this = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','second_noise'); % if loading is slo
        toc
        cov_mat_noise_selected_this = cell(n_noise,1);
        for nn = 1:1:n_noise
            % for every noise. first, decide whether it is selected.
            cov_mat_noise_selected_this{nn} = cov_mat_noise_this{nn}(:,:,roiSelected_this);
        end
        clear cov_mat_noise_this
        % align it.
        cov_mat_noise_algined_selected_this = cell(n_noise,1);
        tic
        for nn = 1:1:n_noise
            cov_mat_noise_algined_selected_this{nn} = cell(nROI_selected,1);
            for rr = 1:1:nROI_selected
                cov_mat_noise_algined_selected_this{nn}{rr} = Roi_Center_Alignment_CovMat(roi_data_selected_this{rr},cov_mat_noise_selected_this{nn}(:,:,rr));
            end
        end
        toc % 30 seconds.
        
    end
    
    %% collect all flies.
    cov_mat_selected{ff} = cov_mat_algined_selected_this;
    roi_data_selected{ff} = roi_data_selected_this;
    roiSelected{ff} = roiSelected_this;
    
    if cov_mat_noise_flag
        for nn = 1:1:n_noise
            cov_mat_noise_selected{nn}{ff} =  cov_mat_noise_algined_selected_this{nn};
        end
    end
    catch err
        Analysis_Function_ErrorReport(filepath, err);
    end
end % this step takes some time, how to optimize it?

% why do you missed so many of them?? think about it...
%% these are all the flies you have.
% every cov_mat is a cell! easier!
cov_mat = cat(1,cov_mat_selected{:}); %
roi_data = cat(1, roi_data_selected{:});

% start average...
edgeType = cellfun(@(roi) roi.typeInfo.edgeType, roi_data);
nType = 4;
cov_mat_mean = cell(4,1);
for tt = 1:1:nType
    ind_this_type = edgeType == tt;
    cov_mat_this_type_cell = cov_mat(ind_this_type); cov_mat_this_type = cat(3, cov_mat_this_type_cell{:});
    cov_mat_mean{tt} = mean(cov_mat_this_type,3);
end
% you also want to remember the selected kernels.
if cov_mat_noise_flag
    % before mean value.
    for nn = 1:1:n_noise
        cov_mat_this_shuffle = cov_mat_noise_selected{nn};
        cov_mat_noise{nn} = cat(1,cov_mat_this_shuffle{:});
    end
    for nn = 1:1:n_noise
        cov_mat_mean_noise{nn} = cell(nType,1);
        for tt = 1:1:nType
            ind_this_type = edgeType == tt;
            cov_mat_this_type_cell_this_shuffle = cov_mat_noise{nn}(ind_this_type); cov_mat_this_type_this_shuffle = cat(3, cov_mat_this_type_cell_this_shuffle{:});
            cov_mat_mean_noise{nn}{tt} = mean(cov_mat_this_type_this_shuffle,3);
        end
    end
end

% 
save('data_for_sig_test_all','cov_mat_mean', 'roi_data', 'cov_mat', 'cov_mat_mean_noise', 'cov_mat_noise','-v7.3');