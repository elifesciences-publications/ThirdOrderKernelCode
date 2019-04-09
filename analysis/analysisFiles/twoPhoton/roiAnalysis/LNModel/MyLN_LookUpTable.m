function y = MyLN_LookUpTable(x,lookUpTable)

X = lookUpTable.x;
Y = lookUpTable.y;

% first, split x into three parts.
% x < predResp min
% x > predResp max
% min < x < max

minX = min(X);
maxX = max(X);

indA = x < minX;
indB = minX < x & x < maxX;
indC = x > maxX;

y = zeros(size(x));

y(indA) = min(Y);
y(indB) = interp1(X,Y,x(indB));
y(indC) = max(Y);


end