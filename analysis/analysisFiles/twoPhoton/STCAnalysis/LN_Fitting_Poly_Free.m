% y, x, order.
function poly_coe = LN_Fitting_Poly_Free(x,y,order)
% assume

[n,d] = size(x);
% if d
if d ~= 2
    error('input data does not have two dimensions');
end

% prepare X_polyfit
X_polyfit = ones(n,1);
for pp = 1:1:order
    for ii = 1:1:pp + 1;
        mm = ii - 1;
        % x1^(0) * x2(pp) + x1^(1) * x2(pp - 1) + ...
        X_polyfit = cat(2,X_polyfit,x(:,1).^(mm) .* x(:,2).^(pp - mm));
    end
end

poly_coe = X_polyfit\y;
% you have to remember the meaning of p.
% p(1) is constant term
% p(2) * x1^(0) * x2^(1) + p(3) * x1^(1) * x2^(0)
% p(4) * x1^(0) * x2^(2) + p(5) * x1^(1) * x^(1) + p(6) * x1^(2) * x1^(0)
% p(7) * x1^(0) * x2^(3) + p(8) * x1^(1) * x2^(2) + p(9) * x1^(2) * x2^(1) + p(10) * x1^(3) * x2^(0)