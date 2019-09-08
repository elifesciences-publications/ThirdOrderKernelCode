function mu = moment_computing(p, gray_value, order)
    mu = sum((gray_value.^order) .* p);
end