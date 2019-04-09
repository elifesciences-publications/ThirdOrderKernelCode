function ind_vec  = covariance_index_transition_mat_to_vector(ind_mat, N)
    [I,J] = ind2sub([N,N], ind_mat);
    ind_vec = abs(I-J) + 1;
end
% maxtrix index will be 1 to N^2
