function kernels = Main_KernelExtraction_ReverseCorr(respData, stimData, stimIndexes, varargin)
order = 1;
maxTau = 64;
dx =[0,0];
arma_flag = false;
kr = [];
donoise = false;

cross_validation_flag = false;
repStimIndInFrame = [];
maxTauSmall = 32; % Used by third order kernel.
nOffsetPerBatch = 16; % 16 seems to be a good number, storage might take more time though. decreases the. you will use this for third order kernel.
noiseKernelReps = 100;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% you have not implemented this situations yet.
if cross_validation_flag && donoise
    warning('for the cross-validation mode, do noise kernel has not been implemented');
    keyboard;
end


maxTau = single(maxTau);
nMultiBars = size(stimData,2);
nRoi = length(respData);

%% change the response to response minus the previous one...

if arma_flag
    respData_use = cell(nRoi,1);
    for rr = 1:1:nRoi
        respData_use{rr} = respData{rr} - kr{rr} * [0;respData{rr}(1:end - 1)];
    end
else
    respData_use = respData;
end


% cross_validation_flag = true, only use part of the stimulus and response.
if cross_validation_flag
    [respDataGPU,stimDataGPU1,numElementsSummed,stimDataVar] = tp_kernels_ReverseCorrGPU_Prepare_Rep(respData_use,stimIndexes,stimData,maxTau,repStimIndInFrame);
else
    [respDataGPU,stimDataGPU1,numElementsSummed,stimDataVar] = tp_kernels_ReverseCorrGPU_Prepare(respData_use,stimIndexes,stimData,maxTau);
end
% you should shift respData outside of this... do you?
nT = size(respDataGPU{1},1);
if donoise
    rng(0); % makesure that rand generate same thing everytime.
    rotBy = maxTau * 2 + floor(rand(noiseKernelReps, 1)*(nT - maxTau * 3));
else
    noiseKernelReps  = 1;
    rotBy = [];
end


% every noise will be put into a cell array. This is more intuitive.
kernels_cell = cell(noiseKernelReps,1);
for nn = 1:1:noiseKernelReps
    
    % prepare the response data, stimulus is constant everytime.
    % rotBy(n) = floor(rand*nT);%maxTau+floor(rand*(nT-128));
    if donoise
        firstBunch = 1:rotBy(nn);
        secondBunch = rotBy(nn)+1:nT;
        kernelIndsUse = [secondBunch firstBunch];% shuffle(kernelInds)
        respDataGPU{1} = single(respDataGPU{1}(kernelIndsUse,:));
    end
    switch order
        case 1
            % type transformation before gpu.
            % GPU here does not work anymore. use
            sumCPU = oned_cpu_gpu_format(maxTau,stimDataGPU1,respDataGPU);
            kernelsRaw = zeros(maxTau,nMultiBars,nRoi);
            for qq = 1:1:nMultiBars
                kernelsRaw(:,qq,:) = permute(sumCPU{qq},[1,3,2]);
            end
            kernels_this_rep = zeros(maxTau,nMultiBars,nRoi);
            for qq = 1:1:nMultiBars
                for rr = 1:1:nRoi
                    kernels_this_rep(:,qq,rr) = kernelsRaw(:,qq,rr)/(numElementsSummed(rr) * stimDataVar(qq));
                end
            end
            
        case 2
            % change your data structure... get cov_mat directly from
            [response, stimulus] = tp_kernels_ReverseCorrGPU_Prepare_For_OmerCovMat(respDataGPU, stimDataGPU1);
            output = extract2ndOrderKernelGPU(maxTau,stimulus,response);
            % compare this with second order cpu.
            %% first, renormalize.
            kernel_raw = output * nT;
            numElementsSummed_ = zeros(1,1,nRoi); numElementsSummed_(1,1,:) = numElementsSummed; numElementsSummed_ = repmat(numElementsSummed_, [maxTau * nMultiBars,maxTau * nMultiBars,1]);
            stimDataVar_ = repmat(stimDataVar,[maxTau,1]); stimDataVar_ = stimDataVar_(:); stimDataVar_mat = repmat(stimDataVar_ * stimDataVar_',[1,1,nRoi]);
            kernels_this_rep = kernel_raw./(stimDataVar_mat .* numElementsSummed_);
            
        case 3
            % actually,  you will loop through dxBank here...
            maxTau = single(64); % use omer new gpu code? omer's gpu code isnot very suitable here. you have to break 20 bars apart.
            stimData2 = circshift(stimDataGPU1,[1,-dx(1)]);
            stimData3 = circshift(stimDataGPU1,[1,-dx(2)]);
            
            OffsetBank = [-(maxTau - 1):1: maxTau - 1];
            
            numOffset = length(OffsetBank);
            sumGPULong = cell(nMultiBars,numOffset);
            
            % do it by small batches.
            nBatch = ceil(numOffset/nOffsetPerBatch);
            %                 timePerBatch = zeros(nBatch,1);
            for jj = 1:1:nBatch
                % offsetInd
                %                     tStart = tic;
                offsetInd = (jj - 1) * nOffsetPerBatch + 1: min([jj * nOffsetPerBatch,numOffset]);
                OffsetBankThisBatch = OffsetBank(offsetInd);
                numOffsetThisBatch = length(OffsetBankThisBatch);
                
                stimDataGPU1Long = repmat(stimDataGPU1,[1,numOffsetThisBatch]);
                stimDataGPU2Long = cell(length(stimDataGPU1Long),1);
                for ii = 1:1:numOffsetThisBatch
                    tt = OffsetBankThisBatch(ii);
                    ttCell = num2cell(tt * ones(1,nMultiBars));
                    if tt < 0
                        % shift up and pad zeros in the end/. padding
                        stimData3Shift = cellfun(@(stimThisBar,tt) [stimThisBar(abs(tt) + 1:end,:);zeros(abs(tt),nRoi)],stimData3, ttCell ,'UniformOutput', false); % shift it
                    elseif tt == 0
                        stimData3Shift = stimData3;
                    else
                        % shift down and pad zeros in the begining.
                        stimData3Shift = cellfun(@(stimThisBar,tt) [zeros(abs(tt),nRoi);stimThisBar(1 :end - abs(tt),:)],stimData3, ttCell ,'UniformOutput', false); % shift it
                    end
                    stimDataGPU2 = cellfun(@(x,y) x.* y,stimData3Shift, stimData2,'UniformOutput',false);
                    stimDataGPU2Long((ii - 1)* nMultiBars + 1 : ii * nMultiBars) = stimDataGPU2;
                end
                sumGPULong(:,offsetInd)= reshape(twod_gpu(maxTau,stimDataGPU1Long,stimDataGPU2Long,respDataGPU),nMultiBars,[]);
                %                     timePerBatch(jj) = toc(tStart);
            end
            %                 fprintf('There are %d batches gpu computing, each batch contains %d offset, %d rois, %d 2o kernel compuation \nOn average, each batch uses %f seconds ,  each kernel uses %f seconds.\n%f seconds in total\n',...
            %                     nBatch,nOffsetPerBatch,nRoi,nOffsetPerBatch * nRoi,mean(timePerBatch),sum(timePerBatch)/(nOffsetPerBatch * nRoi),sum(timePerBatch));
            %
            %                 tStart = tic;
            clear stimDataGPU2Long stimDataGPU1Long
            sumGPULongMat = reshape(cell2mat(sumGPULong),[maxTau,nMultiBars,maxTau,numOffset,nRoi]);
            clear sumGPULong
            kernelsLong = permute(sumGPULongMat,[1,3,4,2,5]);
            %         kernelLongSmall = kernelsLong(1:maxTauSmall,1:maxTauSmall,:,:,:);
            kernelCubed = tp_kernels_ReverseCorrGPU_Utils_3o_LongKernelToCubicKernel(kernelsLong,OffsetBank);
            kernelCubed = kernelCubed (1:maxTauSmall,1:maxTauSmall,1:maxTauSmall,:,:);
            %                 tOragnize = toc(tStart);
            %                 fprintf('It takes %f seconds to organize the kernel\n',tOragnize);
            % you really need a smaller kernels.
            kernels_this_rep_this_dx = reshape(kernelCubed,[maxTauSmall^3,nMultiBars,nRoi]);
            for qq = 1:1:nMultiBars
                for rr = 1:1:nRoi
                    kernels_this_rep_this_dx(:,qq,rr) =  kernels_this_rep_this_dx(:,qq,rr)/(numElementsSummed(rr) * stimDataVar(qq).^3);
                end
            end
            kernels_this_rep =  kernels_this_rep_this_dx;
    end
    kernels_cell{nn} = kernels_this_rep;
end
% first order kernel
% first order kernel.
% kernels = [maxTau, nNoise, nMultibars, nRoi];
% second order kernel. {noise}(maxTau * nMultiBars, maxTau * nMultiBars,
% nRoi);
% if order == 1
%     kernels = squeeze(permute(cat(4, kernels_cell{:}),[1,4,2,3])); % into cell array... not consistent with T4T5 branch.
% else
%     kernels = kernels_cell;
% end
kernels = kernels_cell; % ignore the wiered first order kernel.