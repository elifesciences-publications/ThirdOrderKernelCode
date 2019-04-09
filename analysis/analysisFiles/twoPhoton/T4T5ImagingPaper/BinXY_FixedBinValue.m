function [binedx,binedy,n] = BinXY_FixedBinValue(x,y,mode,nbinsUsr)
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
% edgex should be changed to a fixed one now.....
% edgex = linspace(min(x),max(x),nbins);
edgex = linspace(-0.6,0.6,nbins); % the predicted response can be really really large
edgex = [-inf,edgex,inf];
dumbX = edgex';
xDumb = [x;dumbX];

[nDumb,binsDumb] = histc(xDumb,edgex); 
yDumb = [y;zeros(length(edgex),1)];
tyDumb = sparse(1:length(xDumb),binsDumb,yDumb);
muDumb = full(sum(tyDumb)./sum(tyDumb~=0)); % bin and average

binedx = edgex';
binedy = muDumb';
n = nDumb - 1;

if mode == 'y'
    a = binedy;
    binedy = binedx;
    binedx = a;
end

end
