function  ReExtractKernels_Main_Temp(varargin)

MainName = 'behavior_kernel_arma';
process_stim_flag  = false;
FWHM = 0;

% kernel related parameter
order = 2;
noise = 0;
maxTau = 64;

dx = 0;
arma_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

MainName = behavior_kernel_utils_create_name(process_stim_flag, FWHM, order, dx, MainName);
S = GetSystemConfiguration;
data_holly_folder = S.behavior_kernel_data_path;
data_folder_relative_path = findkerneldata_relativepath(data_holly_folder);

% separate nMultiBars 3 and 4. how?
behavior_kernel = cell(2,1); % 3 bars and 4 bars.
averaged_kernel = cell(2,1);
nMultiBars_bank = [3,4];
for ss = 1:1:2
    data_folder_relative_path_this_stimfun = data_folder_relative_path{ss};
    behavior_kernel_this_stimfun = [];
    nMultiBars = nMultiBars_bank(ss);
    
    for ff = 1:1:length(data_folder_relative_path_this_stimfun)
        % for each file.
        datafolder = fullfile(data_holly_folder, data_folder_relative_path_this_stimfun{ff});
        kernel_this_file = BehaviorKernelExtraction_Temp(datafolder , 'nMultiBars',nMultiBars,...
            'process_stim_flag', process_stim_flag, 'FWHM', FWHM, 'order', order, 'noise', noise, 'maxTau', maxTau, 'dx', dx, 'arma_flag', arma_flag);
        
        kernel_info.path = datafolder;
        kernel_info.kernel = kernel_this_file;
        
        % do this for each fly.
        behavior_kernel{ss} = [behavior_kernel{ss};kernel_info];
        % do you want to store the data? yes, for sure.. inside the function...
    end
    
    % summarize all data.
    all_kernel_this = cat(2,  behavior_kernel{ss}.kernel);
    averaged_kernel{ss} = mean(all_kernel_this, 2);
end



%% Make the name.
% for ss = 1:1:2
%     MakeFigure;
%     quickViewCovMat(averaged_kernel{ss}, 'nMultiBars', nMultiBars_bank(ss));
%     MySaveFig_Juyue(gcf,MainName, num2str(nMultiBars_bank(ss)),'nFigSave',2,'fileType',{'png','fig'});
% end

save(MainName,'behavior_kernel', 'averaged_kernel')

% data.kernel_individual_file = behavior_kernel;
% data.kernel_average =
% data.kernel_param =


% save the data.
end

