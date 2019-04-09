function kernels = Main_KernelExtraction_ReverseCorr(respData, stimData, stimIndexes, varargin)
order = 1;
maxTau = 64;
dx =[0,0];
arma_flag = false;
kr = [];
donoise = false;
maxTau_r = 1;
cross_validation_flag = false;
repStimIndInFrame = [];
maxTauSmall = 64; % Used by third order kernel.
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
    if maxTau_r == 1
        respData_use = cell(nRoi,1);
        for rr = 1:1:nRoi
            respData_use{rr} = respData{rr} - kr{rr} * [0;respData{rr}(1:end - 1)];
        end
    else
        respData_use = cell(nRoi,1);
        for rr = 1:1:nRoi
            temp_vec = [respData{rr}; zeros(maxTau_r, 1)];
            temp_mat = toeplitz( respData{rr}, [respData{rr}(1), zeros(1, maxTau_r)]); temp_mat = temp_mat(1:length(respData{rr}), 2:end);
            respData_use{rr} = respData{rr} -  temp_mat * kr{rr};
        end
        
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
            sumGPU = oned_cpu_gpu_format(maxTau,stimDataGPU1,respDataGPU);
            
            %             sumGPU = oned_gpu(maxTau,stimDataGPU1,respDataGPU);
            kernelsRaw = zeros(maxTau,nMultiBars,nRoi);
            for qq = 1:1:nMultiBars
                kernelsRaw(:,qq,:) = permute(sumGPU{qq},[1,3,2]);
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
            
            
            %% si
            stimDataGPU1 = cellfun(@(x) x(:,1), stimDataGPU1, 'UniformOutput', false);
            %% si
            stimData2 = circshift(stimDataGPU1,[1,-dx(1)]); % This might be wrong?!!! 
            %% si+1 when dx = 1, si-1 then dx = -1
            stimData3 = circshift(stimDataGPU1,[1,-dx(2)]);
            
            OffsetBank = [-(maxTau - 1):1: maxTau - 1];
            numOffset = length(OffsetBank);
            kernelsLong = zeros(maxTau, maxTau, numOffset, nMultiBars, nRoi);
            
            
            % do it by small batches.
            nBatch = ceil(numOffset/nOffsetPerBatch);
            %                 timePerBatch = zeros(nBatch,1);
            for jj = 1:1:nBatch
                % offsetInd
                %                     tStart = tic;
                offsetInd = (jj - 1) * nOffsetPerBatch + 1: min([jj * nOffsetPerBatch,numOffset]);
                OffsetBankThisBatch = OffsetBank(offsetInd);
                numOffsetThisBatch = length(OffsetBankThisBatch);
                
                % si
                stimDataGPU1Long = repmat(stimDataGPU1, [numOffsetThisBatch, 1]);
                % si(t) * si+1(t-delta tt). delta tt = OffsetBankThisBatch(ii)
                stimDataGPU2Long = cell(size(stimDataGPU1Long));
                for ii = 1:1:numOffsetThisBatch
                    tt = OffsetBankThisBatch(ii);
                    ttCell = num2cell(tt * ones(1,nMultiBars));
                    if tt < 0
                        % shift up and pad zeros in the end/. padding
                        stimData3Shift = cellfun(@(stimThisBar,tt) [stimThisBar(abs(tt) + 1:end,:);zeros(abs(tt),1)],stimData3, ttCell ,'UniformOutput', false); % shift it
                    elseif tt == 0
                        stimData3Shift = stimData3;
                    else
                        % shift down and pad zeros in the begining.
                        stimData3Shift = cellfun(@(stimThisBar,tt) [zeros(abs(tt),1);stimThisBar(1 :end - abs(tt),:)],stimData3, ttCell ,'UniformOutput', false); % shift it
                    end
                    stimDataGPU2 = cellfun(@(x,y) x.* y,stimData3Shift, stimData2,'UniformOutput',false);
                    stimDataGPU2Long(ii,:) = stimDataGPU2;
                end
                
                % kernel(a, b, c, d, e) = k(tau1, tau2, tau2 - delta tt,
                % bar, roi), delta tt is offsetInd.
                kernelsLong(:,:, offsetInd, :, :) = compute_3o_kernel_use_OmerCov(respDataGPU, stimDataGPU1Long, stimDataGPU2Long, maxTau);
            end
            %                     timePerBatch(jj) = toc(tStart);
            %                 fprintf('There are %d batches gpu computing, each batch contains %d offset, %d rois, %d 2o kernel compuation \nOn average, each batch uses %f seconds ,  each kernel uses %f seconds.\n%f seconds in total\n',...
            %                     nBatch,nOffsetPerBatch,nRoi,nOffsetPerBatch * nRoi,mean(timePerBatch),sum(timePerBatch)/(nOffsetPerBatch * nRoi),sum(timePerBatch));
            %
            %                 tStart = tic;
            clear stimDataGPU2Long stimDataGPU1Long
            % kernelCubed = k(i, i, i+1(-1), tau1, tau2, tau3)
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
if order == 1
    kernels = squeeze(permute(cat(4, kernels_cell{:}),[1,4,2,3]));
else
    kernels = kernels_cell;
end
end

function kernel_output =  compute_3o_kernel_use_OmerCov(respDataGPU, stimDataGPU1Long, stimDataGPU2Long, maxTau)
% input.
% stimDataGPU1Long = cell(numOffSet, nMultiBars) = [1,2,3;1,2,3;1,2,3;....]
% stimDataGPU2Long = cell(numOffSet, nMultiBars) = [1,2,3;1,2,3;1,2,3;....]
% respData = cell(1,nRoi)

% output
% respData = zeros(T, 1, nMultiBars * numOffSet * nRoi)  = zeros(T, 1111111111111111111111111,222222222222222222222222);
% stim = zeros(T,2, nMultiBars * numOffSet * nRoi); = zeros(T, [stim1,
% stim2], nMultiBars * numOffSet * nRoi);
% covmat. only get the upper tri.

% do the transition.


[ numOffsetThisBatch, nMultiBars] = size(stimDataGPU1Long);
nRoi = size(respDataGPU{1}, 2);
T = length(respDataGPU{1});
response = single(zeros(T,1,numOffsetThisBatch * nMultiBars * nRoi));
% stimulus = zeros(T, 2, numOffsetThisBatch * nMultiBars * nRoi);

% organize response
respDataGPU = mat2cell(respDataGPU{1},T,ones(1,nRoi));
respDataGPU = repmat(respDataGPU, [numOffsetThisBatch * nMultiBars, 1]); respDataGPU = respDataGPU(:);
response(:, 1, :) = cat(2, respDataGPU{:});

% organize stimulus
stim1 = stimDataGPU1Long(:); stim1 = cat(3, stim1{:});
stim2 = stimDataGPU2Long(:); stim2 = cat(3, stim2{:});
stim = cat(2, stim1, stim2);
stimulus = repmat(stim, [1,1, nRoi]);

% covmat
covmat = extract2ndOrderKernelGPU(maxTau,stimulus,response);
third_kernel = covmat(1:maxTau, maxTau + 1: 2 * maxTau, :);
third_kernel = third_kernel * T;
kernel_output = reshape(third_kernel, [maxTau, maxTau, numOffsetThisBatch, nMultiBars, nRoi]);

end