function [optimal_h, n_bin] = GMC_Utils_FindOptimalH_Main(x, y)
x_range = max(x) - min(x);
y_range = max(y) - min(y);
n_bin = 4.^(5:8) * 3;
h = [x_range./n_bin, y_range./n_bin];
f = zeros(length(h), 1);
for ii = 1:1:length(h)
    f(ii) = GMC_Utils_FindOptimalH_Utils_CalErrOneh(x, y, h(ii));
end

[~, f_min_arg] = min(f);
optimal_h = h(f_min_arg);
MakeFigure;
subplot(2, 2, 1);
scatter(h, f);


end