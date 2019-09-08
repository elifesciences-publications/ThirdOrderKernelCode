#include <utility>
#define __CL_ENABLE_EXCEPTIONS
#include <CL/cl.hpp>

#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <iterator>
#include "OpenCLErrorStrings.h"
#include "openCLKernels.h"

using namespace std;

const int numQueues = 1;


bool extract_multiple_1D_kernels(const int maxTau, const vector<float*> respArrays,
								 const vector<float*> stimulusArrays, const vector<int> respLengths,
								 const vector<int> numROIs, const vector<float*> outputKernels,
								 string& errorString) {
	try {
		//------Grab the correct device---------//
		vector< cl::Platform > platformList;
		cl::Platform::get(&platformList);
		int deviceNum = 1;
		cl_context_properties cprops[3] = { CL_CONTEXT_PLATFORM,
			(cl_context_properties)(platformList[deviceNum])(),
			0 };
		cl::Context context(CL_DEVICE_TYPE_GPU, cprops);

		vector< cl::Device > devices;
		devices = context.getInfo<CL_CONTEXT_DEVICES>();
		cl::Device default_device = devices[0];

		//--------Compile kernel extraction program from opencl---------//
		cl::Program::Sources ExtractSource(1, std::make_pair(Extract1DProg.c_str(), Extract1DProg.length() + 1));
		cl::Program ExtractProgram(context, ExtractSource);
		try {
			const char options[] = "-cl-fast-relaxed-math";
			ExtractProgram.build(devices, options);
		}
		catch (cl::Error err)
		{
			string buildlog = ExtractProgram.getBuildInfo<CL_PROGRAM_BUILD_LOG>(default_device);
			errorString.append(buildlog);
			throw err;
		}

		cl::Kernel ExtractKernel(ExtractProgram, "extract_1D");


		//--------Compile summing program from opencl---------//
		cl::Program::Sources SumSource(1, std::make_pair(Sum1DProg.c_str(), Sum1DProg.length() + 1));
		cl::Program SumProgram(context, SumSource);
		try {
			const char options[] = "-cl-fast-relaxed-math";
			SumProgram.build(devices, options);
		}
		catch (cl::Error err)
		{
			string buildlog = SumProgram.getBuildInfo<CL_PROGRAM_BUILD_LOG>(default_device);
			errorString.append(buildlog);
			throw err;
		}

		cl::Kernel SumKernel(SumProgram, "sum_1D");


		//--------Enqueue work to be done---------//
		//Note: out of order execution not currently supported.
		vector<cl::CommandQueue> queues;
		for (int i = 0; i < numQueues; i++)
			queues.emplace_back(context, devices[0]);

		for (int i = 0; i < respArrays.size(); i++) {

			const int timepointsCalcedPerKernel = 2000;
			//First kernel is responsible for calculating timepointsCalcedPerKernel + maxTau
			//so subtract maxTau from respLength when calculating kernelsPerResp
			const int kernelsPerResp = ceil(float(respLengths[i]-(maxTau-1)) / float(timepointsCalcedPerKernel));
		
			int q = i % numQueues;
			size_t inputBufferSize = respLengths[i] * numROIs[i];
			
			//Declare Buffers and write to them
			cl::Buffer respBuf(context,
				CL_MEM_READ_ONLY,
				sizeof(float)*inputBufferSize);

			cl::Buffer stimBuf(context,
				CL_MEM_READ_ONLY,
				sizeof(float)*inputBufferSize);

			cl::Buffer smallKernelBuf(context,
				CL_MEM_READ_WRITE,
				sizeof(float) * maxTau * kernelsPerResp*numROIs[i]);

			cl::Buffer outputKernelBuf(context,
				CL_MEM_WRITE_ONLY,
				sizeof(float) * maxTau * numROIs[i]);

			queues[q].enqueueWriteBuffer(respBuf, CL_FALSE, 0, sizeof(float)*inputBufferSize, respArrays[i]);
			queues[q].enqueueWriteBuffer(stimBuf, CL_FALSE, 0, sizeof(float)*inputBufferSize, stimulusArrays[i]);

			//Enqueue extraction on subsets of a response
			ExtractKernel.setArg(0, respBuf);
			ExtractKernel.setArg(1, stimBuf);
			ExtractKernel.setArg(2, UINT64(respLengths[i]));
			ExtractKernel.setArg(3, UINT64(timepointsCalcedPerKernel+maxTau-1));
			ExtractKernel.setArg(4, UINT64(maxTau));
			ExtractKernel.setArg(5, smallKernelBuf);

			cl::NDRange  extractLocal(maxTau, 1, 1);
			cl::NDRange extractGlobal(maxTau, kernelsPerResp, numROIs[i]);

			queues[q].enqueueNDRangeKernel(ExtractKernel,
				cl::NullRange,
				extractGlobal,
				extractLocal);

			//Enqueue summing of response subsets
			SumKernel.setArg(0, smallKernelBuf);
			SumKernel.setArg(1, UINT64(kernelsPerResp));
			SumKernel.setArg(2, outputKernelBuf);
			cl::NDRange  sumLocal(maxTau, 1);
			cl::NDRange sumGlobal(maxTau, numROIs[i]);

			queues[q].enqueueNDRangeKernel(SumKernel,
				cl::NullRange,
				sumGlobal,
				sumLocal);

			//Read the output back
			queues[q].enqueueReadBuffer(outputKernelBuf,
				CL_TRUE,
				0,
				sizeof(float)*maxTau*numROIs[i],
				outputKernels[i]);
		}//End for loop

		for (int i = 0; i < numQueues; i++)
			queues[i].finish();
		
		return EXIT_SUCCESS;
	}
	catch (cl::Error err) {
		errorString.append("Error In: ");
		errorString.append(err.what());
		errorString.append(": ");
		errorString.append(getErrorString(err.err()));
		return EXIT_FAILURE;
	}
}

