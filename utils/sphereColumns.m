function B = sphereColumns( A )
% Mean-subtract and normalize the columns of A.

    m = size(A,1);
    % Mean subtract
    B = A - repmat(mean(A,1),[ m 1 ]);
    % Normalize
    covs = B'*B;
    covs = diag(diag(covs));
    B = B * covs^(-1/2);

end

