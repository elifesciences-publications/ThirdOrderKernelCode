#pragma once
bool extract_multiple_kernels(vector<float*> respArrays, vector<float*> stimulus1Arrays,
							  vector<float*> stimulus2Arrays, vector<int> respLengths,
							  vector<int> numROIs, vector<float*> outputKernels,
							  string& errorString);

bool extract_multiple_1D_kernels(const int maxTau, const vector<float*> respArrays,
								 const vector<float*> stimulusArrays, const vector<int> respLengths,
								 const vector<int> numROIs, const vector<float*> outputKernels,
								 string& errorString);