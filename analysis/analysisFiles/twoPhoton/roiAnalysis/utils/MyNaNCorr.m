function [rxy,covxy] = MyNaNCorr(x,y);
% This is a very wrong way to estimate the data...
covxy = nancov(x,y);
covxy = covxy(1,2);
nanPair = isnan(x) | isnan(y);
x(nanPair) = [];
y(nanPair) = [];
try
    rxy = corr(x,y);
catch
    rxy = 0;
end

end