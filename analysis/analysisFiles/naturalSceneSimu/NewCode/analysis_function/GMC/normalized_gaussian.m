function y = normalized_gaussian(x)
    y = 1/(sqrt(2 * pi)) * exp(-1/2 * x.^2);
end
