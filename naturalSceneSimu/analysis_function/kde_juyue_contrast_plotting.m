function y = kde_juyue_contrast_plotting(x_sample, x_val, h)
y = zeros(length(x_val), 1);
for xx = 1:1:length(x_val)
    y(xx) = 1/h * mean(K((x_val(xx) - x_sample)/h));
end
end
function y = K(x)
y = 1/sqrt(2 * pi) * exp(-1/2 * x.^2);
end