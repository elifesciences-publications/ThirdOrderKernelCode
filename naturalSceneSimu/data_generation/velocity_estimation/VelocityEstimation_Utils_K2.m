function v2 = VelocityEstimation_Utils_K2(kernel, s1, s2)
% s1 s2 is vertical vector.
flips1 = flipud(s1);
flips2 = flipud(s2);
v2 = flips1' * kernel * flips2;
v2 = v2 * 2;
end
