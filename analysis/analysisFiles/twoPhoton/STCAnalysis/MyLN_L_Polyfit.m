function y_use = MyLN_L_Polyfit(x, order, L_polyfit_coe, meshflag)
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
%
a(1:2) = L_polyfit_coe(1:2);
f = L_polyfit_coe(3:end);
if (order + 1) ~= length(f)
    error('order does not match');
end

v = (a * x_use')';
y = f(1) * ones(size(x_use,1),1);
if order >= 1
    y = y + f(2) * v;
    if order >= 2
        y = y + f(3) * v.^2;
        if order >= 3
            y = y + f(4) * v.^3;
            if order >=4
                y = y + f(5) * v.^4;
                if order >= 5
                    y = y + f(6) * v.^5;
                end
            end;
        end
    end
end


if meshflag
    y_use = reshape(y, [length(x(:,1)), length(x(:,2))]);
else
    y_use = y;
end