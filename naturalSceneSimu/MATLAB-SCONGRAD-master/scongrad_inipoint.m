%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%									   %%
%%		SCONGRAD_INIPOINT			   %%
%%									   %%
%%  Initial points for problems		   %%
%%  listed in SCONGRAD_FEVAL		   %%
%%									   %%	
%%  Input:							   %%
%%		n 	 = # of variables		   %%
%%		nexp = ID of problem		   %%
%%			   to be tested			   %%
%%									   %%
%%  Output:							   %%
%%		x = initial point for given    %%
%%			function				   %%
%%									   %%
%%  Written by Michael Doo			   %%
%%  Rensselaer Polytechnic Institute   %%
%%  Spring 2011						   %%
%%									   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x] = scongrad_inipoint(n,nexp)

x = zeros(n,1); % Initialize x as column vector

switch(nexp)

% Extended Powell
	case 1
	
		i = 1;
	
		while (i<=n)
			x(i)   =  3;
			x(i+1) = -1;
			x(i+2) =  0;
			x(i+3) =  1;
			i = i+4;
		end

	return
      
% LIARWHD
	case 2

		for i=1:n
			x(i) = 4; 
		end   
		
		return 
      
% DIXON3DQ
	case 3

		for i=1:n
			x(i) = -1; 
		end   
		
		return 
      
% BIGGSB1
	case 4
	
		for i=1:n
			x(i) = 0;            
		end 
	
		return   
      
% COSINE
	case 5

		for i=1:n
			x(i) = 1; 
		end   
		
		return  
      
% DENSCHNB
	case 6

		for i=1:n
			x(i) = 1; 
		end   
		
		return

% Freudenstein & Roth
	case 7
	
		i = 1;
		while (i<=n)
			x(i)   = 0.5;
			x(i+1) = -2;
			i = i+2;
		end

		return

% TRIDIA
	case 8
		for i=1:n
			x(i) = 1; 
		end   
	
	return 
      
% ARWHEAD
	case 9
	
		for i=1:n
			x(i) = 1; 
		end   

		return 

% NONDIA
    case 10

		for i=1:n
			x(i) = -1; 
		end   

		return

end % end switch

end % end function