function Y = gaussianIntegral( binLims, sig, mu, see )
% Returns a filter of length (length(binLims)-1) that has as its entries
% the integral of a Gaussian distribution with mu mean and standard
% deviation sig.

    if nargin < 3
        mu = 0;
    end
    
    if nargin < 4
        see = 0;
    end

   % Step 1. Because we can't scale MATLAB's error function script, we 
   % shift and scale binLims
   X = binLims - mu;
   X = X / sqrt(2) / sig;
   
   % Step 2. Compute the error function at the end points of each bin
   erfY = erf(X) / 2; % erf integrates twice the Gaussian distribution
   
   % Step 3. Take differences
   Y = diff(erfY);
%    assert( abs(sum(Y) - 1) < .05 );
   
   % Step 4. Optionally, visualize "continuous filter" versus output
   if see
       nContinSamples = 1000;
       continAxis = linspace(min(binLims),max(binLims),nContinSamples);
       continGauss = exp( -( (continAxis-mu)/sqrt(2)/sig ).^2 ) / sqrt(2*pi*sig^2);
       dxContin = [ max(binLims) - min(binLims) ] / nContinSamples;
%        sum(continGauss) * dxContin
       dxBin = [ max(binLims) - min(binLims) ] / (length(binLims)-1);
       Xcenters = filter([1/2 1/2],1,X);
       Xcenters = Xcenters(2:end)*sqrt(2)*sig;
       Yrenorm = Y /  dxBin;
       figure; plot(continAxis,continGauss); 
       hold all; bar(Xcenters,Yrenorm);
   end      

end

