function x = GibbsSampling_Utils_OD_Sample(p, n)
[~, x] =  histc(rand(n,1),[0;cumsum(p)/sum(p)]);
end