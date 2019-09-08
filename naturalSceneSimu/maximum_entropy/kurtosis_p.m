function kurtosis = kurtosis_p(p, gray_level)
mu = moment_computing(p, gray_level, 1);
variance = variance_p(p,gray_level);
% skewness = sum(((gray_level - mu)./sqrt(variance)).^3.*p);
kurtosis = sum(((gray_level - mu)./sqrt(variance)).^4.*p);
end