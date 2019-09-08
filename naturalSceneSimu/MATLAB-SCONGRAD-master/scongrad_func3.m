%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									   %%
%%  DIXON3DQ  (CUTEr)				   %%
%%  Initial Point x0 = [-1;-1;...;-1]  %%
%%									   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,g] = scongrad_func3(x)

n = length(x);
g = zeros(n,1);

f = (x(1)-2).^2;

for i=1:n-1
	f = f + (x(i)-x(i+1)).^2;
end

f = f + (x(n)-1).^2;

g(1) = 2*(x(1)-2) + 2*(x(1)-x(2));

for i=2:n-1
	g(i) = -2*(x(i-1)-x(i)) + 2*(x(i)-x(i+1));
end

g(n) = -2*(x(n-1)-x(n)) + 2*(x(n)-1);

end