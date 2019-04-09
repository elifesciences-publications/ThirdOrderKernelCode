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

const int maxTau = 64;
const int timepointsStoredPerKernel = 2728;// 680;
const int numQueues = 1;


bool extract_multiple_kernels(const vector<float*> respArrays, const vector<float*> stimulus1Arrays,
							  const vector<float*> stimulus2Arrays, const vector<int> respLengths,
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

		//--------Compile kernel extraction program from opencl---------//
		cl::Program::Sources ExtractSource(1, std::make_pair(ExtractProg.c_str(), ExtractProg.length() + 1));
		cl::Program ExtractProgram(context, ExtractSource);
		try {
			const char options[] = "-cl-fast-relaxed-math";
			ExtractProgram.build(devices, options);
		}
		catch (cl::Error err)
		{
			char buildlog[1000];
			ExtractProgram.getBuildInfo(devices[0], CL_PROGRAM_BUILD_LOG, &buildlog);
			cerr << buildlog << endl;
			errorString.append(buildlog);
			throw err;
		}

		cl::Kernel ExtractKernel(ExtractProgram, "extract");


		//--------Compile summing program from opencl---------//
		cl::Program::Sources SumSource(1, std::make_pair(SumProg.c_str(), SumProg.length() + 1));
		cl::Program SumProgram(context, SumSource);
		try {
			const char options[] = "-cl-fast-relaxed-math";
			SumProgram.build(devices, options);
		}
		catch (cl::Error err)
		{
			char buildlog[1000];
			SumProgram.getBuildInfo(devices[0], CL_PROGRAM_BUILD_LOG, &buildlog);
			cerr << buildlog << endl;
			throw err;
		}

		cl::Kernel SumKernel(SumProgram, "sum");


		//--------Enqueue work to be done---------//
		//Note: out of order execution not currently supported.
		vector<cl::CommandQueue> queues;
		for (int i = 0; i < numQueues; i++)
			queues.emplace_back(context, devices[0]);

		for (int i = 0; i < respArrays.size(); i++) {

			int q = i % numQueues;
			size_t inputBufferSize = respLengths[i] * numROIs[i];
			const int timepointsCalcedPerKernel = timepointsStoredPerKernel - (maxTau-1);
			//First kernel is responsible for calculating timepointsCalcedPerKernel + maxTau
			//so subtract maxTau from respLength when calculating kernelsPerResp
			const int kernelsPerResp = ceil(float(respLengths[i]-(maxTau-1)) / float(timepointsCalcedPerKernel));
			//Declare Buffers and write to them
			cl::Buffer respBuf(context,
				CL_MEM_READ_ONLY,
				sizeof(float)*inputBufferSize);

			cl::Buffer stim1Buf(context,
				CL_MEM_READ_ONLY,
				sizeof(float)*inputBufferSize);

			cl::Buffer stim2Buf(context,
				CL_MEM_READ_ONLY,
				sizeof(float)*inputBufferSize);

			cl::Buffer smallKernelBuf(context,
				CL_MEM_READ_WRITE,
				sizeof(float) * 64 * 64 * kernelsPerResp*numROIs[i]);

			cl::Buffer outputKernelBuf(context,
				CL_MEM_WRITE_ONLY,
				sizeof(float) * 64 * 64 * numROIs[i]);

			queues[q].enqueueWriteBuffer(respBuf , CL_FALSE, 0, sizeof(float)*inputBufferSize, respArrays[i]);
			queues[q].enqueueWriteBuffer(stim1Buf, CL_FALSE, 0, sizeof(float)*inputBufferSize, stimulus1Arrays[i]);
			queues[q].enqueueWriteBuffer(stim2Buf, CL_FALSE, 0, sizeof(float)*inputBufferSize, stimulus2Arrays[i]);

			//Enqueue extraction on subsets of a response
			ExtractKernel.setArg(0, respBuf);
			ExtractKernel.setArg(1, stim1Buf);
			ExtractKernel.setArg(2, stim2Buf);
			ExtractKernel.setArg(3, int(respLengths[i]));
			ExtractKernel.setArg(4, smallKernelBuf);

			cl::NDRange  extractLocal(256, 1, 1);
			cl::NDRange extractGlobal(256, kernelsPerResp, numROIs[i]);

			queues[q].enqueueNDRangeKernel(ExtractKernel,
				cl::NullRange,
				extractGlobal,
				extractLocal);

			//Enqueue summing of response subsets
			SumKernel.setArg(0, smallKernelBuf);
			SumKernel.setArg(1, kernelsPerResp);
			SumKernel.setArg(2, outputKernelBuf);
			cl::NDRange  sumLocal(64, 1, 1);
			cl::NDRange sumGlobal(64, 64, numROIs[i]);

			queues[q].enqueueNDRangeKernel(SumKernel,
				cl::NullRange,
				sumGlobal,
				sumLocal);

			//Read the output back
			queues[q].enqueueReadBuffer(outputKernelBuf,
				CL_TRUE,
				0,
				sizeof(float)*64*64*numROIs[i],
				outputKernels[i]);
		}//End for loop

		for (int i = 0; i < numQueues; i++)
			queues[i].finish();

		return EXIT_SUCCESS;
	}
	catch (cl::Error err) {
		cerr << "ERROR IN: " << err.what()
			<< ": " << getErrorString(err.err()) << endl;
		errorString.append("Error IN: ");
		errorString.append(err.what());
		errorString.append(":");
		errorString.append(getErrorString(err.err()));
		return EXIT_FAILURE;
	}
}

