function data_folder_relative_path = findkerneldata_relativepath(kernel_holly_folder)

% kernel_holly_folder = 'D:\kernels\HollyOldData\gliders_and_kernel\kernel_data_record\kernels';

root_folder = kernel_holly_folder;
stim_folder = findsubfolders({root_folder});%loop through each folder. how to you search for all?
% separate 3 and 4.
data_folder_relative_path = cell(length(stim_folder), 1);
for ss = 1:1:length(data_folder_relative_path)
    year_folder = findsubfolders(stim_folder(ss));
    month_folder = findsubfolders(year_folder);
    date_folder = findsubfolders(month_folder);
    data_folder_relative_path{ss}= cellfun(@(x) x(length(kernel_holly_folder)+2:end), date_folder, 'UniformOutput', false);
end
end

function sub_folder_all = findsubfolders(rootfolder)

sub_folder_all = [];
for ii = 1:1:length(rootfolder)
    subfolder_info = dir(rootfolder{ii}); subfolder_info = subfolder_info(3:end);
    subfolder_info(~[subfolder_info(:).isdir]) = [];
    subfolder = cellfun(@(x) fullfile(rootfolder{ii}, x), {subfolder_info(:).name}, 'UniformOutput', false);
    sub_folder_all = [sub_folder_all;subfolder'];
end
end