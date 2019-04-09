// Extracting 2D kernels from 2 inputs + 1 response vector

#include <iostream>
#include <math.h>
#include <cmath>
#include <mex.h>
#include <vector>

using namespace std;

void _main();

void mexFunction(	
	int nlhs, mxArray *plhs[],
	int nrhs, const mxArray *prhs[])
	{
	
	// declare variables
	mxArray *maxLen_in, *inVar_in, *input1_in, *input2_in, *resp_in, *kernel_out;
	double *input1, *input2, *resp, *kernel, *maxLen, *inVar;
	
	// associate inputs
	maxLen_in = mxDuplicateArray(prhs[0]);
    inVar_in = mxDuplicateArray(prhs[1]);
	input1_in = mxDuplicateArray(prhs[2]);
	input2_in = mxDuplicateArray(prhs[3]);
	resp_in = mxDuplicateArray(prhs[4]);
	
	// get maxLen and input variance
	maxLen = mxGetPr(maxLen_in);
	int mxl = *maxLen;
	double size = mxl*mxl;
    inVar = mxGetPr(inVar_in);
	
	// get length of resp/input vectors
	int dataDims = mxGetNumberOfElements(prhs[2]);
    
	// associate outputs
	kernel_out = plhs[0] = mxCreateDoubleMatrix(1,size,mxREAL);
         
	// associate pointers	
	input1 = mxGetPr(input1_in);
	input2 = mxGetPr(input2_in);
	resp = mxGetPr(resp_in);
	kernel = mxGetPr(kernel_out);

	// compute kernel 
    for(int diag = 0; diag < mxl - 4; diag++){       
        for(int t=mxl-1; t<dataDims; t++){
            for(int tau1=diag+1; tau1 < diag+5; tau1++){
                kernel[tau1+mxl*diag] += resp[t]*input1[t-tau1]*input2[t-diag];
            }
            for(int tau2=diag+1; tau2 < diag+5; tau2++){
                kernel[diag+mxl*tau2] += resp[t]*input1[t-diag]*input2[t-tau2];
            }
        }
    }
    
    // normalize
    double constNorm = *inVar * *inVar * (dataDims-mxl+1);
    
        // You can show on paper that this is the magnitude of the normalization constant
        // by writing out the response as a 2d convolution against the filter you want,
        // writing out the cross-correlation against these two inputs, and moving 
        // integrals around (Fubini's thm). However, for higher-D filters it won't generally
        // be this simple - see Schetzen 1980, chapter 10, the thing about combinations of ordering,
        // and note that this is a different case in which input 1 and input 2 are different variables,
        // changing the total number of possible permutations. 

    for(int tau1=0; tau1 < mxl; tau1++){
        for(int tau2=0; tau2 < mxl; tau2++){
            kernel[tau1+mxl*tau2] = kernel[tau1+mxl*tau2] / constNorm;
        }
    }
    
	return;
}
