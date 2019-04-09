function SAC_Tmp_Main_First_Second(fpass)

%% extract kernels. from the SAC.
% folder = 'D:\data_sac_calcium';
cell_list = {'cell18828_LE_01_b', 'cell18911_LE_02_a','cell18911_LE_02_b', 'cell18911_LE_03_a', 'cell18911_LE_03_b'};

n_cell = length(cell_list);
first_order_kernel = cell(n_cell, 1);
second_order_kernel = cell(n_cell, 1);

pred_resp = cell(n_cell, 1);
resp = cell(n_cell, 1);
for ii = 1:1:length(cell_list)
    [first_order_kernel{ii},pred_resp{ii}, resp{ii}] = SAC_Tmp_extract_kernel(cell_list{ii}, 1, 1, fpass);
%     [second_order_kernel{ii},~, ~] = SAC_Tmp_extract_kernel(cell_list{ii}, 2, 0, fpass);
end

%% Plot All those kernels, averaged across different rois.
first_order_kernel_across_rois = cell(n_cell, 1);
second_order_kernel_across_rois = cell(n_cell, 1);

for ii = 1:1:n_cell
    first_order_kernel_across_rois{ii} = squeeze(mean(first_order_kernel{ii}, 3));
%     second_order_kernel_across_rois{ii} = squeeze(mean(second_order_kernel{ii}, 3));
end

%%
first_order_kernel_across_rois_mat = cat(3, first_order_kernel_across_rois{:});
quickViewKernelsFirst(first_order_kernel_across_rois_mat);

%% make the axis correct.
for ii = 1:1:n_cell
    subplot(2,3,ii);
    title(cell_list{ii});
    ConfAxis('fontSize', 15);
    box on
end
MySaveFig_Juyue(gcf, 'firstKernels',['fpass', num2str(fpass * 100)],'nFigSave',1,'fileType',{'png'});
% 
%% plot LN.
MakeFigure; 
for ii = 1:1:length(cell_list)
    subplot(2,3,ii)
    resp_ii = resp{ii};
    resp_ii = bsxfun(@minus, resp_ii, mean(resp_ii, 1));
    
    pred_ii = pred_resp{ii};
    pred_ii = bsxfun(@minus, pred_ii, mean(pred_ii, 1));
    SAC_Tmp_LN_Plot(pred_ii(:), resp_ii(:), 50, 10);
    coefficient = corr(pred_ii(:), resp_ii(:));
    text(0.2,0.2,['r = ', num2str(coefficient, 2)], 'FontSize', 15);
    title(cell_list{ii});
    ConfAxis
    
end
MySaveFig_Juyue(gcf, 'firstKernels_LN', ['fpass', num2str(fpass * 100)], 'nFigSave',1,'fileType',{'png'});

%%
second_order_kernel_across_rois_mat = cat(3, second_order_kernel_across_rois{:});
for ii = 1:1:n_cell
   MakeFigure;
   cov_mat_this = second_order_kernel_across_rois_mat(:,:,ii);
   cov_mat_this(eye(size(cov_mat_this, 1)) == 1) =0;
   quickViewCovMat(cov_mat_this, 'nMultiBars', 15);
   title(cell_list{ii});
   MySaveFig_Juyue(gcf, 'Second_Kernels_all',[cell_list{ii},'_fpass', num2str(fpass * 100)],'nFigSave',1,'fileType',{'png'});
end


end