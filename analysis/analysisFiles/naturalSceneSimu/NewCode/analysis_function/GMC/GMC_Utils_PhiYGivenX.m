function phi_y_given_x = GMC_Utils_PhiYGivenX(x, x_data, y_data, h)
    % first, define K 
    % x and x_data are all column vector.
    dist_x_xi = bsxfun(@minus, x, x_data'); 
    dist_norm = dist_x_xi/h;
    
    n = length(x_data);
    f_x = normalized_gaussian(dist_norm);
    f_x_times_y = bsxfun(@times, f_x, y_data');
    
    phi_y_given_x = 1/(n * h) * sum(f_x_times_y, 2);
    
end

% \