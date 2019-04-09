function K3_Impulse = K3_SVD_Utils_GetK3_Impulse_SameSpatialSym(tau_21, tau_31, K3, tMax, maxTau)
% maxTau = 64;
% tMax = 48;
% K3 = k3_sym_mean;
% tau_21 = [-10:10];
% tau_31 = [-10:10];

n_21 = length(tau_21);
n_31 = length(tau_31);

K3_Impulse = zeros(tMax, n_21, n_31);
for ii = 1:1:n_21
    for jj = 1:1:n_31
        dtxx = tau_21(ii) - tau_31(jj);
        dtxy = -tau_21(jj);
        [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);        
        K3_Impulse(1:sum(~isnan(ind)),ii,jj) = K3(wind(:) == 1); % most recent bars.    
    end
end
end