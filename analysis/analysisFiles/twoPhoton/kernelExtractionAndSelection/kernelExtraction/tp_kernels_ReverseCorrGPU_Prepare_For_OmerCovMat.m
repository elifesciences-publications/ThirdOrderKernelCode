function  [response, stimulus] = tp_kernels_ReverseCorrGPU_Prepare_For_OmerCovMat(respDataGPU, stimDataGPU1)
nMultiBars = length(stimDataGPU1);
[T,nRoi] = size(stimDataGPU1{1});
stimulus = single(zeros(T,nMultiBars,nRoi));
for qq = 1:1:nMultiBars
    stimulus(:,qq,:) = stimDataGPU1{qq};
end
response = single(zeros(T,1,nRoi)); response(:,1,:) = respDataGPU{1};

end