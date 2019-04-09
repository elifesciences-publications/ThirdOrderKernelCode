%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									%%
%%  LIARWHD (CUTEr)                 %%            
%%  Initial point x0 = [4;4;...;4]  %%
%% 								    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,g] = scongrad_func2(x)

n = length(x);
g = zeros(n,1);

f = 0;

for i=1:n
	f = f + 4*(x(i)*x(i) - x(1)).^2 + (x(i)-1).^2;
end  

g(1) = 2*(x(1)-1) + 8*(x(1)*x(1)-x(1))*(2*x(1)-1);

for i=2:n
	g(1) = g(1) - 8*(x(i)*x(i)-x(1));
end

for i=2:n
	g(i) = 16*x(i)*(x(i)*x(i)-x(1)) + 2*(x(i)-1);
end  

end