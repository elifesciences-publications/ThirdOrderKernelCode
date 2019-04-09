function x = CovEstimation_SecondOrderKernel_Utils_CollectOffDiagnalElement(X,dt)
N = size(X,1); % X should be a square matrix.
windFull = true(N,N);
wind = tril(windFull,dt) & triu(windFull,dt);
x = X(wind(:));
end