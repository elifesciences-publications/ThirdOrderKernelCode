function [f, x] = MyCDF(y)
% matlab one
[f0,x0] = ecdf(y);

makeFigure;
h = histogram(y);
h.BinWidth = 0.0001;
x = h.BinEdges(1:end-1) + 1/2 * h.BinWidth;
p = h.Values;
f = cumsum(p);
close(gcf)
f = f/max(f);
makeFigure
plot(x0,f0,'r',x,f,'b');

end