%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%										      %%
%%		SCONGRAD Testing Script				  %%
%%											  %%
%%  This script compares the SCONGRAD		  %%
%%  minimization algorithm against 			  %%
%%  MATLAB's built-in FMINUNC. It times		  %%
%%  both algorithms and outputs relevant	  %%
%%  data about both. 						  %%
%%											  %%
%%  Note that the user can modify the 		  %%
%%  script slightly to output even more 	  %%
%%  information about the SCONGRAD algorithm  %%
%%  such as number of restarts and number of  %%	
%%  line searches taken. 					  %%
%%											  %%
%%  Likewise, more information can be 		  %%
%%  displayed from FMINUNC. Please see		  %%
%%  relevant MATLAB documentation.			  %%
%%									   		  %%
%%  Written by Michael Doo			   		  %%
%%  Rensselaer Polytechnic Institute   		  %%
%%  Spring 2011						   		  %%
%%									   		  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scongrad_main

% If tetas = 1, spectral updating of theta
% If thetaa = 1, anticipative updating of theta
tetas  = 1;
thetaa = 0; 

% Choose stoptest. See scongrad.m for more details.
stoptest = 1;

% Set convergence tolerance and # of max iterations
epsg    = 1e-6;
epsf    = 1e-10;
maxiter = 2000;
delta   = 10.1;

% Set options for fminunc
options = optimset('GradObj','off','Display','off');

% Set number of columns
total_columns = 5; % Should be n/100

% Initialize data columns as 0
[ndata,nexpdata,iterdata,fcntdata,t1tocdata,fxnewdata,...
    outputiterdata,outputfuncdata,t2tocdata,fvaldata,...
    diffdata] = deal(zeros(50,total_columns)); 

% Begin testing
for n = 100:100:500
	for nexp = 1:10

		% Reset fcnt, lscnt, x0 for each iteration
		fcnt  = 0;
		lscnt = 0;
		x0    = scongrad_inipoint(n,nexp);
		
		% Start timer and run SCONGRAD
		t1tic = tic;
		[fxnew,gnorm,iter,irstart,fcnt,lscnt] = scongrad(n,x0,epsg,...
			epsf,delta,maxiter,stoptest,fcnt,lscnt,tetas,thetaa,nexp);
		t1toc = toc(t1tic);
		
		% Start time and run FMINUNC
		t2tic = tic; 
		switch nexp % Choose given experiment
			case 1
				[x,fval,exitflag,output] = fminunc(@scongrad_func1,x0,options);
			case 2
				[x,fval,exitflag,output] = fminunc(@scongrad_func2,x0,options);
			case 3
				[x,fval,exitflag,output] = fminunc(@scongrad_func3,x0,options);
			case 4
				[x,fval,exitflag,output] = fminunc(@scongrad_func4,x0,options);
			case 5
				[x,fval,exitflag,output] = fminunc(@scongrad_func5,x0,options);
			case 6
				[x,fval,exitflag,output] = fminunc(@scongrad_func6,x0,options);
			case 7
				[x,fval,exitflag,output] = fminunc(@scongrad_func7,x0,options);
			case 8
				[x,fval,exitflag,output] = fminunc(@scongrad_func8,x0,options);
			case 9
				[x,fval,exitflag,output] = fminunc(@scongrad_func9,x0,options);
			case 10
				[x,fval,exitflag,output] = fminunc(@scongrad_func10,x0,options);
		end
		
		t2toc = toc(t2tic);
		
		curr_column = n / 100;
		
		% Store data in column arrays
		ndata(nexp,curr_column) 		 = n;
		nexpdata(nexp,curr_column) 		 = nexp;
		iterdata(nexp,curr_column) 		 = iter;
		fcntdata(nexp,curr_column) 		 = fcnt;
		t1tocdata(nexp,curr_column)		 = t1toc;
		fxnewdata(nexp,curr_column)		 = fxnew;
		outputiterdata(nexp,curr_column) = output.iterations; 
		outputfuncdata(nexp,curr_column) = output.funcCount;
		t2tocdata(nexp,curr_column)		 = t2toc;
		fvaldata(nexp,curr_column)		 = fval;
		diffdata(nexp,curr_column)		 = abs(fval-fxnew);
		timediffdata(nexp,curr_column)	 = abs(t2toc-t1toc);
		
    end
end

% Write data to text file
header = ['nexp     n	 iter 	 fcnt	 time1	   fxnew	  MATLAB iter ' ...
		' 	MATLAB fcnt      time2	     fval	difference  time diff\n'];
format = ['%2d %8d %8d %8d %8.3f %13.5g %13d %13d %13.3f %13.5g %13.3e %8.4f\n'];
fid = fopen('doom2_results.txt', 'w');
fprintf(fid,header);
	for j = 1:10
		for t = 1:total_columns
			fprintf(fid,format,nexpdata(j,t),ndata(j,t),iterdata(j,t),fcntdata(j,t),...
			t1tocdata(j,t),fxnewdata(j,t),outputiterdata(j,t),outputfuncdata(j,t),...
			t2tocdata(j,t),fvaldata(j,t),diffdata(j,t),timediffdata(j,t));
		end
	end
fclose(fid);

end