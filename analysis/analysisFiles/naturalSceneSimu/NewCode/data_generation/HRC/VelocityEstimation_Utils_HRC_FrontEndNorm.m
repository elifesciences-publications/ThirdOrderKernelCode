function v2 = VelocityEstimation_Utils_HRC_FrontEndNorm(HRC, s1, s2, s1_norm, s2_norm)
flips1 = flipud(s1);
flips2 = flipud(s2);
flips1_norm = flipud(s1_norm);
flips2_norm = flipud(s2_norm);
f = HRC.f;
g = HRC.g;

% s1 s2 is vertical vector.
if HRC.contrast_adaptation_flag
    % if the contrast adaptation happens in delay line.
    % the variance of s1 should be normalized...
    switch HRC.adaptation_form
        case 'norm_delay'
            s1_delay =  flips1_norm;
            s2_delay =  flips2_norm;
            s1_nondelay = flips1;
            s2_nondelay = flips2;
        case 'norm_nondelay'
            s1_delay =  flips1;
            s2_delay =  flips2;
            s1_nondelay = flips1_norm;
            s2_nondelay = flips2_norm;
        case 'norm_both'
            s1_delay = flips1_norm;
            s2_delay = flips2_norm;
            s1_nondelay = flips1_norm;
            s2_nondelay = flips2_norm;
    end
end

right_arm = dot(f,s1_nondelay) * dot(g,s2_delay);
left_arm = dot(g,s1_delay) * dot(f,s2_nondelay);

% right_arm = dot(f,flips1) * dot(g,flips2 );
% left_arm = dot(g,flips1) * dot(f,flips2);

v2 = right_arm - left_arm;

end
