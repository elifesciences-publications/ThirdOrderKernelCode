function y = MyLN_Coe(x,coe,lookUpTable)
X = lookUpTable.x;
Y = lookUpTable.y;

minX = min(X);
maxX = max(X);

indA = x < minX;
indB = minX < x & x < maxX;
indC = x > maxX;

y = zeros(size(x));
x_ = coe(1)* x.^2 + coe(2)* x.^1 + coe(3);

yMin = coe(1)* minX^2 + coe(2)* minX^1 + coe(3);
yMax = coe(1)* maxX^2 + coe(2)* maxX^1 + coe(3);
y(indA) = yMin;
y(indB) = x_(indB);
y(indC) = yMax;


end