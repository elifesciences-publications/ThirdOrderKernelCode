function alphaNew = ARD_Utils_Calculate_Alpha(alpha,covMat,mu)
    M = length(alpha);
    alphaNew = zeros(M,1);
    for mm = 1:1:M
        alphaNew(mm) = (1 - alpha(mm) * covMat(mm,mm))/mu(mm).^2;
    end
end