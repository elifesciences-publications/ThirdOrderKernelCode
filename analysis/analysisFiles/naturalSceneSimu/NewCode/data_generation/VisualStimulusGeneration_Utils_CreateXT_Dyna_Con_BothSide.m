function stim= VisualStimulusGeneration_Utils_CreateXT_Dyna_Con_BothSide(oneRow, v_real, time, f, pos, varargin)
dt_tf = 0.002; % 1 ms ? might be too small? not sure...if it is too slow, change it to 2 ms.
dt_sample = 1/60;
space_range = 54;
n_hor = length(oneRow);
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
f_double_sided = [f; flipud(f(1:end - 1))];
f_double_sided = f_double_sided/sum(f_double_sided);
% resample the one row, on the sampling rate, and then 
v_real = - v_real;
dx_tf = v_real * dt_tf;

x0 = v_real * dt_sample * (0:1: time.n - 1)'; % second.
n_f = length(f);
% x_shifted = (0:1:n_f - 1) * dx_tf;
x_shifted_double_sided = (0:1:n_f * 2 - 1 -1) * dx_tf;

x_position = bsxfun(@plus, x0, x_shifted_double_sided); % find the corresponding index. that's all.. first
x_position_one_period = mod(x_position, 360);
x_position_ind_base = floor(x_position_one_period/(360/927)) + 1;


% pos = VelocityEstimation_SelectPos('space_range', space_range, 'synthetic_flag', synthetic_flag);


stim = zeros(time.n, space_range);
for pp = 1:1:space_range
    x_position_ind_this = x_position_ind_base + pos(pp) - 1;
    x_position_ind_this = mod(x_position_ind_this - 1, n_hor) + 1;
    lum_this = oneRow(x_position_ind_this);
    stim_mean = lum_this * f_double_sided;
    stim(:,pp) = (lum_this(:,length(f)) - stim_mean)./ stim_mean;
    % This should be good.
end

end
