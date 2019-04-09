function K2_CovarianceMatrix_Visualization_dx_dt_ft_plot(fft_dx_dt, dt_bank, dx_bank)
quickViewOneKernel(fft_dx_dt,1, 'labelFlag',false);
xlim = get(gca,'XLim');
ylim = get(gca,'YLim');
hold on
dt_middle_line = ceil(length(dt_bank)/2);
plot(xlim,[dt_middle_line,dt_middle_line],'k-');
dx_middle_line = ceil(length(dx_bank)/2);
plot([dx_middle_line,dx_middle_line],ylim,'k-');
xlabel('f(cycle in space)');
ylabel('f(Hz in time)');

% get the unit of frequency correctly.
Fs_t = 60; % 60 Hz.
L_t = length(dt_bank); % length of signal.
f_unit = Fs_t/L_t; % 3.75 Hz. every unit. dt.. not very large. you can do better.
set(gca,'YTick',1:length(dt_bank),'YTickLabel',strsplit(num2str(dt_bank * f_unit)));

Fs_s = 360/5; % 72Hz.
L_s = length(dx_bank);
v_unit = Fs_s/L_s;
set(gca,'XTick', 1:length(dx_bank), 'XTickLabel', strsplit(num2str(dx_bank *v_unit)));
ConfAxis
end