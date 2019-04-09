%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									 %%
%%  COSINE (CUTEr)					 %%
%%  Initial point: x0 = [1;1;...;1]  %%
%%								     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,g] = scongrad_func5(x)

n = length(x);
g = zeros(n,1);

f = 0;

for i=1:n-1
	f = f + cos(x(i)*x(i) - x(i+1)/2);
end

g(1) = -(2*x(1)) * sin(x(1).^2 - x(2)/2);

for i=2:n-1
	g(i) = 0.5*sin(x(i-1).^2 - x(i)/2) - (2*x(i)) * sin(x(i).^2 - x(i+1)/2);
end

g(n) = 0.5*sin(x(n-1).^2 - x(n)/2);  	

end