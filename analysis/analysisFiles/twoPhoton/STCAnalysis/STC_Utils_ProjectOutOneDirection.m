function cov_mat_without_P = STC_Utils_ProjectOutOneDirection(cov_mat, P)
P = P(:);
A = P*P'/ (P'*P);
I = eye(size(cov_mat,2));
cov_mat = double((cov_mat + cov_mat')/2);
cov_mat_without_P = (I - A') * cov_mat * (I - A')';
cov_mat_without_P = ( cov_mat_without_P +  cov_mat_without_P')/2;
end