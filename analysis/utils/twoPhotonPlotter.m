function twoPhotonPlotter(plot_title, data_for_plotting, steps_back, fs, epoch, figure_handle, Z, varargin)
%This function takes in the data to be plotted and does so in nice figures

plot_rois = true;
combine_plots = false;

% Receive input variables
for ii = 1:2:length(varargin)
    %Remember to append all new varargins so old ones don't overwrite
    %them!
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

plot_location_ind=1;
if plot_rois && combine_plots
    plot_locations = {{1, 2, 1}, {1, 2, 2}};
elseif combine_plots
    plot_locations = {{1, 1, 1}};
else
    plot_locations = {{2, 1, 1}, {2, 2, 3}, {2, 2, 4}};
end


for i = 1:size(data_for_plotting, 1)
    roi_legend_entry{i} = ['ROI ' num2str(i)];
end

%Here we save the image with the rois drawn on top
%The +2 is for the trigger data and averaged data when plotting below
%as well as the background data for ROI purposes
figure(figure_handle)
% colors = colormap(jet(num_rois+3));
colors = lines(size(data_for_plotting, 1)+2);
if plot_rois
    subplot(plot_locations{plot_location_ind}{:})
    plot_location_ind = plot_location_ind+1;
    colormap(gray(256))
    imagesc(roi_image);
    axis off
    hold on
    roi_legend_entry{end+1} = 'Background ROI';
    for i = 1:length(roi_data.points)
        x = roi_data.points{i}(:, 1);
        y = roi_data.points{i}(:, 2);
        %It's colors(i+2) because of how the plotting works later on;
        %this allows the roi colors to match the signal trace colors
        plot(x, y, 'Color', colors(i+2,:));
    end
    legend(roi_legend_entry);
end
% if plot_rois
%     x_back = roi_data.points{end}(:, 1);
%     y_back = roi_data.points{end}(:, 2);
%     plot(x_back, y_back, 'Color', colors(i+3,:));
%     roi_legend_entry{end+1} = 'Background ROI';
%     legend(roi_legend_entry);
%     hold off
% end

%This -1 isn't magical, it works to align at zero. It has to do with
%how the steps_back affect the indexes and length
t_vals = linspace(-steps_back/fs, (size(data_for_plotting,2)-steps_back-1)/fs,size(data_for_plotting, 2));

subplot(plot_locations{plot_location_ind}{:})
plot_location_ind = plot_location_ind+1;
hold on
trace_dists = diff(data_for_plotting(2:end, :));
if combine_plots
    plot_sep = 2*mean(max(trace_dists)-min(trace_dists));
else
    plot_sep = 0;
end
% plot_sep = 2*max(trace_dists(:));
legend_plots = [];
for j = 1:size(data_for_plotting, 1)
    legend_plots(j) = plot(t_vals, data_for_plotting(j, :)+plot_sep*(j-1), '-', 'Color', colors(j+2, :));
    plot(t_vals, plot_sep*(j-1)*ones(size(t_vals)), ':', 'Color', colors(j+2, :))
end

epoch_name = epoch;
epoch_name(epoch == '_') = ' ';
epochNum = str2double(epoch_name(find(epoch_name == ' ')+1:end));
plot_title(plot_title=='_') = ' ';
params = Z.stimulus.params;
if length(params)>=epochNum && isfield(params, 'epochName') && ~isempty(params(epochNum).epochName)
    plot_title = sprintf('%s\n%s', plot_title, params(epochNum).epochName);
else
    plot_title = sprintf('%s\n%s', plot_title, epoch_name);
end

title(plot_title);
xlabel('Time (s)');
ylabel('Amplitude (\Delta F/F)');
%We're not plotting the background, but I'm pretty sure Matlab will
%just ignore the extra entry!
if ~combine_plots
    legend(legend_plots, roi_legend_entry);
    hold off
elseif plot_rois
    roi_legend_entry(end) = [];
end

if combine_plots
    shift_down = plot_sep;
else
    shift_down = 0;
end

if ~combine_plots
    subplot(plot_locations{plot_location_ind}{:})
    plot_location_ind = plot_location_ind+1;
end


std_kernels = std(data_for_plotting, 0, 1);
sem_kernels = std_kernels/sqrt(size(data_for_plotting, 1));

sem_plot_x = t_vals;
sem_plot_y = mean(data_for_plotting, 1)-shift_down;
sem_plot_e = sem_kernels;
%Pretty sure this makes color_1 slightly darker than color_2
color_1  = colors(1, :) + (1-colors(1,:))*0.1;
color_2 = colors(1, :);

% legend_plots(end+1) = plot_err_patch(sem_plot_x, sem_plot_y, sem_plot_e, color_1);
hold on
if ~combine_plots
%     legend('Averaged Intensities');
else
    legend(legend_plots, [roi_legend_entry 'Averaged Intensities']);
end

%     plot(linspace(0, length(avg_triggered_intensities)/fs,length(avg_triggered_intensities)), avg_triggered_intensities(1, :), 'Color', colors(1, :))
%     plot(linspace(-steps_back/fs, (length(avg_triggered_intensities)-steps_back-1)/fs,length(avg_triggered_intensities)), scaled_avg, 'Color', colors(2, :))
xlabel('Time (s)')
title(sprintf('%s\n%s', plot_title, epoch_name));

hold off
