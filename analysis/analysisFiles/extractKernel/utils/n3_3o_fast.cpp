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
    double constNorm = 2 * var * var * (dataDims-mxl+1) * 3; 
    vector<float> stored1a;
    vector<float> stored2a;
    vector<float> stored3a;
    vector<float> stored1b;
    vector<float> stored2b;
    vector<float> stored3b;
    stored1a.resize(dataDims);
    stored2a.resize(dataDims); 
    stored3a.resize(dataDims); 
    stored1b.resize(dataDims);
    stored2b.resize(dataDims); 
    stored3b.resize(dataDims); 
	for(int tau3=0; tau3 < mxl; tau3++){
        for(int t=mxl-1; t<dataDims; t++){
            stored1a[t] = resp[t] * input2[t-tau3] / constNorm;
            stored2a[t] = resp[t] * input3[t-tau3] / constNorm;
            stored3a[t] = resp[t] * input1[t-tau3] / constNorm;
        }
		for(int tau2=0; tau2 < mxl; tau2++){
            for(int t=mxl-1; t<dataDims; t++){
                stored1b[t] = stored1a[t] * input1[t-tau2];
                stored2b[t] = stored2a[t] * input2[t-tau2];
                stored3b[t] = stored3a[t] * input3[t-tau2];
            }
            for(int tau1=0; tau1 < mxl; tau1++){
                for(int t=mxl-1; t < dataDims; t++){
                    kernel[tau1+mxl*tau2+mxl*mxl*tau3] += 
                            stored1b[t]*input1[t-tau1] +
                            stored2b[t]*input2[t-tau1] + 
                            stored3b[t]*input3[t-tau1];
                }
            }
        }
	}
    
	return;
}
