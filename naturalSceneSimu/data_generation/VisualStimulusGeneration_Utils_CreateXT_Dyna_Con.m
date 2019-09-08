function stim = VisualStimulusGeneration_Utils_CreateXT_Dyna_Con(oneRow, v_real, time, f, column_pos, varargin)
dt_tf = 0.002; % 1 ms ? might be too small? not sure...if it is too slow, change it to 2 ms.
dt_sample = 1/60;
space_range = 54;
n_hor = length(oneRow);
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
v_real = - v_real;
dx_tf = v_real * dt_tf;

x0 = v_real * dt_sample * (0:1: time.n - 1)'; % second.
n_f = length(f);
x_shifted = (0:1:n_f - 1) * dx_tf;

x_position = bsxfun(@plus, x0, x_shifted); % find the corresponding index. that's all.. first
x_position_one_period = mod(x_position, 360);
x_position_ind_base = floor(x_position_one_period/(360/927)) + 1;

stim = zeros(time.n, space_range);
for pp = 1:1:space_range
    x_position_ind_this = x_position_ind_base + column_pos(pp) - 1;
    x_position_ind_this = mod(x_position_ind_this - 1, n_hor) + 1;
    lum_this = oneRow(x_position_ind_this);
    stim_mean = lum_this * f;
    stim(:,pp) = (lum_this(:,end) - stim_mean)./ stim_mean;
end


end

