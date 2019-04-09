function tp_kernels_ReverseCorrGPU_LongerSecondOrderKernel(respData,stimIndexes,stimData,maxTauNum,maxTauUnit)
maxTauNum = 3; % 3 * 64 ~ 1 second.
maxTauUnit = 64;
% rearrange respData, stimIndexes and stimData...

% respData and sitmIndexes do not have to change.
% not very hard, give it a try...

secondKernel =  cell(maxTauNum,maxTauNum);
tic
for jj = 1:1:maxTauNum
    %% jj is the left bar should be shifted by (jj - 1) * 64;
    stimL = stimData(:,1); % get the left.
    shift = (jj - 1) * maxTauUnit;
    stimL = [zeros(shift ,1);stimL(1:end - shift)];
    for ii = 1:1:maxTauNum
        stimR = stimData(:,2);
        shift = (ii - 1) * maxTauUnit;
        stimR = [zeros(shift ,1);stimR(1:end - shift)];
        % ii is the right bar should be shifted by (ii - 1) * 64;
        stimDataNew = [stimL,stimR];
        secondKernel{ii,jj} = tp_kernels_ReverseCorrGPU(respData,stimIndexes,stimDataNew,'order',2,'maxTau',64,'dx',1,'order',2);
    end
end
toc
MakeFigure;
count = 1;

for ii = 1:1:3
    for jj = 1:1:3
        subplot(3,3,count)
        quickViewOneKernel(secondKernel{ii,jj}(:,1),2);
        count = count + 1;
    end
end
% catenate all the kernels together.

nfly = length(respData);
nMultiBars = size(stimData,2);
maxTau = maxTauNum * maxTauUnit;
kernels = zeros(maxTau * maxTau ,nMultiBars,nfly);
count = 1;
for jj = 1:1:maxTauNum
    for ii = 1:1:maxTauNum
        ind = (count - 1) * maxTauUnit^2 + 1: count * maxTauUnit^2;
        kernels(ind,:,:) = secondKernel{ii,jj};
        count = count + 1;
    end
end

MakeFigure;
quickViewKernels(kernels(:,1),2);
end