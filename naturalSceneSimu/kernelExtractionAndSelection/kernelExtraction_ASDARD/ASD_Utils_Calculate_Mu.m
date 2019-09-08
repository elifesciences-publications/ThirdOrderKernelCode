function mu = ASD_Utils_Calculate_Mu(XY,sig,covMat)
    
mu = covMat * XY / sig.^2;
end
