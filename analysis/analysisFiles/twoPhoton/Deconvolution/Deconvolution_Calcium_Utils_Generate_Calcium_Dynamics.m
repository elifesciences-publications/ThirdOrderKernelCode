function [ca_psf,t_plot] = Deconvolution_Calcium_Utils_Generate_Calcium_Dynamics(type)

switch type
    case 'psf'
        stimHz = 60; % 60 Hz
        
        t = (0:1/stimHz:0.5 - 1/stimHz * 1)';
        t_rise = 0.005;
        t_decay = 0.3;
        % t_decay_half = 0.2
        % t_decay = t_decay_half / log(1/2);
        ca_dy = (exp(-t/t_rise) - exp(-t/t_decay));
        ca_dy = ca_dy/(sum(ca_dy));
        
        % make it faster.
        ca_psf = [zeros(length(t) - 1,1); ca_dy];
        t_plot = -(length(t) - 1) * 1/ stimHz : 1/stimHz:max(t);
    case '1_demension'
end
end