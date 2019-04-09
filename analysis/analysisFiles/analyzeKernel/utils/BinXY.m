function [binedx,binedy,n] = BinXY(x,y,mode,varargin)
% because the data set are too large, it is really hard to draw the binned
% data
% nbin = 1000;
% h = histogram(v);
% h.NumBins = nbin;
% counts = h.Values;
% leftEdges = h.BinEdges;

nbins = 1000;
edge_distribution = 'linear';
for ii = 1:2:length(varargin)
      eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if mode == 'y'
    a = y;
    y = x;
    x = a;
end

max_x = max(abs(x));
if strcmp(edge_distribution,'linear')
    edgex = linspace(-max_x ,max_x,nbins(1)); % maximun value would not be appropriate. will it? it should be more symmetric    
elseif strcmp(edge_distribution,'histeq')
    % change the function 
    edgex = Bin_Edge_Histeq(x, nbins(1));
end
[n,~,bins] = histcounts(x,edgex);
ty = sparse(1:length(x),bins,y);
mu = full(sum(ty)./sum(ty~=0)); % bin and average...

binedx = (edgex(1:end - 1) + edgex(2:end))/2;
binedy = mu;

if mode == 'y'
    a = binedy;
    binedy = binedx;
    binedx = a;
end

end
