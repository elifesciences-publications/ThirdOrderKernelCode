function variance = variance_p(p, gray_level)
    mu = moment_computing(p, gray_level, 1);
    variance = sum((gray_level - mu).^2 .* p);
end