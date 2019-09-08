function a = MyAbs(x)
% x would be velocity, in this program, x will be left and right
% symetrical... (positive and negative symmetrical)

% first, get the absolute value of x, which is reasonable larger than 0;
tolerance  = 1e-6;
a = abs(x);
a = a(a > tolerance);
end