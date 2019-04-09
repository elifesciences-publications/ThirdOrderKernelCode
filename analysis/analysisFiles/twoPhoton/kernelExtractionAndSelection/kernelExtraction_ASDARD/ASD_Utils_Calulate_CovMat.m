function covMat = ASD_Utils_Calulate_CovMat(XX,sig,C, invCFlag)
if invCFlag
    covMat = inv(XX/sig.^2 + C); % hard inverse calculation. need gpu?
else
    covMat = inv(XX/sig.^2 + inv(C)); % hard inverse calculation. need gpu?
    
end
end