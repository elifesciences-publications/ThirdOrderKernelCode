function [stim, pos] = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con_SmoothStim(oneRow, v_real, time, f, varargin)
dt_tf = 0.002; % 1 ms ? might be too small? not sure...if it is too slow, change it to 2 ms.
dt_sample = 1/60;
space_range = 54;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% resample the one row, on the sampling rate, and then 
v_real = - v_real;
dx_tf = v_real * dt_tf;

x0 = v_real * dt_sample * (0:1: time.n - 1)'; % second.
n_f = length(f);
x_shifted = (0:1:n_f - 1) * dx_tf;

x_position = bsxfun(@plus, x0, x_shifted); % find the corresponding index. that's all.. first
x_position_one_period = mod(x_position, 360);
x_position_ind_base = floor(x_position_one_period/(360/927)) + 1;


n_hor = length(oneRow);
pos_reference = randi(n_hor);

pos_reference = 838;
pos = pos_reference + [0:1:space_range - 1]' * 13;
pos = mod(pos - 1, n_hor) + 1; % periodic 360 degree.


stim = zeros(time.n, space_range);
for pp = 1:1:space_range
    x_position_ind_this = x_position_ind_base + pos(pp) - 1;
    x_position_ind_this = mod(x_position_ind_this - 1, n_hor) + 1;
    lum_this = oneRow(x_position_ind_this);
    stim_mean = lum_this * f;
    stim(:,pp) = (lum_this(:,end) - stim_mean)./ stim_mean;
    stim(lum_this(:,end) == 0,pp) = 0; % if the luminance is zeros. then it is zeros
    % This should be good.
end


end
