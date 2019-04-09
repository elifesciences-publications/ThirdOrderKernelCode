function y = MyLN_Poly(x,coe,lookUpTable,varargin)
% set a marker to decide whether you use the boundary constrain...
% just work on
setUpLowerBoundFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


y_ = coe(1)* x.^2 + coe(2)* x.^1 + coe(3);

if setUpLowerBoundFlag
    X = lookUpTable.x;
    Y = lookUpTable.y;
    
    minX = min(X);
    maxX = max(X);
    
    indA = x < minX;
    indB = minX < x & x < maxX;
    indC = x > maxX;
    
    y = zeros(size(x));
    yMin = coe(1)* minX^2 + coe(2)* minX^1 + coe(3);
    yMax = coe(1)* maxX^2 + coe(2)* maxX^1 + coe(3);
    y(indA) = yMin;
    y(indB) = y_(indB);
    y(indC) = yMax;
else
    y = y_;
end

end