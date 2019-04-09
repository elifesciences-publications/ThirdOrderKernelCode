function v2 = VelocityEstimation_Utils_HRC(HRC, s1, s2)
%% if there is no contrast_adaptation_flag field.

f = HRC.f;
g = HRC.g;
if isfield(HRC, 'contrast_adaptation_flag')
    s1_adapted = CAF_LNL(s1, 1);
    s2_adapted = CAF_LNL(s2, 1);
    % to make the temporal filter comparable. linear filtering the non
    % normalized arm as well.
    s1 = CAF_LNL(s1, 0);
    s2 = CAF_LNL(s2, 0);
    
    flips1 = flipud(s1);
    flips2 = flipud(s2);
    flips1_adapted = flipud(s1_adapted);
    flips2_adapted = flipud(s2_adapted);
    
    % s1 s2 is vertical vector.
    if HRC.contrast_adaptation_flag
        % if the contrast adaptation happens in delay line.
        % the variance of s1 should be normalized...
        switch HRC.adaptation_form
            case 'norm_delay'
                s1_delay = flips1_adapted;
                s2_delay =  flips2_adapted;
                s1_nondelay = flips1;
                s2_nondelay = flips2;
            case 'norm_nondelay'
                s1_delay = flips1;
                s2_delay =  flips2;
                s1_nondelay = flips1_adapted;
                s2_nondelay = flips2_adapted;
            case 'norm_both'
                s1_delay = flips1_adapted;
                s2_delay =  flips2_adapted;
                s1_nondelay = flips1_adapted;
                s2_nondelay = flips2_adapted;
                
        end
    else
        s1_delay = flips1;
        s2_delay =  flips2;
        s1_nondelay = flips1;
        s2_nondelay = flips2;
    end
else
    s1_nondelay = flipud(s1);
    s1_delay = flipud(s1);
    s2_delay = flipud(s2);
    s2_nondelay = flipud(s2);
end

right_arm = dot(f,s1_nondelay) * dot(g,s2_delay);
left_arm = dot(g,s1_delay) * dot(f,s2_nondelay);


% right_arm = dot(f,flips1) * dot(g,flips2 );
% left_arm = dot(g,flips1) * dot(f,flips2);

v2 = right_arm - left_arm;

end
