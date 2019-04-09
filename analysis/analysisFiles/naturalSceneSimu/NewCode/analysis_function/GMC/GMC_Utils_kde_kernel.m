function f_x = GMC_Utils_kde_kernel(x,x_data, h)
    % first, define K 
    % x and x_data are all column vector.
    dist_x_xi = bsxfun(@minus, x, x_data'); 
    dist_norm = dist_x_xi/h;
    
    n = length(x_data);
    f_x = 1/(n * h) * sum(normalized_gaussian(dist_norm), 2);
end

