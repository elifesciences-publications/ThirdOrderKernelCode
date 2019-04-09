function sigNew = ARD_Utils_Calculate_Sig(X,Y,mu,covMat,alpha)
    T = length(Y);
    aNumber = length(alpha) - diag(covMat)' * alpha';
    sigNewSquare = (Y - mu' * X) * (Y' - X' * mu)/(T - aNumber);
    sigNew = sqrt(sigNewSquare);
end
