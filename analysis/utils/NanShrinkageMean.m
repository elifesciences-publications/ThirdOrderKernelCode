function y = NanShrinkageMean(x,dim)
    varIn = nanvar(x,[],dim);
    meanIn = nanmean(x, dim);
    n = sum(~isnan(x),dim);
    shrunkMeans = meanIn+(1-(n-3)*varIn/sum((x-meanIn).^2)).*(x-meanIn);
    y = mean(shrunkMeans);
end