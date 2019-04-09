function deltaRho = ASD_Utils_Update_DeltaRho(S,covMat,mu)
    deltaRho = 1/2 * trace((S - covMat - mu * mu')/inv(S));
end
