%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%																		  %%
%%								  SCONGRAD								  %%
%%																		  %%
%%	Scaled Conjugate Gradient Method									  %%
%%																		  %%
%%  SCONGRAD is a function to compute the minimum of a differentiable	  %%
%%  function with a large number of variables. SCONGRAD implements a      %%
%%  scaled conjugate gradient algorithm. This function is accompanied by  %% 
%%  the function scongrad_linesearch which implements the Wolfe line 	  %%
%%  search.								  								  %%
%%																		  %%																  %%
%%  Inputs:																  %%
%%  																	  %%
%%  n			# of variables									     	  %%
%%  x			Initial point											  %%
%%  epsg		convergence tolerance for gradient						  %%
%%  epsf		convergence tolerance for function						  %%
%%  delta		parameter used in anticipative selection of				  %%
%%				the scaling factor of the gradient. It has a 			  %%
%%				value comparable with the function's value at			  %%
%%				the current point.										  %%
%%  maxiter		maximum number of iterations							  %%
%%  stoptest	parameter for selection of stopping criterion			  %%
%%				If = 1, then the test is:						     	  %%
%%					if(infnormgk <= epsg)								  %%
%%				If = 2, then the test is:								  %%
%%					if(infnormgk <= max(epsg, epsf*infnormg)			  %%
%%				If = 3, then the test is:								  %%
%%					if(norm2g <= epsg)									  %%
%%				If = 4, then the test is:								  %%
%%					if(norm2g <= epsg*max(1, abs(fx))					  %%
%%				If = 5, then the test is:								  %%
%%					if(infnormgk <= epsg/sqrt(n))						  %%
%%				If = 6, then the test is:								  %%
%%					if(infnormgk < epsg | abs(alfa*gtd) < epsf*abs(fx))	  %%
%%																		  %%
%%				where:													  %%
%%																		  %%
%%				infnormgk = infinite norm of gradient g(xk)	  			  %%
%%				infnormg  = infinite norm of gradient g(x0)				  %%
%%				norm2g    = 2-norm of gradient g(xk)					  %%
%%																		  %%
%%  tetas		If 1, then the spectral formula is used					  %%
%%  thetaa		If 1, then anticipative formula is used 				  %%
%%																		  %%
%%  Outputs:															  %%
%%																		  %%
%%  fx			function value at optimal point							  %%
%%  norm2g		2-norm of gradient at optimal point						  %%
%%  iter		# of iterations to get to optimal point					  %%
%%  irstart		# of restart iterations									  %%
%%  fcnt		# of function evaluations								  %%
%%  lscnt		# of line searches										  %%
%%																		  %%
%%  SCONGRAD calls the function to be minimized with the SCONGRAD_FEVAL	  %%
%%  function. SCONGRAD_FEVAL supplies a function value and its gradient.  %%
%%  Please see SCONGRAD_FEVAL for more details.							  %%
%%																		  %%
%%  SCONGRAD also calls a line search function SCONGRAD_LINESEARCH to 	  %%
%%  determine a new x, f(x), and grad(x). 								  %%
%%  Please see SCONGRAD_LINESEARCH for more details.					  %%
%%																		  %%
%%  Written by Michael Doo			   		  							  %%
%%  Rensselaer Polytechnic Institute   		  							  %%
%%  Spring 2011						   		  							  %%
%%									   		  							  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fx,norm2g,iter,irstart,fcnt,lscnt]=scongrad(n,x,epsg,...
						  epsf,delta,maxiter,stoptest,fcnt,lscnt,tetas,thetaa,nexp)

% Step 1 - Initialization and check

if (stoptest<1 || stoptest>6) % Throw error if stoptest is not valid
	error('doom2:stoptestInvalid','Stoptest must be between 1 & 6.');
	return
end

epsinf    = epsg/sqrt(n);

iter      = 0; % Initialize counters and such
irstart   = 0;
fcnt      = 0;
lscnt     = 0;

[fx,grad] = scongrad_feval(x,nexp); % Get initial f(x) & grad(x)
fcnt 	  = fcnt+1; % Increase function counter

d         = -grad; 
gtg       = grad'*grad; 
infnormg  = norm(grad,inf); 

gtd       = -gtg;
norm2g    = norm(grad,2);
norm2d    = norm2g; 
gtdr      = gtd;
dtd       = gtg; 

% Step 2 - Line search from initial point 
% Initially, alpha = 1/norm of gradient(x0).
% Compute: xnew = x + alpha*d, fnew=f(xnew), gradnew = gradient(xnew)

if norm2g ~= 0
	alfa = 1/norm2g; % Spelled 'alfa' to avoid confusion with MATLAB function 'alpha'
end

[xnew,fxnew,gradnew,fcnt,lscnt,lsflag] = scongrad_linesearch(n,x,fx,d,gtd,norm2d,...
										 alfa,fcnt,lscnt,nexp);

% Step 3 - Compute s and y. Prepare test for continuation

s     	  = xnew - x;
y     	  = gradnew - grad;
gtg   	  = gradnew'*gradnew; 
infnormgk = norm(gradnew,inf);
norm2g 	  = norm(gradnew,2);

% Step 4 - Stop test for initial point

if (norm2g < epsg*max(1,abs(fxnew))) 
	return 
end

% Step 5 - Continue iterations

iter = iter + 1;

while 1 % Forever do
		
		% Here begins the restart iterations
		% SCONGRAD only comes back up here if Powell restart
		% criterion are met
		
		% Step 6 - Compute theta
		
		% Spectral Formula
		
		if tetas == 1
			sts = s'*s; 
			sty = s'*y;
			
			if sty <= 0
				theta = 1e10;
			else
				theta = min(1e10,max(1e-10,sts/sty));
			end;
		end;
		
		% Anticipative Formula
		
		if thetaa == 1		
		
			gamma = 2*(fxnew - fx - alfa*gtdr)/(dtd*(alfa.^2));
						
			if gamma <= 0
				eta    = (fx - fxnew + alfa*gtdr + delta)/gtdr;
				alfan  = alfa - eta;
				gamma  = 2*(fxnew-fx-alfan*gtdr)/(dtd*alfan*alfan);
			end
			
			theta = 1/gamma;
		end
		
		% Step 7 - Update function value and norm of direction
		
		fx		  = fxnew;
		norm2dpre = norm2d;
		
		% Step 8 - Compute direction d
		% Update x and grad
		% Prepare for line search with new direction
		% Compute gtd and dtd
		
		x    = xnew;
		grad = gradnew; 
		gts  = grad'*s;
		gty  = grad'*y;
		yts  = y'*s; 
		yty  = y'*y;
		
		if yts ~= 0
			coef = 1 + theta*yty/yts;
			d    = -theta*grad + theta*(gts/yts)*y - ...
			       (coef*gts/yts - theta*gty/yts)*s;
			gtd  = grad'*d; 
			dtd  = d'*d;
		end
		
		if yts == 0
			d   = -theta*grad;
			gtd = grad'*d;
			dtd = d'*d; 
		end
		
		norm2d = norm(d,2); 
		gtdr   = gtd;
		
		% Step 9 - Line Search
		% Initialize alpha and then with this value compute the step length.
		% Compute: xnew = x + alfa*d, fnew=f(xnew), gradnew = grad(xnew)
		
		alfa = alfa * (norm2dpre/norm2d);
		
		[xnew,fxnew,gradnew,fcnt,lscnt,lsflag] = scongrad_linesearch(n,x,fx,d,gtd,norm2d,...
                                          alfa,fcnt,lscnt,nexp);

		% Step 10 - Store theta
		
		thetas = theta; 
		
		% Step 11 - Compute s and y. Store these vectors for normal computation.
		% Prepare for stopping test.
				
		s     	   = xnew - x; 
		y     	   = gradnew - grad;
		ss    	   = s; 
		ys    	   = y; 
		gtg   	   = gradnew'*gradnew; 
		g1tg 	   = gradnew'*grad; 
		infnormgk  = norm(gradnew,inf);
		norm2g 	   = norm(gradnew,2); 
		
		% Step 12 - First test of stopping criterion
		
		switch stoptest
			case 1
				if infnormgk <= epsg
					return
				end
			case 2
				if infnormgk <= max(epsg,epsf*infnormg)
					return
				end
			case 3
				if norm2g <= epsg
					return
				end
			case 4
				if norm2g <= epsg*max(1,abs(fxnew))
					return
				end
			case 5
				if infnormgk <= epsinf
					return
				end
			case 6
				if ((infnormgk < epsg) || (abs(alfa*gtd) <= epsf*(abs(fxnew))))
					return
				end
		end
		
		% Step 13 - If stopping test isn't satisfied, continue iterations
		
		while abs(g1tg) < 0.2*gtg % Loop until Powell restart criterion are met.
		
				iter = iter + 1;
				if iter > maxiter
					display('Too many iterations.');
					return
				end
								
				% Step 15 - Normal iteration begins again
				% The Powell restart criterion is not satisfied. Compute the direction
				% using the BFGS update
				
				fx 		  = fxnew;
				norm2dpre = norm2d; 
				
				% Step 16 - Compute v, w, d
								
				x    	= xnew; 
				grad 	= gradnew; 
				gts     = grad'*ss;
				gty     = grad'*ys; 
				yts     = ys'*ss; 
				yty     = ys'*ys; 
				yks     = y'*ss; 
				yky     = y'*ys; 
				gts1    = grad'*s;
				yts1    = y'*s; 
				
				coef = 1 + thetas*yty/yts;
				
				v   = thetas*grad-thetas*(gts/yts)*ys+...
					   (coef*gts/yts-thetas*gty/yts)*ss;
				
				w   = thetas*y-thetas*(yks/yts)*ys+...
					   (coef*yks/yts-thetas*yky/yts)*ss;
				
				gtw = grad'*w;
				ytw = y'*w;
				
				% Step 17 - Prepare for line search for this direction: gtd, dtd
				% 	Here compute d(k+1)
				
				d      = -v+(gts1*w+gtw*s)/yts1-(1+ytw/yts1)*(gts1/yts1)*s; 
				gtd    = grad'*d;
				dtd    = d'*d; 
				norm2d = norm(d,2);
				gtdr   = gtd; 
				
				% Step 18 - Line Search
				% Initialize alpha and with this value compute step length.
				% Compute: xnew = x + alfa*d, fnew=f(xnew), gradnew=gradient(xnew)
				
				alfa = alfa*(norm2dpre/norm2d);
				
				[xnew,fxnew,gradnew,fcnt,lscnt,lsflag] = scongrad_linesearch(n,x,...
								fx,d,gtd,norm2d,alfa,fcnt,lscnt,nexp);
				
				% Step 19 - Compute s and y. Prepare for test of continuation
				
				s 		  = xnew-x;
				y 		  = gradnew-grad; 
				gtg  	  = gradnew'*gradnew;
				g1tg 	  = gradnew'*grad;
				infnormgk = norm(gradnew,inf);
				
				norm2g = norm(gradnew,2);
				
				% Step 20 - Test of stopping criterion...again
				
				switch stoptest
					case 1
						if infnormgk <= epsg
							return
						end
					case 2
						if infnormgk <= max(epsg,epsf*infnormg)
							return
						end
					case 3
						if norm2g <= epsg
							return
						end
					case 4
						if norm2g <= epsg*max(1,abs(fxnew))
							return
						end
					case 5
						if infnormgk <= epsinf
							return
						end
					case 6
						if ((infnormgk < epsg) || abs(alfa*gtd) <= epsf*(abs(fxnew)))
							return
						end
				end
	
		end % ends while loop for restart criterion 

end % Infinite loop is infinite!

end