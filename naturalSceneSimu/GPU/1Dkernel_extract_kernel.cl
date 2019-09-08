R"+++++++(#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable

__kernel void extract_1D(__global float* resp_g,
						 __global float* stim_g,
					     unsigned long respLength,
						 unsigned long numTimepoints,
						 unsigned long maxTau,
                         __global float* output) {
  size_t tau1 = get_global_id(0);
  size_t ROI = get_global_id(2);
  size_t startTime = get_global_id(1)*(numTimepoints - maxTau+1);
  size_t endTime = min(respLength,startTime+numTimepoints);

  float sum = 0;
												
#pragma unroll 32											
  for (size_t t = startTime+maxTau-1; t < endTime; t = t+1) {
    sum += resp_g[t+respLength*ROI] * stim_g[t - tau1 + respLength*ROI];
  }
	
  size_t outputIndex = tau1 + maxTau*get_global_id(1) + maxTau*get_global_size(1)*ROI;
  output[outputIndex] = sum;
})+++++++"
