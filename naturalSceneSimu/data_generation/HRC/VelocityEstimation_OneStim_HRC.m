function v2 = VelocityEstimation_OneStim_HRC(stim, kernel, varargin)
% space_range = 54;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
space_range = size(stim, 2);
v2 = zeros(space_range - 1, 1);
for ii = 1:1:space_range - 1
    s1 = stim(:, ii);
    s2 = stim(:, ii + 1);
    v2(ii) =  VelocityEstimation_Utils_HRC(kernel, s1, s2);
end

end



% Test Function for the Utils K2 and K3.
% test function using for loop.
function r = VelocityEstimation_Utils_K2_Test(k2_sym, s1, s2)
maxTau = size(k2_sym, 1);
r = 0;
for ii = 1:1:maxTau
    for jj = 1:1:maxTau
        r = r +  k2_sym(ii, jj) * s1(end - ii + 1) * s2(end - jj + 1);
    end
end


end
function r = VelocityEstimation_Utils_K3_Test(k3_sym, s1, s2)

maxTau = size(k3_sym, 1);
r = 0;
for ii = 1:1:maxTau
    for jj = 1:1:maxTau
        for kk = 1:1:maxTau
            r = r +  k3_sym(ii, jj, kk) *...
                (s1(end - ii + 1) * s1(end - jj + 1) *  s2(end - kk + 1) -...
                s2(end - ii + 1) * s2(end - jj + 1) *  s1(end - kk + 1));
        end
    end
end
end