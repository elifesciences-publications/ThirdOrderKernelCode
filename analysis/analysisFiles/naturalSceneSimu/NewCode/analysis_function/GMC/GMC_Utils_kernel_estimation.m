function hist_I = compute_contrast_distribution_kernel(x, sigma, dynamic_range)
% for every value, analyze data there.
    dist_I = bsxfun(@minus, dynamic_range, x');
    norm_dist_I = dist_I/sigma; 
    hist_I = mean( exp(-norm_dist_I.^2), 2);
    hist_I = hist_I/sum(hist_I);
%     MakeFigure; plot(dynamic_range, hist_I);
    
    %% if you normalize from beginning>
%      hist_I = mean( 1/(sigma * sqrt(2 * pi)) * exp(-norm_dist_I.^2), 1);
end