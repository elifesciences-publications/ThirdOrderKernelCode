function [kernel] = tp_kernels_OLS(respMatrix,stimMatrix)
    % first, compute tau, nRoi,nMultiBars;
    nRoi = length(respMatrix);
    nMultiBars = size(stimMatrix,1); % 20 
    maxTau = size(stimMatrix{1,1},2);
    
    kernel = zeros(maxTau,nMultiBars,nRoi);
    for rr = 1:1:nRoi
        for qq = 1:1:nMultiBars
%             % which computer is usable??
%             stimMat = gpuArray(stimMatrix{qq,rr});
%             respMat = gpuArrary(respMatrix{rr});
            kernel(:,qq,rr) = stimMatrix{qq,rr}\respMatrix{rr};
        end
    end
    
end