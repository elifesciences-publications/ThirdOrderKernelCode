function [ii,jj] = Calculate_Jacobian_Utils_EveryMarginalCov_Cov_Ind2Sub(ind)
n_ind = length(ind);
ii = zeros(n_ind, 1);
jj = zeros(n_ind, 1);
for nn = 1:1:n_ind
    % first, calculate k.
    [kk, temp] = Utils_Find_KK(ind(nn));
    jj(nn) = kk + 1;
    ii(nn) = ind(nn) - temp;
end
end
%% you should build up a table for this.


function  [kk, kk_minus_1_ind] = Utils_Find_KK(ind)
    look_up_table_upper = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120];
    look_up_table_lower = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105];
    kk = find(ind > look_up_table_lower & ind <= look_up_table_upper);
    kk_minus_1_ind = look_up_table_lower(kk);
end


% this one include diag. Do not use it anymore.
% kk = 1:1:100;
% look_up_table = (kk.^2 + kk)/2
% function  [kk, kk_minus_1_ind] = Utils_Find_KK(ind)
%     look_up_table_upper = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120];
%     look_up_table_lower = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105];
%     kk = find(ind > look_up_table_lower & ind <= look_up_table_upper);
%     kk_minus_1_ind = look_up_table_lower(kk);
% end

