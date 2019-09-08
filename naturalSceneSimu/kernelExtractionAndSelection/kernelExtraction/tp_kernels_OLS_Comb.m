function [kernel] = tp_kernels_OLS_Comb(respMatrix,stimMatrix)
% first, compute tau, nRoi,nMultiBars;
nRoi = length(respMatrix);
nMultiBars = size(stimMatrix,1); % 20
maxTau = size(stimMatrix{1,1},2);

kernel = zeros(maxTau,nMultiBars,nRoi);
for rr = 1:1:nRoi
    stimMatrixComb = [];
    for qq = 1:1:nMultiBars
        %             % which computer is usable??
        %             stimMat = gpuArray(stimMatrix{qq,rr});
        %             respMat = gpuArrary(respMatrix{rr});
        stimMatrixComb = [stimMatrixComb stimMatrix{qq,rr};];

    end
    tic
    kernelComb= stimMatrixComb\respMatrix{rr};
    toc
    kernel(:,:,rr) = reshape(kernelComb,[maxTau,nMultiBars]);
end

end