function edge_type_selected = Analysis_Function_Imaging_Quality_T4T5_Statistics_Draft(file_paht_all, kernel_identifier)
nfile = length(file_path_all);
roi_selected = cell(nfile, 1);
edge_type_all = cell(nfile, 1);
roi_data_all = cell(nfile,1);
for ff = 1:1:nfile
    % for one particular fly
    filepath = file_path_all{ff};
    roi_selected_this = Analysis_Function_RoiSelection_V1_Draft(filepath, kernel_identifier);
    roi_data_this = Analysis_Function_Loading_Draft(filepath,kernel_identifier,'which_data','roi_data_edge_only');
    edge_type_this = cellfun(@(roi) roi.typeInfo.edgeType, roi_data_this);
    
    roi_selected{ff} = roi_selected_this;
    edge_type_all{ff} = edge_type_this;
    roi_data_all{ff} = roi_data_this;
end
roi_data_all = cat(3,roi_data_all{:})
roi_data_selected = cellfun(@(edge_type, roi_selected) edge_type(roi_selected), roi_data_all,roi_selected, 'UniformOutput', false);
numStat = roiAnalysis_FlyRoiKernelStat(roi_data_this,'sortMethod','flyId');
% edge_type_selected = cellfun(@(edge_type, roi_selected) edge_type(roi_selected), edge_type_all,roi_selected, 'UniformOutput', false);
% you do not like this calculation.
% overall... or individual...

%% look at how many of them are used...