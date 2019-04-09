function sumCPU = twod_cpu_gpu_format(maxTau,stimDataGPU1,stimDataGPU2,respDataGPU);

resp = zeros(size(respDataGPU{1}));
resp(maxTau:end,:) = respDataGPU{1}(maxTau:end, :);
clear respDataGPU;
[T,nRoi] = size(resp);
nMultiBars = length(stimDataGPU1);
% prepare for second order kernel.
sumCPU = cell(20,1); % one by one...
% inputExpanded  = zeros(T, nMultiBars * maxTau); % all rois will share same stimulus.
for qq = 1:1:nMultiBars
    inputExpanded1 = toeplitz(stimDataGPU1{qq}(:,1),[stimDataGPU1{qq}(1,1) zeros(1, maxTau -1)]) ;
    inputExpanded2 = toeplitz(stimDataGPU2{qq}(:,1),[stimDataGPU2{qq}(1,1) zeros(1, maxTau -1)]) ;
    sumCPU{qq} = zeros(maxTau, maxTau, nRoi);
    for rr = 1:1:nRoi
        response_this_roi = repmat(resp(:,rr),[1 maxTau]);
        sumCPU{qq}(:,:,rr) = inputExpanded1' * (inputExpanded2 .* response_this_roi);
    end
    
end


%% could you change this? should be...
