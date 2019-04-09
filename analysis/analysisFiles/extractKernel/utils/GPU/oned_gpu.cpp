#include "mex.h"
#include "matrix.h"
#include <tuple>
#include <vector>
#include <string>

using namespace std;

#include "extract_kernel.h"

tuple<vector<float*>,vector<int>,vector<int>,size_t> extractFromCellArray(mxArray* inputCellArray) {

	size_t numBarPairs;
	numBarPairs = mxGetNumberOfElements(inputCellArray);

	vector<float*> outputData;
	vector<int> outputRespLengths;
	vector<int> outputNumROIs;
	for (mwIndex index = 0; index < numBarPairs; index++)
	{
		const mxArray* arrayPtr  = mxGetCell(inputCellArray,index);
		const mwSize* dims;
		mwSize numDims;
		numDims = mxGetNumberOfDimensions(arrayPtr);
		if (numDims != 2)
			mexErrMsgIdAndTxt("onedkernelextract:dims",
							  "Requires array cells to have two dimensions: time and ROIs");
		dims = mxGetDimensions(arrayPtr);
		size_t respLength = dims[0];
		size_t numROI = dims[1];
		if (!mxIsSingle(arrayPtr))
			mexErrMsgIdAndTxt("onedkernelextract:nrhs", "Requires data of type Single");
		float* data = static_cast<float*>(mxGetData(arrayPtr));
		outputData.push_back(data);
		outputRespLengths.push_back(respLength);
		outputNumROIs.push_back(numROI);
	}
	return make_tuple(outputData, outputRespLengths, outputNumROIs, numBarPairs);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]) {
	if (nrhs != 3 || !mxIsNumeric(prhs[0])
		|| mxGetNumberOfElements(prhs[0]) != 1 || mxIsComplex(prhs[0])
		|| !mxIsCell(prhs[1]) || !mxIsCell(prhs[2])) 
		mexErrMsgIdAndTxt("onedkernelextract:nrhs", "Requires one scalar and two cell arrays");
	if (nlhs != 1)
		mexErrMsgIdAndTxt("onedkernelextract:nlhs", "Outputs one cell array");

	int maxTau = round(mxGetScalar(prhs[0]));
	vector<float*> stims, resps, outputKernels;
	vector<int> respLengths, numROIs, newRespLengths, newNumROIs;
	size_t numBars, newNumBars;
	tie(stims, respLengths, numROIs, numBars) = extractFromCellArray(prhs[1]);

	tie(resps , newRespLengths, newNumROIs, newNumBars) = extractFromCellArray(prhs[2]);
	if (newNumBars == 1) //If only given one response, assume it applies to all bar pairs
	{
		resps = vector<float*>(numBars, resps[0]);
		newRespLengths = vector<int>(numBars,newRespLengths[0]);
		newNumROIs = vector<int>(numBars,newNumROIs[0]);
	}
	else if (newNumBars != numBars)
		mexErrMsgIdAndTxt("onedkernelextract:dims", "Stimulus and Response do not contain the same number of bars");
	for (int i = 0; i < numBars; i++) {
		if (newRespLengths[i] != respLengths[i])
			mexErrMsgIdAndTxt("onedkernelextract:dims", "Stimulus and Response are not the same length in time");
		if (newNumROIs[i] != numROIs[i])
			mexErrMsgIdAndTxt("onedkernelextract:dims", "Stimulus and Response do not contain the same number of ROIs");
	}

	mxArray* outputCell = mxCreateCellMatrix(numBars, 1);
	for (int i = 0; i < numBars; i++) {
		size_t ndim = 2;
		vector<size_t> dims = { (size_t)maxTau, (size_t)numROIs[i] };
		mxArray* outputArray = mxCreateUninitNumericArray(ndim,dims.data(),mxSINGLE_CLASS,mxREAL);
		mxSetCell(outputCell, i, outputArray);
		outputKernels.push_back(static_cast<float*>(mxGetData(outputArray)));
	}

	string errorString = "";
	bool failure = extract_multiple_1D_kernels(maxTau, resps, stims, respLengths, numROIs, outputKernels, errorString);
	
	errorString.insert(0,"GPU extraction failed.\n");
	if(failure)
		mexErrMsgIdAndTxt("onedkernelextract:extract", errorString.c_str());

	plhs[0] = outputCell;
}