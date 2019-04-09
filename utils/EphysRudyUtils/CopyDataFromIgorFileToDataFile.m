function CopyDataFromIgorFileToDataFile(data_to_this_path, IgorFolder)
% the folder it should be going
% IgorFolder = 'C:\Users\rblab\Documents\experiments\';
n_channel  = 2;
for cc = 1:1:n_channel
    data_path_psycho5 = fullfile(data_to_this_path,[['ch',num2str(cc - 1),'.ibw']]);
    % the current folder.
    latest_data_path_Igor = getIgorData(IgorFolder, cc - 1);
    copyfile(latest_data_path_Igor, data_path_psycho5);
end

end

function lastest_filename  = FindTheLastestFile(all_ibw)
% find the latest for ch0;
all_file_name = {all_ibw.name};
all_file_number = cellfun(@(name) str2double(name(5:end-4)), all_file_name);
[~,lastest_ind] = max( all_file_number );
lastest_filename = all_file_name{lastest_ind};

end

function latest_data_path_Igor = getIgorData(IgorFolder, channel_num)
all_ibw = dir(fullfile(IgorFolder, ['ch',num2str(channel_num),'_*.ibw']));
lastest_filename = FindTheLastestFile(all_ibw);
latest_data_path_Igor = fullfile(IgorFolder,lastest_filename);

end