function v_sym = VelocityEstimation_Utils_K3(kernel, s1, s2)
% s1 s2 is vertical vector.
flips1 = flipud(s1);
flips2 = flipud(s2);


% compute velocity using third order kernel
[mesha,meshb,meshc] = ndgrid(flips1,flips1,flips2);
Sxxy = mesha.* meshb.* meshc;
% v_xxy = Sxxy.* k3_xxy;

[mesha,meshb,meshc] = ndgrid(flips2,flips2,flips1);
Syyx = mesha.* meshb.* meshc;
% v_yyx = Syyx.* k3_yyx;

% correct, here, you assume sym = xxy - yyx;
v_sym = kernel.*(Sxxy - Syyx);
v_sym = sum(v_sym(:));

v_sym = v_sym * 3;
end