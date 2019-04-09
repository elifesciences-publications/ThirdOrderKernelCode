function [glider_str_3o, glider_data, kernel_data] = High_Corr_PaperFig_GliderKernel_Utils_Compute()
load('D:\Natural_Scene_Simu\parameterdata\ori_reverse_correlation.mat')
third_kernel_behavior{1} = (kernel.k3_xxy_ind - kernel.k3_yyx_ind)/2;
third_kernel_behavior{2} = -(kernel.k3_xxy_ind - kernel.k3_yyx_ind)/2;
n_flies_kernel = size(third_kernel_behavior{1},2);
dx_bank  =  {[0,1],[0,-1]};
nMultiBars = 1;
%% plot the behavior behavior consistency...
% for any glider response, find the corrparam....


load('D:\JuyueLog\2017_04_28\cated_with_individual_response.mat'); % catMean is the mean glider response.
catTitles = {'Diverging DT 1','Converging DT 1','Two Point DT 1','Elbow','Late Knight',...
    'Early Knight','Diverging DT 2','Converging DT 2','Elbow Late Break','Elbow Early Break',...
    'Diverging DT 3','Diverging DT 4','Converging DT 3','Converging DT 4','Two Point DT 2', ...
    'Two Point DT 3','Two Point DT 4'};
%% 
glider_str_3o = {'Diverging DT 1','Converging DT 1','Elbow','Late Knight',...
    'Early Knight','Diverging DT 2','Converging DT 2','Elbow Late Break','Elbow Early Break',...
    'Diverging DT 3','Diverging DT 4','Converging DT 3','Converging DT 4'};
n_glider_3o = length(glider_str_3o);
glider_resp_3o = cell(n_glider_3o, 2); % two polarities. positive and negative. positive first.

for ii = 1:1:n_glider_3o
    glider_name_this = glider_str_3o{ii};
    glider_resp_3o(ii,:) = response_separate_polarity(ismember(catTitles,glider_name_this)).individual_resp;
end

glider_resp_3o_mean = cellfun(@(x) mean(x), glider_resp_3o);
glider_resp_3o_std =  cellfun(@(x) std(x), glider_resp_3o);
glider_resp_3o_n =  cellfun(@(x) length(x), glider_resp_3o);
glider_resp_3o_sem =  glider_resp_3o_std./sqrt(glider_resp_3o_n);
glider_resp_3o_p = zeros(size(glider_resp_3o));
for ii = 1:1:size(glider_resp_3o, 1)
    for jj = 1:1:size(glider_resp_3o, 2)
        [~, glider_resp_3o_p(ii,jj)] = ttest(glider_resp_3o{ii,jj});
    end
end
glider_data.mean = glider_resp_3o_mean;
glider_data.sem = glider_resp_3o_sem;
glider_data.std = glider_resp_3o_std;
glider_data.p = glider_resp_3o_p;  % for the combination of positive and negative.
glider_data.n = glider_resp_3o_n;
%% for a given third order kernel, compute the corresponding kernel prediction.
%corrparam.dx
%corrparam.dt
average_over_space_pairs = 54;

k3_resp = cell(n_glider_3o, 1); % get the individual flies respons.
k3_p = zeros(n_glider_3o, 1);
tMax = 48;
for ii = 1:1:n_glider_3o
    % organize the kernel thing,
    glider_name_this = glider_str_3o{ii};
    
    [dx, dt] = K3_Glider_Trans_Utils_Name_To_TauDx( glider_name_this);
    dx_which = find(cellfun(@(x) isequal(x, dx), dx_bank));
    corrParam = cell(1,1);
    corrParam{1}.dt = dt;
    k3_resp{ii,1} = zeros(1, n_flies_kernel);
    
    for jj = 1:1:n_flies_kernel
        [k3_resp{ii}(jj),~] =  K3ToGlider_One_CorrType(third_kernel_behavior{dx_which}(:,jj),  corrParam,'tMax', tMax);
    end
    [~,k3_p(ii)] = ttest(k3_resp{ii});
    k3_resp{ii} = k3_resp{ii} * average_over_space_pairs  * 6; % full kernel!!
    
    % first is always positive.
end

k3_resp_mean = cellfun(@(x) mean(x), k3_resp);
k3_resp_std = cellfun(@(x) std(x), k3_resp);
k3_resp_n = cellfun(@(x) length(x), k3_resp);
k3_resp_sem = k3_resp_std./sqrt(k3_resp_n);

kernel_data.mean = k3_resp_mean;
kernel_data.sem = k3_resp_sem;
kernel_data.p = k3_p;
end