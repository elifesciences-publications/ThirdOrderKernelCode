function [ outHist ] = pointHist_fun( kernelVects,X,Y,Z,nBins )
% Creates a histogram of average values along a specific diagonal

if nargin < 4
    nBins = 20;
end

Nflies = size(kernelVects,2);

for qq = 1:Nflies
    getDot(qq) = kernelVects(X,Y,Z,qq);
end

figure; hist(getDot,nBins)
outHist = hist(getDot,nBins); 


end

