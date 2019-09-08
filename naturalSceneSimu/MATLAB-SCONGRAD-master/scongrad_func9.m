%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									 %%
%%  ARWHEAD (CUTEr)                  %%         
%%  Initial point: x0 = [1;1;...;1]  %%
%%									 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [f,g] = scongrad_func9(x)

n = length(x);
g = zeros(n,1);

		f = 0;
		
		for i=1:n-1
			f = f + (-4*x(i)+3) + (x(i).^2+x(n).^2).^2;
		end
		
		for i=1:n-1
			g(i) = -4 + 4*x(i)*(x(i).^2+x(n).^2);
		end
		
		g(n) = 0;
		
		for i=1:n-1
			g(n) = g(n) + 4*x(n)*(x(i).^2+x(n).^2);
		end             
end