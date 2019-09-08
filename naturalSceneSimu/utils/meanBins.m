function [ distMeans, distAxis, distSD, distN ] = meanBins( xs, ys, nBins )
% Approximates the relationship between x and y by averaging y values in a
% certain range of x.

    % create limits for bins - evently spaces
    distLimits = [ min(xs) max(xs) ];
    eps = 1e-7;
    distBins = linspace(distLimits(1), distLimits(2), nBins + 1);
    distBins(1) = distBins(1) - eps;
    distMeans = zeros(1,nBins);
    
    % pick out and average
    for q = 1:nBins
        theseIndices = ( xs > distBins(q)) .* ...
            (xs <= distBins(q+1) );
        theseIndices = find(theseIndices);
        distSD(q) = std(ys(theseIndices));
        distN(q) = length(theseIndices);
        distMeans(q) = mean(ys(theseIndices));
    end
    
    % create axis labels - mean value of each bin
    distAxis = filter([1/2 1/2],1,distBins); 
    distAxis = distAxis(2:end);

end

