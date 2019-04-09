function [ thisVect,outHist ] = diagHist_fun( kernelVects,dispSide,dispUp,nBins )
% Creates a histogram of average values along a specific diagonal

if nargin < 4
    nBins = 20;
end

Nflies = size(kernelVects,2);

thisVect = getLine( 50,dispSide,dispUp,0 );
for qq = 1:Nflies
    thisKernel = kernelVects(:,:,:,qq);
    integrate(qq) = thisVect'*thisKernel(:) / sum(thisVect);
end

% integrate = permute(integrate,[3 1 2]);
figure; hist(integrate,nBins)
outHist = hist(integrate,nBins); 

end

