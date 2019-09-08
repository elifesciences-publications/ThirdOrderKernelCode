function [ Y ] = spherize( X )
% Mean subtracts and scales to unit length the COLUMNS of a matrix X

    meanSubtract = X - repmat(mean(X),[size(X,1) 1]);
    normMat = diag(diag(meanSubtract'*meanSubtract))^(-1/2);
    Y = meanSubtract * normMat;

end

