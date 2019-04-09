function cov_mat_sym = STC_Utils_SigTest_Utils_SymmetrizeCovMat(cov_mat, method)
    % the best way is to use only half of it.
    switch method
        case 'upper_half'
            A = true(size(cov_mat));
            cov_mat_sym = zeros(size(cov_mat));
            cov_mat_sym(triu(A,0) > 0) = cov_mat(triu(A,0) > 0);
            cov_mat_sym = cov_mat_sym + cov_mat_sym';
            cov_mat_sym(eye(size(cov_mat,1)) > 0) =   cov_mat_sym(eye(size(cov_mat,1)) > 0)/2;
            
        case 'lower_half'
            A = true(size(cov_mat));
            cov_mat_sym = zeros(size(cov_mat));
            cov_mat_sym(tril(A,0) > 0) = cov_mat(tril(A,0) > 0);
            cov_mat_sym = cov_mat_sym + cov_mat_sym';
            cov_mat_sym(eye(size(cov_mat,1)) > 0) =   cov_mat_sym(eye(size(cov_mat,1)) > 0)/2;
          
        case 'average'
            cov_mat_sym = (cov_mat + cov_mat')/2; 
    end
end