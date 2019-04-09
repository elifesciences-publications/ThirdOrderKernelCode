function ind = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Sub2Ind(ii, jj)
% ii, jj into a index
% ii, jj might be vector.
if length(ii)~= length(jj)
    keyboard;
end
ind = zeros(length(ii), 1);

for nn = 1:1:length(ii)
    
    if ii >= jj
        warning('ii should not be larger than jj');
        keyboard;
    end
    kk = jj(nn) - 1;
    ind(nn) = (kk^2 - kk)/2 + ii(nn);
    
end


