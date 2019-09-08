#include <utility>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <iterator>
#include <random>
#include <chrono>
#include <iomanip>

using namespace std;
#include "extract_kernel.h"

const int respLength = 72000;
const int maxTau = 64;
const int numROI = 200;
const int numBarPairs = 20;

int main(void){

    //--------Set Up Input Data (REPLACE WITH MATLAB POINTERS)---------//
    vector< float > response (respLength*numROI);
    vector< float > stimulus1(respLength*numROI);
    vector< float > stimulus2(respLength*numROI);

    random_device rd;
	int seed = 0;//rd();
	minstd_rand random_engine(seed);
    uniform_real_distribution<float> uniform_dist(-1,1);

    for (int i = 5; i < response.size(); i++) {
      stimulus1[i]  = uniform_dist(random_engine);
      stimulus2[i]  = uniform_dist(random_engine);
	  response[i] = stimulus1[i - 1] * stimulus2[i - 2];
    }

	//Vector of vectors that each contain an output kernel
	vector<vector< float >> outputKernels(numBarPairs, vector<float>(64 * 64 * numROI));

	//Prepare input arrays
	vector <float*> respArrays, stimulus1Arrays, stimulus2Arrays;
	vector<int> respLengths, numROIs;
	vector<float*> outputKernelPointers;
	for (int i = 0; i < numBarPairs; i++) {
		respArrays.push_back(response.data());
		stimulus1Arrays.push_back(stimulus1.data());
		stimulus2Arrays.push_back(stimulus2.data());
		respLengths.push_back(respLength);
		numROIs.push_back(numROI);
		outputKernelPointers.push_back(outputKernels[i].data());
	}
	chrono::time_point<chrono::high_resolution_clock> start, end;
	chrono::duration<double> elapsed_seconds(0);
	start = chrono::high_resolution_clock::now();
	bool failed = 0;
	string errorString;
	failed = extract_multiple_1D_kernels(128, respArrays, stimulus1Arrays, respLengths, numROIs, outputKernelPointers,errorString);
	end = chrono::high_resolution_clock::now();
	elapsed_seconds += end - start;
	if (failed){
		cerr << errorString << endl;
		return EXIT_FAILURE;
	}

	/*failed = extract_multiple_kernels(respArrays, stimulus1Arrays, stimulus2Arrays,
										   respLengths,numROIs,outputKernelPointers);

	end = chrono::high_resolution_clock::now();
	elapsed_seconds += end - start;
	if (failed)
		return EXIT_FAILURE;

	//--------Output Some Diagnostics---------//
	cout << "Elapsed time for " << numROI * numBarPairs << " kernels was "
		<< elapsed_seconds.count() << " seconds " << endl;

	cout << "(tau1,tau2):" << endl;
	vector<float> output = outputKernels[0];
	float maximum = 0;
	int maxTau1 = 0, maxTau2 = 0;
	for (int tau2 = 0; tau2 < 64; tau2++) {
		for (int tau1 = 0; tau1 < 64; tau1++) {
			float currValue = abs(output[tau1 + 64 * tau2 + 64 * 64 * 0]);
			if (currValue > maximum) {
				maxTau1 = tau1; maxTau2 = tau2;
				maximum = currValue;
			}
			//        if (abs(output[i*64 + j]/(timepointsPerKernel*18)) > 0.0005)
			//          cout << "(" << i << "," << j << ")" << endl;
		}
	}
	cout << "(" << maxTau1 << "," << maxTau2 << ") = " << maximum << endl;

	for (int i = 0; i < 5; i++) {
		for (int j = 0; j < 5; j++) {
			cout << fixed << setprecision(3) << setw(7) << output[i * 64 + j] << " ";
		}
		cout << endl;
	}*/

	return EXIT_SUCCESS;
}
