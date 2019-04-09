// Extracting 3D kernels from three input + 1 response vector

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
	mxArray *maxLen_in, *inVar_in, *input1_in, *input2_in, *input3_in, *resp_in, *kernel_out;
	double *input1, *input2, *input3, *resp, *kernel, *maxLen, *inVar;
	
	// associate inputs
	maxLen_in = mxDuplicateArray(prhs[0]);
	inVar_in = mxDuplicateArray(prhs[1]);
    input1_in = mxDuplicateArray(prhs[2]);
	input2_in = mxDuplicateArray(prhs[3]);
	input3_in = mxDuplicateArray(prhs[4]);
	resp_in = mxDuplicateArray(prhs[5]);
	
	// get maxLen
	maxLen = mxGetPr(maxLen_in);
	int mxl = *maxLen;
	double size = mxl*mxl*mxl;
    inVar = mxGetPr(inVar_in);
	
	// get length of resp/input vectors
	int dataDims = mxGetNumberOfElements(prhs[2]);

	// associate outputs
	kernel_out = plhs[0] = mxCreateDoubleMatrix(1,size,mxREAL);
	
	// associate pointers	
	input1 = mxGetPr(input1_in);
	input2 = mxGetPr(input2_in);
	input3 = mxGetPr(input3_in); 
	resp = mxGetPr(resp_in);
	kernel = mxGetPr(kernel_out);

	// compute kernel 
    
    double var = *inVar;
    double constNorm = 2 * var * var * (dataDims-mxl+1);
    
    // the strange indexing here (taus starting at diag v diag+1) is deliberate   
    for(int diag = 0; diag < mxl - 4; diag++){       
        for(int t=mxl-1; t<dataDims; t++){
            for(int tau1=diag; tau1 < diag+5; tau1++){
                for(int tau2=diag; tau2 < diag+5; tau2++){
                	kernel[tau1+mxl*tau2+mxl*mxl*diag] += resp[t]*input1[t-tau1]*input2[t-tau2]*input3[t-diag] / constNorm;
                }
            }    
            for(int tau2=diag+1; tau2 < diag+5; tau2++){ 
                for(int tau3=diag+1; tau3 < diag+5; tau3++){
                	kernel[diag+mxl*tau2+mxl*mxl*tau3] += resp[t]*input1[t-diag]*input2[t-tau2]*input3[t-tau3] / constNorm;
                }
            }
            for(int tau1=diag; tau1 < diag+5; tau1++){
                for(int tau3=diag+1; tau3 < diag+5; tau3++){
                	kernel[tau1+mxl*(diag)+mxl*mxl*tau3] += resp[t]*input1[t-tau1]*input2[t-(diag)]*input3[t-tau3] / constNorm;
                }
            }
        }
    }
    
	return;
}
