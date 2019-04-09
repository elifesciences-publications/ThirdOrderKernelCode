%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									%%
%%  TRIDIA  (CUTEr)					%%
%%  Initial point x0 = [1;1;...;1]  %%
%%									%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,g] = scongrad_func8(x)

n = length(x);
g = zeros(n,1);

		alpha = 2;
		beta  = 1;
		gamma = 1;
		delta = 1;
		
		f = gamma*(delta*x(1)-1).^2;
		
		for i=2:n
			f = f + i*(alpha*x(i)-beta*x(i-1)).^2;
		end
		
		g(1) = 2*gamma*(delta*x(1)-1)*delta - 4*(alpha*x(2)-beta*x(1))*beta;
		
		for i=2:n-1
			g(i) = 2*i*(alpha*x(i)-beta*x(i-1))*alpha - ... 
				   2*(i+1)*(alpha*x(i+1)-beta*x(i))*beta;
		end   
		
		g(n) = 2*n*(alpha*x(n)-beta*x(n-1))*alpha;

end