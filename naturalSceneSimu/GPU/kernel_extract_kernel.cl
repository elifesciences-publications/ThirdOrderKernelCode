R"+++++++(#pragma OPENCL EXTENSION cl_khr_byte_addressable_store : enable
#define NUM_TIMEPOINTS 2728
#define NUM_SUMS 16
		//MUST EQUAL 64/tau2StepSize

__kernel void extract(__global float* resp_g,
                      __global float* stim1_g,
                      __global float* stim2_g,
					           int respLength,
                      __global float* output) {
  size_t tau1 = get_global_id(0) %  64;
  size_t tau2StepSize = get_global_size(0) / 64;
  size_t tau2Offset = get_global_id(0) / 64;
  size_t maxTau = 64;
  size_t ROI = get_global_id(2);
  int startTime = get_global_id(1)*(NUM_TIMEPOINTS - maxTau+1);
  //int endTime = 680, 680+616, 680+616+616...
  size_t timepointsStored = min(respLength - startTime, NUM_TIMEPOINTS);
  

  float sum[NUM_SUMS];//MUST EQUAL 64/tau2StepSize
  __local float  resp[NUM_TIMEPOINTS];
  __local float stim1[NUM_TIMEPOINTS];
  __local float stim2[NUM_TIMEPOINTS];

  for (int i = get_local_id(0); i < timepointsStored; i += get_local_size(0))
	  resp[i] = resp_g[i + startTime + ROI*respLength];
  for (int i = get_local_id(0); i < timepointsStored; i += get_local_size(0))
    stim1[i] = stim1_g[i + startTime + ROI*respLength];
  for (int i = get_local_id(0); i < timepointsStored; i += get_local_size(0))
    stim2[i] = stim2_g[i + startTime + ROI*respLength];
  barrier(CLK_LOCAL_MEM_FENCE);

#pragma unroll									
  for (int i = 0; i < 16; i++)
    sum[i] = 0;
												
#pragma unroll 4											
  for (int t = maxTau-1; t < timepointsStored; t = t+1) {
    float respStim1 = resp[t] * stim1[t - tau1];
#pragma unroll
	for (int i = 0; i < NUM_SUMS; i++) {
		size_t tau2 = tau2Offset + i*tau2StepSize;
		sum[i] += respStim1*stim2[t - tau2];
	}
  }
	
  for (int i = 0; i < NUM_SUMS; i++) {
    size_t tau2 = tau2Offset + i*tau2StepSize;
    size_t outputIndex = tau1 + 64*tau2 + 64*64*get_global_id(1) + 64*64*get_global_size(1)*ROI;
	output[outputIndex] = sum[i];
  }
})+++++++"
