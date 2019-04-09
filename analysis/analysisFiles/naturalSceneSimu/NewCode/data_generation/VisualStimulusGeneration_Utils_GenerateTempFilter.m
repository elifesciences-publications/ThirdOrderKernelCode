function f = VisualStimulusGeneration_Utils_GenerateTempFilter(tau, varargin)
mode = 'exponetial_decay';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% decay_form = 'exponential squred';  change
% dt_sample = 1/60; % sampling dt for the second/third kernel.
dt_tf = 0.002; % sampling dt for the temporal kernel
% tau = 0.01; % tau is 10 ms second. already very very fast. what is the relevant time?
n_f = round(tau/dt_tf * 3);
t_f = (0:1:n_f - 1)' * dt_tf;
if strcmp(mode, 'exponetial_decay')
    f = exp(-t_f/tau); 
%     plot(t_f, f); % f can be computed before hand.
else
    
end
f = flipud(f);
% normalize by
f = f/sum(f);
end