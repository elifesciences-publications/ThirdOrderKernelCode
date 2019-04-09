// 2D "Forward Filtering"
// MATLAB has a 2D filtering native function that takes a 2D input and a 2D
// filter. You could use this by making the input 2D (outer product of the 
// two inputs) but then the response we want would be the diagonal of 
// the result - clearly a lot of wasted computation. 

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
	mxArray *maxLen_in, *input1_in, *input2_in, *kernel_in, *resp_out;
	double *input1, *input2, *resp, *kernel, *maxLen;
	
	// associate inputs
	maxLen_in = mxDuplicateArray(prhs[0]);
	input1_in = mxDuplicateArray(prhs[1]);
	input2_in = mxDuplicateArray(prhs[2]);
	kernel_in = mxDuplicateArray(prhs[3]);
	
	// make maxLen an int
	maxLen = mxGetPr(maxLen_in);
	const int mxl = (const int)*maxLen;
	
	// get length of input vectors; resp needs to be shorter
	int inDims = mxGetNumberOfElements(prhs[1]);
    int respDims = inDims - mxl + 1;
    
	// associate outputs
	resp_out = plhs[0] = mxCreateDoubleMatrix(1,respDims,mxREAL);
    
	// associate pointers	
	input1 = mxGetPr(input1_in);
	input2 = mxGetPr(input2_in);
	kernel = mxGetPr(kernel_in);
    resp = mxGetPr(resp_out);

    // compute response
    vector<float> store;
    store.resize(mxl); 
    for(int t=0; t < respDims; t++){
        for(int tau2=0; tau2 < mxl; tau2++){
            store[tau2] = input1[tau2-t] * kernel[mxl*tau2];
            for(int tau1 = 0; tau1 < mxl; tau1++){
                resp[t] += input1[tau1-t] * kernel[tau1 + mxl*tau2];
            }
        }
    }
    
	return;
}
