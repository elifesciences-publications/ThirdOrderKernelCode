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
            mexErrMsgIdAndTxt("twodkernelextract:dims",
                    "Requires array cells to have two dimensions: time and ROIs");
        dims = mxGetDimensions(arrayPtr);
        size_t respLength = dims[0];
        size_t numROI = dims[1];
        if (!mxIsSingle(arrayPtr))
            mexErrMsgIdAndTxt("twodkernelextract:nrhs", "Requires data of type Single");
        float* data = static_cast<float*>(mxGetData(arrayPtr));
        outputData.push_back(data);
        outputRespLengths.push_back(respLength);
        outputNumROIs.push_back(numROI);
    }
    return make_tuple(outputData, outputRespLengths, outputNumROIs, numBarPairs);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]) {
    if (nrhs != 4 || !mxIsNumeric(prhs[0]) 
    || mxGetNumberOfElements(prhs[0]) != 1 || mxIsComplex(prhs[0])
    || !mxIsCell(prhs[1]) || !mxIsCell(prhs[2]) || !mxIsCell(prhs[3]))
        mexErrMsgIdAndTxt("twodkernelextract:nrhs", "Requires three cell arrays");
    if (nlhs != 1)
        mexErrMsgIdAndTxt("twodkernelextract:nlhs", "Outputs one cell array");
    
    size_t maxTau = round(mxGetScalar(prhs[0]));
    vector<float*> stim1s, stim2s, resps, outputKernels;
    vector<int> respLengths, numROIs, newRespLengths, newNumROIs;
    size_t numBarPairs, newNumBarPairs;
    tie(stim1s, respLengths, numROIs, numBarPairs) = extractFromCellArray(prhs[1]);
    
    tie(stim2s, newRespLengths, newNumROIs, newNumBarPairs) = extractFromCellArray(prhs[2]);
    if (newNumBarPairs != numBarPairs)
        mexErrMsgIdAndTxt("twodkernelextract:dims", "Stimulus1 and Stimulus 2 do not contain the same number of bars");
    for (int i = 0; i < numBarPairs; i++) {
        if (newRespLengths[i] != respLengths[i])
            mexErrMsgIdAndTxt("twodkernelextract:dims", "Stimulus1 and Stimulus 2 are not the same length in time");
        if (newNumROIs[i] != numROIs[i])
            mexErrMsgIdAndTxt("twodkernelextract:dims", "Stimulus1 and Stimulus 2 do not contain the same number of ROIs");
    }
    
    tie(resps , newRespLengths, newNumROIs, newNumBarPairs) = extractFromCellArray(prhs[3]);
    if (newNumBarPairs == 1) //If only given one response, assume it applies to all bar pairs
    {
        resps = vector<float*>(numBarPairs, resps[0]);
        newRespLengths = vector<int>(numBarPairs,newRespLengths[0]);
        newNumROIs = vector<int>(numBarPairs,newNumROIs[0]);
    }
    else if (newNumBarPairs != numBarPairs)
        mexErrMsgIdAndTxt("twodkernelextract:dims", "Stimulus1 and Response do not contain the same number of bars");
    for (int i = 0; i < numBarPairs; i++) {
        if (newRespLengths[i] != respLengths[i])
            mexErrMsgIdAndTxt("twodkernelextract:dims", "Stimulus1 and Response are not the same length in time");
        if (newNumROIs[i] != numROIs[i])
            mexErrMsgIdAndTxt("twodkernelextract:dims", "Stimulus1 and Response do not contain the same number of ROIs");
    }
    
    mxArray* outputCell = mxCreateCellMatrix(numBarPairs, 1);
    for (int i = 0; i < numBarPairs; i++) {
        size_t ndim = 3;
        vector<size_t> dims = {maxTau,maxTau, (size_t)numROIs[i] };
        mxArray* outputArray = mxCreateUninitNumericArray(ndim,dims.data(),mxSINGLE_CLASS,mxREAL);
        mxSetCell(outputCell, i, outputArray);
        outputKernels.push_back(static_cast<float*>(mxGetData(outputArray)));
    }
    
    string errorString = "";
    bool failure = extract_multiple_kernels(resps, stim1s, stim2s, respLengths, numROIs, outputKernels, errorString);
    
    errorString.insert(0,"GPU extraction failed.\n");
    if(failure)
        mexErrMsgIdAndTxt("twodkernelextract:extract", errorString.c_str());
    
    plhs[0] = outputCell;
}