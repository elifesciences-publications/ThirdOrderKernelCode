R"+++++++(#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable

__kernel void sum_1D(__global float* smallKernels,
                     unsigned long numKernelsPerResp,
                     __global float* output) {
  size_t tau1 = get_global_id(0);
  size_t ROI  = get_global_id(1);
  size_t maxTau = get_global_size(0);
  float sum = 0;
	
#pragma unroll 64
  for (size_t i = 0; i < numKernelsPerResp; i++)
    sum += smallKernels[tau1 + maxTau*i + maxTau*numKernelsPerResp*ROI];

  output[tau1 + maxTau*ROI] = sum;
})+++++++"
