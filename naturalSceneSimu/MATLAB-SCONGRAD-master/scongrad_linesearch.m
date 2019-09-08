%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         								 %%
%%                   Wolfe Line Search    				 %%
%%														 %%
%%  The calling of this function is:					 %%
%%  SCONGRAD_LineSearch(n,x,f,d,gtd,norm2d,alpha,xnew,	 %%
%%             fnew,gnew,fcnt,lscnt,lsflag)			     %%
%%  Inputs:												 %%
%%  n       : number of variables						 %%
%%  x       : current iteration							 %%
%%  f       : function value at current point  			 %%
%%  d 	    : array with search direction				 %%
%%  gtd     : scalar: grad'*d							 %%
%%  norm2d  : 2-norm of d								 %%
%%  alpha   : step length (given by LineSearch)			 %%
%%  fcnt    : current # of function evaluations			 %%
%%  lscnt   : current # of line searches				 %%
%%													     %%
%%  Outputs:											 %%
%%  xnew    : new value of x							 %%
%%  fnew    : f(xnew)									 %%
%%  gnew    : grad(xnew)								 %%
%%  fcnt    : updated # of function evaluations			 %%
%%  lscnt   : updated # of line searches				 %%
%%  lsflag  : Note if line search went over max # of     %%
%%			  allowed iterations					     %%
%%                         								 %%
%%  Written by Michael Doo			 				     %%
%%  Rensselaer Polytechnic Institute   					 %%
%%  Spring 2011						   					 %%
%%									   					 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xnew,fnew,gnew,fcnt,lscnt,lsflag] = scongrad_linesearch(n,x,f,d,gtd,norm2d,...
											   alpha,fcnt,lscnt,nexp)

% Initialize variables
	lsflag = 0;
	maxls  = 20;
	
	alphap = 0;
	fp	   = f;
	dp	   = gtd;
	
	xnew   = x + alpha*d;
	
	[fnew,gnew] = scongrad_feval(xnew,nexp);
	fcnt        = fcnt + 1;
		
	gtdnew = gnew'*d;
	
	lsiter = 0;

% Test whether the Wolfe line search conditions have been met

while ((alpha*norm2d > 1e-30) && (lsiter < maxls) && ~(gtdnew == 0 && fnew < f) && ...
       ((fnew > (f+1e-4*alpha*gtd) || abs(gtdnew/gtd) > 0.9) || (lsiter == 0 && ...
       abs(gtdnew/gtd) > 0.5)))
       
%{ 
Test whether the new point has a negative slope and a higher function value
than that corresponding to alpha=0. In this case, the search has passed through
a local max and is heading for a local min. Reduce alpha, compute the 
new corresponding point, its function value and gradient, as well as gtdnew.
Repeat this test until a good point has been found. 
%}

	if (alpha*norm2d > 1e-30 && fnew > f && gtdnew < 0)
		
		alpha 		= alpha/3;
		xnew 		= x + alpha*d;
		[fnew,gnew] = scongrad_feval(xnew,nexp);
		fcnt 		= fcnt + 1;
		
		gtdnew = gnew'*d;
		
		alphap = 0;
		fp     = f;
		dp     = gtd;
		
	end;
	
% Cubic interpolation 

	a = dp+gtdnew-3*(fp-fnew)./(alphap-alpha);
	b = a^2 - dp*gtdnew;
	
	if b > 0
		b = sqrt(b);
	else
		b = 0;
	end;
	
	alphatemp = alpha - (alpha-alphap)*(gtdnew+b-a)./(gtdnew-dp+2*b);

% Test whether the line minimum has been bracketed.

	if gtdnew./dp <= 0
%{ 
Here the minimum has been bracketed. Test whether the trial point lies sufficiently within
   the bracketed interval. If it does not, choose alphatemp as the midpoint of the interval. 
 %}
   		if ((0.99*max(alpha,alphap) < alphatemp) || (alphatemp < 1.01*min(alpha,alphap)))
   			alphatemp = (alpha+alphap)./2;
   		end;
   		
   	else
   	
 
% Here the min hasn't been bracketed. Trial point is too small, double the largest prior point 
   
   		if (gtdnew < 0 && alphatemp < 1.01*max(alpha,alphap))
   			alphatemp = 2*max(alpha,alphap);
   		end;
   		
% Trial point is too large, halve the smallest prior point 

		if ((gtdnew > 0 && alphatemp > 0.99*max(alpha,alphap)) || ...
			alphatemp < 0)
			alphatemp = min(alpha,alphap)/2;
		end;
	
	end;
	
% Save and continue the search
	
	alphap = alpha;
	fp	   = fnew;
	dp     = gtdnew;
	
	alpha  = alphatemp;
	
	xnew = x + alpha*d;
	
	[fnew,gnew] = scongrad_feval(xnew,nexp);
	fcnt = fcnt + 1;
	
	gtdnew = 0;
	gtdnew = gnew'*d;
	
	lsiter = lsiter + 1;
	
end; % End of while statement

if lsiter >= maxls
	lsflag = 1; % Note whether max iterations was exceeded
end;

if lsiter ~= 0
	lscnt = lscnt + 1; % Increase line search counter
end;

return;

end