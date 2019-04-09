function mat_vec = covariance_index_transition_vec_to_mat(ind_vec, N)
    
    mat_vec = zeros(N^2, length(ind_vec));
    for ii = 1:1:length(ind_vec)
        A = tril(ones(N,N),ind_vec(ii) - 1) & triu(ones(N,N),ind_vec(ii) - 1);
        A = (A + A');
        mat_vec(:,ii) = A(:);
    end
    
end