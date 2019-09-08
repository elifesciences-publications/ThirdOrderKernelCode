function [v2, v3] = VelocityEstimation_OneStim_InputIsOneRow_AllKernel(stim, kernel, varargin)
% space_range = 54;
which_kernel_type = 'reverse_correlation_sameKernel';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
space_range = size(stim, 2);
spatial_interval = 13; % 5/(360/927)
v2 = zeros(space_range, 1);
% n and n + 1 pair. compute all of them,
switch which_kernel_type
    case 'reverse_correlation_sameKernel'
        k2_sym = kernel.k2_sym;
        k3_sym = kernel.k3_sym;
        v3 = zeros(space_range, 1);
        for ii = 1:1:space_range
            s1 = stim(:, ii);
            s2 = stim(:, mod(ii + spatial_interval - 1, space_range) + 1);
            v2(ii) = VelocityEstimation_Utils_K2(k2_sym, s1, s2);
            v3(ii) = VelocityEstimation_Utils_K3(k3_sym, s1, s2);
        end
    case 'HRC'
        for ii = 1:1:space_range
            s1 = stim(:, ii);
            s2 = stim(:, mod(ii + spatial_interval - 1, space_range) + 1);
            v2(ii) =  VelocityEstimation_Utils_HRC(kernel, s1, s2);
        end
        v3 = [];
    case 'STE'
        
        [x_n, t_n, ~] = size(kernel);
        for ii = 1:1:space_range - 1
            % get the last part, across several placs.
            spatial_loc = ii + (0:x_n-1) * spatial_interval; spatial_ind = mod(spatial_loc - 1, space_range) + 1;
            temporal_loc = size(stim, 1) - t_n + 1:1: size(stim, 1);
            
            stim_this = stim(temporal_loc,spatial_ind);
            v2(ii) = VelocityEstimation_Utils_STE(kernel, stim_this);
        end
        v3 = [];
end

vest.v2 = v2;
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