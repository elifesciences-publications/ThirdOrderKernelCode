function [velocity_sequence, col_pos_sequence] = Generate_VisStimVelEst_Utils_WithinScene_GenVel(n_sample,  velocity, varargin)
seed_num  = 0;
n_hor = 927;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% first, column position.
% second, velocity distribution.
rng(seed_num,'twister');
switch velocity.distribution
    case 'gaussian'
        velocity_sequence = randn(n_sample, 1) * velocity.range;
        col_pos_sequence = randi(n_hor, [n_sample, 1]);
    case 'binary'
        velocity_sequence = [];
        col_pos_sequence = randi(n_hor, [n_sample, 1]);
end
end