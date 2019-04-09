function y_use = MyLN_Poly_Free(x, order, polyfit_coe, meshflag)
% assume
% it
d = size(x,2);
% if d
if d ~= 2
    error('input data does not have two dimensions'); 
end

if meshflag
    % you would meshgrid x,
    [X1,X2] = ndgrid(x(:,1),x(:,2),2);
    x_use = [X1(:), X2(:)];
else
    x_use = x;
end
% prepare X_polyfit
n = size(x_use, 1);
X_polyfit = ones(n,1);
for pp = 1:1:order
    for ii = 1:1:pp + 1;
        mm = ii - 1;
        % x1^(0) * x2(pp) + x1^(1) * x2(pp - 1) + ...
        X_polyfit = cat(2,X_polyfit,x_use(:,1).^(mm) .* x_use(:,2).^(pp - mm));
    end
end

% you need to have a mesh here...

y = X_polyfit * polyfit_coe;

if meshflag
    y_use = reshape(y, [length(x(:,1)), length(x(:,2))]);
else
    y_use = y;
end