function deltaSmooth = ASD_Utils_Calculate_DeltaSmooth(S,covMat,mu,distMat,smoothParam)
deltaSmooth =  -1/2 * trace((S - covMat - mu * mu') /S * (S.* distMat/smoothParam.^3)/S);
end