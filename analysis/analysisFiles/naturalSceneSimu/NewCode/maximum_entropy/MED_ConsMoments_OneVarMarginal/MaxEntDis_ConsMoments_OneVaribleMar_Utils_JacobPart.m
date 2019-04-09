function [dFdp, DpDx_part1] = MaxEntDis_ConsMoments_OneVaribleMar_Utils_JacobPart(n_highest_moments,gray_level, N)
dFdp = zeros(n_highest_moments + 1, N); %
for ii = 1:1:n_highest_moments + 1
    order = ii - 1; 
    dFdp(ii, :) = gray_level.^ order;
end

DpDx_part1 = zeros(N, n_highest_moments + 1);
for ii = 1:1:n_highest_moments + 1
    order = ii - 1;
    DpDx_part1(:, ii) = gray_level.^ order;
end
end