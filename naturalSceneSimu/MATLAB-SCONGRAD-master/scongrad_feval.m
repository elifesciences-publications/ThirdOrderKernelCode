%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									   %%
%%		SCONGRAD_FEVAL				   %%
%%									   %%
%%  Unconstrained optimization		   %%
%%        test functions			   %%
%%									   %%
%%  Includes functions from the 	   %%
%%	CUTEr collection.				   %%		
%%									   %%	
%%  Input:							   %%
%%		x 	 = initial point		   %%
%%		nexp = ID of problem		   %%
%%			   to be tested			   %%
%%									   %%
%%  Output:							   %%
%%		f = value of function at x	   %%
%%		g = gradient of function at x  %%
%%									   %%
%%  Written by Michael Doo			   %%
%%  Rensselaer Polytechnic Institute   %%
%%  Spring 2011						   %%
%%									   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,g] = scongrad_feval(x,nexp)
      
      n = length(x); % initialize n
	  g = zeros(n,1); % initialize g as column vector
     
switch(nexp)


%  Extended Powell 
%  Initial Point: x0 = [3;-1;0;1;...]

	case 1
      
		f = 0;		
		j = 1;
		
		for i=1:n/4  
		
			t1 = x(4*i-3) + 10*x(4*i-2); 
			t2 = x(4*i-1) - x(4*i);
			t3 = x(4*i-2) - 2*x(4*i-1);
			t4 = x(4*i-3) - x(4*i);     
			
			f = f + t1*t1 + 5*t2*t2 + t3.^4 + 10*t4.^4;      
			       
			g(j)   =   2*t1 + 40*t4.^3;
			g(j+1) =  20*t1 +  4*t3.^3;
			g(j+2) =  10*t2 -  8*t3.^3;
			g(j+3) = -10*t2 - 40*t4.^3;
			
			j = j+4;  
			
		end                
		return
		
%  LIARWHD (CUTEr)                              
%  Initial point x0 = [4;4;...;4]

	case 2

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
		
		return
		
%  DIXON3DQ  (CUTEr)
%  Initial Point x0 = [-1;-1;...;-1]

	case 3

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
				
		return
      
%  BIGGSB1 (CUTEr)
%  Initial Point: x0 = [0;0;...;0]

	case 4
      
      f = (x(1)-1).^2 + (1-x(n)).^2;
      for i=2:n
        f = f + (x(i)-x(i-1)).^2;
      end

      g(1) = 4*x(1)-2*x(2)-2; 
      
      for i=2:n-1
        g(i) = 4*x(i)-2*x(i-1)-2*x(i+1);
      end
      
      g(n) = 4*x(n)-2*x(n-1)-2;          
      
      return        
      
%  COSINE (CUTEr)
%  Initial point: x0 = [1;1;...;1]

	case 5

		f = 0;
		
		for i=1:n-1
			f = f + cos(x(i)*x(i) - x(i+1)/2);
		end
		
		g(1) = -(2*x(1)) * sin(x(1).^2 - x(2)/2);
		
		for i=2:n-1
			g(i) = 0.5*sin(x(i-1).^2 - x(i)/2) - (2*x(i)) * sin(x(i).^2 - x(i+1)/2);
		end
		
		g(n) = 0.5*sin(x(n-1).^2 - x(n)/2);
		
		return    	
		
%  DENSCHNB  (CUTEr)
%  Initial point: x0 = [1;1;...;1]

	case 6

		f = 0;

		for i=1:n/2
			f = f + (x(2*i-1)-2).^2 + ((x(2*i-1)-2).^2)*(x(2*i).^2) + (x(2*i)+1).^2;
		end   
		       
		j = 1;
		
		for i=1:n/2
			g(j)   = 2*(x(2*i-1)-2) + 2*(x(2*i-1)-2)*x(2*i)*x(2*i);
			g(j+1) = ((x(2*i-1)-2).^2)*2*x(2*i) + 2*(x(2*i)+1);
			j      = j+2;
		end
		
		return  


%  Freudenstein & Roth
%  Initial Point: x0 = [0.5;-2;...;0.5;-2]

	case 7

		f = 0;
		j = 1;         
		
		for i=1:n/2 
			t1 = x(2*i-1) - x(2*i)*(2-x(2*i)*(5-x(2*i)))-13;
			t2 = x(2*i-1) - x(2*i)*(14-x(2*i)*(1+x(2*i)))-29;
			
			f = f + t1*t1 + t2*t2;
			
			g(j)   = 2*(t1+t2);   
			g(j+1) = 2*t1*(10*x(2*i)-3*x(2*i)*x(2*i)-2)+...
		     		 2*t2*(3*x(2*i)*x(2*i)+2*x(2*i)-14);   
			j = j+2;        
		end   
		
		return
		
%  TRIDIA  (CUTEr)
%  Initial point x0 = [1;1;...;1]

	case 8
	
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

      return
		
%  ARWHEAD (CUTEr)                             
%  Initial point: x0 = [1;1;...;1].

	case 9

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
			  
		return
      
%  NONDIA (CUTEr)
%  Initial point: x0 = [-1;-1;...;-1]

	case 10
	
		c = 100;
		
		f=(x(1)-1).^2 + c*(x(1)-x(1).^2).^2;
		
		for i=2:n
			f = f + c*(x(1)-x(i).^2).^2;
		end
		
		g(1) = 2*(x(1)-1) + 2*c*(x(1)-x(1).^2)*(1-2*x(1));        
		
		for i=2:n
			g(1) = g(1) + 2*c*(x(1)-x(i).^2);
		end  
		
		for i=2:n
			g(i) = -4*c*x(i)*(x(1)-x(i).^2);
		end        
		  
		return
      

						  
end % end switch

end % end function