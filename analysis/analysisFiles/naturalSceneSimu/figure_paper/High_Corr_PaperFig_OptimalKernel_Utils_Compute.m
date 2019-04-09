function kernel_glider_format = High_Corr_PaperFig_OptimalKernel_Utils_Compute(kernel_extraction_method_bank,corr_type_str_2o,corr_type_str_3o)
% kernel_extraction_method_bank = {'reverse_correlation','extra_input','four_quadrant','non_multiplicative','unrestricted'}; % same as the unrestricted.

dt_time = 1/60;
tMax = 48;
%% plot the behavior behavior consistency...
% for any glider response, find the corrparam....
%%
%% for a given third order kernel, compute the corresponding kernel prediction.
kernel_glider_format = cell(5, 1); % first will be real kernel.
% kernel_glider_format = cell()
for ii = 1:1:5
    kernel_extraction_method = kernel_extraction_method_bank{ii};
    kernel = Load_Kernel_For_NS(false , false, kernel_extraction_method, 'full_kernel_flag', true);
    
    kernel_glider_format_third = High_Corr_PaperFig_OptimalKernel_Utils_Compute_K3(kernel.k3_sym(:), corr_type_str_3o, tMax);
    kernel_glider_format_second = High_Corr_PaperFig_OptimalKernel_Utils_Compute_K2(kernel.k2_sym(:), corr_type_str_2o, tMax);
    kernel_glider_format_second = - kernel_glider_format_second; % change to response to right direction.

    % get the unit correct.
    kernel_glider_format_third_units = kernel_glider_format_third/(dt_time)^3;
    kernel_glider_format_second_units = kernel_glider_format_second/(dt_time)^2;

    % normalize everything by second.
    kernel_glider_format_second_norm = kernel_glider_format_second_units/(kernel_glider_format_second_units(1));
    kernel_glider_format_third_norm = kernel_glider_format_third_units/(kernel_glider_format_second_units(1));
    kernel_glider_format{ii} =  cat(1, kernel_glider_format_second_norm, kernel_glider_format_third_norm);
end
end



function k2_resp =  High_Corr_PaperFig_OptimalKernel_Utils_Compute_K2(k2, corr_type_str_2o, tMax)
n_corr_2 = length(corr_type_str_2o);
k2_resp = zeros(n_corr_2, 1); % get the individual flies respons.
for ii = 1:1:n_corr_2
    % organize the kernel thing,
    glider_name_this = corr_type_str_2o{ii};
    dt = K2_Glider_Trans_Utils_Name_To_Tau(glider_name_this);
    corrParam{1}.dt = dt;
    [k2_resp(ii),~] =  K2ToGlider_One_CorrType(k2(:),  corrParam, 'tMax', tMax);
end
end

function k3_resp =  High_Corr_PaperFig_OptimalKernel_Utils_Compute_K3(k3, corr_type_str_3o, tMax)
dx_bank  =  {[0,1],[0,-1]};
third_kernel_behavior{1} = k3;
third_kernel_behavior{2} = - k3;
n_corr_3 = length(corr_type_str_3o);
k3_resp = zeros(n_corr_3, 1); % get the individual flies respons.
% tMax = 48;
tMax = 48;
for ii = 1:1:n_corr_3
    % organize the kernel thing,
    glider_name_this = corr_type_str_3o{ii};
    
    [dx, dt] = K3_Glider_Trans_Utils_Name_To_TauDx( glider_name_this);
    dx_which = cellfun(@(x) isequal(x, dx), dx_bank);
    corrParam = cell(1,1);
    corrParam{1}.dt = dt;
    [k3_resp(ii),~] =  K3ToGlider_One_CorrType(third_kernel_behavior{dx_which}(:),  corrParam,'tMax', tMax);
end
end