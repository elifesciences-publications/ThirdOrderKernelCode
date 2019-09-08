function y = MyMode(x,n)
% resturn 1:n....
y = x - floor((x - 0.01)/n) * n;
end