function x_ = MyRectification(x)
nSize = size(x);
x_ = zeros(nSize);

ind = find(x > 0);
x_(ind) = x(ind);

x_ = reshape(x_,nSize);



end