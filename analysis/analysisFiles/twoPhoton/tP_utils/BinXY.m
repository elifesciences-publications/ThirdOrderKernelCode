function [binedx,binedy,n] = BinXY(x,y,mode,nbinsUsr)
% because the data set are too large, it is really hard to draw the binned
% data
% nbin = 1000;
% h = histogram(v);
% h.NumBins = nbin;
% counts = h.Values;
% leftEdges = h.BinEdges;

nbins = 1000;
if nargin > 3
    nbins = nbinsUsr;
end
if mode == 'y';
    a = y;
    y = x;
    x = a;
end

edgex = linspace(min(x),max(x),nbins);
[n,bins] = histc(x,edgex);
ty = sparse(1:length(x),bins,y);
mu = full(sum(ty)./sum(ty~=0)); % bin and average...

binedx = edgex;
binedy = mu;

if mode == 'y'
    a = binedy;
    binedy = binedx;
    binedx = a;
end

end
