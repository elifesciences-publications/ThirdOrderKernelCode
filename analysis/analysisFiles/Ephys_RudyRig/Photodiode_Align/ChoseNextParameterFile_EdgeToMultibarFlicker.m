function parameter_file_next = ChoseNextParameterFile_EdgeToMultibarFlicker(genotype, parameter_file)
% search for the file to use...
% first, search for newest data.
sysConfig = GetSystemConfiguration;

%% find the folder of current data.
latest_folder = FindTheLatestFolder(genotype, parameter_file);
probe_data = dir(fullfile(latest_folder,'*.ibw')); % check whether there is ibw file. if not. run...
if isempty(probe_data)
    % it is possible that the currect response is not organized into
    % correct folder. move the latest igor data into datapath.
    IgorFolder = uigetdir(sysConfig.igor_start_path);
    CopyDataFromIgorFileToDataFile(latest_folder, IgorFolder);
end

%% align the response with stimulus and organize the response by epoch and trial
data_path = latest_folder;
[response, ~, epoch_list] = ReadEphysRudyData(data_path);
[resp_time_by_epoch_by_trial, epoch_info] = PlotEdgeResponse(response, epoch_list);

%% test which edges do the cell respond the most and decide which parameter to use. The function here can be changed in the future
parameter_file_next = UseEdgeToChooseMultibarType(epoch_info, resp_time_by_epoch_by_trial);

end

function latest_folder = FindTheLatestFolder(genotype, parameter_file)
sysConfig = GetSystemConfiguration;
[~, parameter_file_name] = fileparts(parameter_file);
data_path_root = fullfile(sysConfig.rudy_ephys_data_path, genotype, parameter_file_name);% might be one minute difference...

% collect all the folder for this genotype and this parameterfile.
sub_folder = regexp(genpath(data_path_root),['[^;]*'],'match');
length_folder = cellfun(@(s)length(s),sub_folder);
sub_folder(length_folder < max(length_folder)) = [];

% find the latest one
folder_date = cellfun(@(s)getdate(s),sub_folder);
[~,latest_folder_ind] = max(folder_date);
latest_folder = sub_folder{latest_folder_ind};

end

function time_num = getdate(s)
a = strsplit(s,filesep);
b = strjoin(a(end-2:end),'_');
time_num = datenum(b,'yyyy_mm_dd_HH_MM_SS');
end

function parameter_file_next = UseEdgeToChooseMultibarType(epoch_info, resp_time_by_epoch_by_trial)
dataRate = 10000;
responsive_time_est = 1 * dataRate; % around 1 second? estimate how long of the response should be accounted as effective.  might be changed in the future.

%% get the representative response from each epoch
n_epoch = length(epoch_info);
edge_response = zeros(n_epoch,1); % the average value of the m
for ee = 1:1:n_epoch
    pcr_eff_time = responsive_time_est/epoch_info(ee).length;
    % depolarization. check the largest response ??????????????
    edge_response(ee) = mean(cellfun(@(time_trace) mean(prctile(time_trace,(1 - pcr_eff_time) * 100)), resp_time_by_epoch_by_trial{ee}));
end

%% pool from 4 edges to represent hor and ver
left_right_epoch = [1,2,3,4];
up_down_epoch = [5,6,7,8];
left_right_response = max(edge_response(left_right_epoch));
up_down_response = max(edge_response(up_down_epoch));

%% which is larger
if up_down_response > left_right_response
    computer_judgement = 'Up & Down';
else
    computer_judgement = 'Left & Right';
end

%% visualize the response. and ask human beings on which is larger.
MakeFigure;
epoch_string = {'Right Light Edge',	'Right Dark Edge',	'Left Light Edge',	'Left Dark Edge',	'Up Light Edge'	'Up Dark Edge',	'Down Light Edge',	'Down Dark Edge'};
%This is hard coded...
for tt = 1:1:2
    subplot(2,1,tt);
    % collect all response. plot them and label them.
    finish_t = 0;
    for ee = 1:1:n_epoch
        x_range = finish_t + 1: finish_t + length(resp_time_by_epoch_by_trial{ee}{tt});
        hold on
        plot(x_range, resp_time_by_epoch_by_trial{ee}{tt});
        finish_t = x_range(end);
        % do the label.
        text(x_range(1), 0, epoch_string{ee});
    end
end
urs_judgement = questdlg('Which edges do the cell respond?', 'Chose Next Parameter File','Up & Down','Left & Right','Not Sure','Not Sure');


%% use human beings and computer to make a final judgement.
if strcmp(urs_judgement, computer_judgement )
    decision = urs_judgement;
else
    % If there is a conflict, ask again and double check.
    urs_judgement_second = questdlg(['Computer Choose ', computer_judgement, ', What is your feeling?'], 'Conflict with Computer',...
        'Up & Down','Left & Right','Do Edge Again','Do Edge Again');
    decision = urs_judgement_second;
end


%% choose which file to tun according to judgement above.
switch decision
    case 'Left & Right' % do vertical multibar
        parameter_file_next = 'C:\psycho5\paramfiles\multiBarFlicker\multiBarFlicker_20_repBlock_60hz_vertical_2_28.txt';
    case 'Up & Down' % do horizontal multibar
        parameter_file_next = 'C:\psycho5\paramfiles\multiBarFlicker\multiBarFlicker_20_repBlock_60hz_horizontal_2_28.txt';
    case 'Do Edge Again' % do edge response again.
        parameter_file_next = 'C:\psycho5\paramfiles\Emilio\comboStims\edgesOrthoDirsOnGray.txt';
end
end

function [resp_time_by_epoch_by_trial,epoch_info] = PlotEdgeResponse(resp, epoch_list)
% response for different epoch
n_epoch  = max(unique(epoch_list));
epoch_start_end_ind_struct = struct('epoch_name',[], 'n_trial',[], 'start',[], 'end',[],'length',[]);
epoch_info = repmat(epoch_start_end_ind_struct, n_epoch,1);
for ee = 1:1:n_epoch
    epoch_info(ee).epoch_name = ee;
    % check how many trials....
    diff_epoch_list = diff([0;epoch_list] == ee);
    start_ind = find(diff_epoch_list == 1);
    end_ind = find(diff_epoch_list == -1) - 2; %
    start_ind = start_ind(1:length(end_ind)); % only include trials which has finishing time.
    
    epoch_info(ee).n_trial = length(start_ind);
    epoch_info(ee).start = start_ind;
    epoch_info(ee).end = end_ind;
    epoch_info(ee).length = end_ind - start_ind  + 1;% different!!! why?
end
% why does the length have different value? by drop of the frame?

resp_time_by_epoch_by_trial = cell(n_epoch, 1);
for ee = 1:1:n_epoch
    n_trial = epoch_info(ee).n_trial;
    resp_time_by_epoch_by_trial{ee} = cell(n_trial, 1); % some times the trial does not have the same length. chop it randomly here?
    for tt = 1:1:n_trial
        % time traces.
        resp_time_by_epoch_by_trial{ee}{tt} = resp(epoch_info(ee).start(tt): epoch_info(ee).end(tt));
    end
end

end


