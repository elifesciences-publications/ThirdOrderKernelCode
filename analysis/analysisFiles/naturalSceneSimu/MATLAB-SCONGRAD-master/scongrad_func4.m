%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									 %%
%%  BIGGSB1 (CUTEr)					 %%
%%  Initial Point: x0 = [0;0;...;0]  %%
%%									 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f,g] = scongrad_func4(x)

n = length(x);
g = zeros(n,1);

      f = (x(1)-1).^2 + (1-x(n)).^2;
      for i=2:n
        f = f + (x(i)-x(i-1)).^2;
      end

      g(1) = 4*x(1)-2*x(2)-2; 
      
      for i=2:n-1
        g(i) = 4*x(i)-2*x(i-1)-2*x(i+1);
      end
      
      g(n) = 4*x(n)-2*x(n-1)-2;    

end