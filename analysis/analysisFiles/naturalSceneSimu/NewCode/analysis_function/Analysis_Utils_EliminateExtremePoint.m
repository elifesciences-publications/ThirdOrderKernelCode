function [X_trunc, Y_trunc] = Analysis_Utils_EliminateExtremePoint(X, Y, thresh_prct)
M = size(X, 2);
ind = zeros(size(X));
for mm = 1:1:M
    low_val = prctile(X(:, mm), thresh_prct);
    high_val = prctile(X(:, mm), 100 - thresh_prct);
    %     X_mm = X(:, mm);
    ind(:, mm) = (X(:, mm)>=low_val) & (X(:, mm) <= high_val);
end
ind_and = prod(ind, 2);
X_trunc = X(ind_and == 1, :);
if isempty(Y)
    Y_trunc = [];
else
    Y_trunc = Y(ind_and == 1, :);
end
end