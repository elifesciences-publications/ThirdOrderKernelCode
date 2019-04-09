function sumCPU = oned_cpu_gpu_format(maxTau,stimDataGPU,respDataGPU)
% this code is used for computer which does not have a gpu.

% resp = zeros(size(respDataGPU{1}));
% resp(maxTau:end,:) = respDataGPU{1}(maxTau:end, :);
% clear respDataGPU;
% [T,nRoi] = size(resp);
% nMultiBars = length(stimDataGPU);
% 
% kernel = zeros(maxTau, nMultiBars, nRoi);
% inputExpanded  = zeros(T, nMultiBars * maxTau); % all rois will share same stimulus.
% for qq = 1:1:nMultiBars
%     inputExpanded(:, (qq - 1) * maxTau + 1 :  qq * maxTau) = toeplitz(stimDataGPU{qq}(:,1),[stimDataGPU{qq}(1,1) zeros(1, maxTau -1)]) ;
% end
% 
% for rr = 1:1:nRoi
%     response_this_roi = repmat(resp(:,rr),[1 maxTau * nMultiBars]);
%     kernel(:,:,rr) = reshape(dot(inputExpanded, response_this_roi), [maxTau, nMultiBars]);
% end
% 
% sumKernels = cell(nMultiBars, 1);
% for qq = 1:1:nMultiBars
%     sumKernels{qq} = single(kernel(:,qq,:));
% end
% you have to put this sumKerne into cell... it is a waste of computing
% time, but make sure that the code is consistent with the GPU version.


resp = zeros(size(respDataGPU{1}));
resp(maxTau:end,:) = respDataGPU{1}(maxTau:end, :);
clear respDataGPU;
nRoi = size(resp,2);
nMultiBars = length(stimDataGPU);
% prepare for second order kernel.
sumCPU = cell(nMultiBars,1); % one by one...
for qq = 1:1:nMultiBars
    inputExpanded = toeplitz(stimDataGPU{qq}(:,1),[stimDataGPU{qq}(1,1) zeros(1, maxTau - 1)]) ;
    sumCPU{qq} = single(zeros(maxTau, nRoi));
    for rr = 1:1:nRoi
        response_this_roi = repmat(resp(:,rr),[1 maxTau]);
        sumCPU{qq}(:,rr) = single( dot(inputExpanded, response_this_roi));
    end
    
end


end

% after this. you should check on what do you have for group meeting...
