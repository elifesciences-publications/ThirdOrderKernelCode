function deltaSigSquare = ASD_Utils_Calculated_DeltaSig(X,Y,covMat,S,mu,sig)
T = length(Y);
M = size(X,1);
deltaSigSquare = 1/sig.^2 * (-T + trace(eye(M)-covMat /S) + 1/sig.^2 * (Y - mu' * X) * (Y - mu' * X)');
end