R"+++++++(#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable

__kernel void sum(__global float* smallKernels,
                  int numKernelsPerResp,
                  __global float* output) {
  size_t tau1 = get_global_id(0);
  size_t tau2 = get_global_id(1);
  size_t ROI  = get_global_id(2);
  float sum = 0;
	
#pragma unroll 64
  for (int i = 0; i < numKernelsPerResp; i++)
    sum += smallKernels[tau1 + tau2*64 + i*64*64 + 64*64*numKernelsPerResp*ROI];

  output[tau1 + tau2*64 + 64*64*ROI] = sum;
})+++++++"
