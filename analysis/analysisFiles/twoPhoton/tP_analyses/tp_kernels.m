function Z = tp_kernels( Z )
% Extracts and saves kernels from the output of tp_flickerSelectAndAlign

%% Default params
N = 10;
dx = 1;
specialName = [];
combineNeighbors = 0;
shiftBy = 0;
saveKernels = 1;
loadFlexibleInputs(Z)

%% Load everything from Z.flick
flickNames = fieldnames(Z.flick);
for ii = 1:length(flickNames)
    eval([flickNames{ii} '= Z.flick.' flickNames{ii} ';']);
end
nRoi = length(ROIuse);
nMultiBars = size(alignedStimulusData,2);

%% Combine neighbors?
if combineNeighbors
    for q = 1:nMultiBars
        firstInd = q;
        secondInd = mod(q,nMultiBars) + 1;
        newAlignedStimulusData{firstInd} = (alignedStimulusData{firstInd} + alignedStimulusData{secondInd}) / 2;
    end
    alignedStimulusData = newAlignedStimulusData;
end

%% Mean subtract response data
responseData(kernelInds,:) = responseData(kernelInds,:) - ...
    repmat(mean(responseData(kernelInds,:),1),[length(kernelInds) 1]);

%% Extract kernels
% Set up input variables
for bar = 1:nMultiBars;
    % average across the bars...
    newAlignedStimulusData1{bar} = single(alignedStimulusData{bar}(kernelInds(shiftBy+1:end),:));
    variance{bar} = var(alignedStimulusData{bar}(kernelInds(shiftBy+1:end),:));
end
% %% test for background...
if exist('useBackGroundCheckAlignment','var') == 1 && useBackGroundCheckAlignment == 1;
    temp = zeros(size(newAlignedStimulusData1{bar}));
    for bar = 1:nMultiBars;
        % average across the bars...
        temp = temp + newAlignedStimulusData1{bar};
    end
    
    for bar = 1:nMultiBars;
        % average across the bars...
        newAlignedStimulusData1{bar} = temp;
        variance{bar} = var(alignedStimulusData{bar}(kernelInds(shiftBy+1:end),:));
    end
end
% % newAlignedStimulusData1{bar} %
% nT = size(newAlignedStimulusData1{bar},1);
% filterSimul = [2,2];
% % generate response using your own filterSimu....
% stimSimu = newAlignedStimulusData1{1}(:,1);
% respSimu = filter(filterSimul,1,stimSimu);
% responseDataCell{1} = single(respSimu);
responseDataCell{1} = single(responseData(kernelInds(1:end-shiftBy),:));
% MakeUp stimulus and filter your self, test the result using matToLN;
% after this point, there is no problem for time alignment between stimulus
% and response.
switch whichKernel
    case 'first'
        sumGPU = oned_gpu(maxTau,newAlignedStimulusData1,responseDataCell);
        kernels(maxTau,nMultiBars,nRoi) = 0;
        for bar = 1:nMultiBars
            % for the binary data, the variance would not change
            % much..
            varianceReshaped =  repmat(reshape(variance{bar},1,1,[]),maxTau,1);
            numElementsSummed = length(kernelInds)-shiftBy-maxTau+1;
            % because some frames was removed, and the response of
            % those frames are set to zero. thus the elements here
            % would be different.
            %             if isfield(Z.filtered,'removeOverMovedFrameFlag') && isfield(Z.filtered,'removeOverMovedFrames')
            %                 numOverMovedFrames = sum(Z.filtered.removeOverMovedFrames);
            %                 numElementsSummed =  numElementsSummed - numOverMovedFrames;
            %
            %             end
            kernels(:,bar,:) = permute(sumGPU{bar},[1 3 2])./(numElementsSummed*varianceReshaped);
        end
        
    case 'second'
        newAlignedStimulusData2 = newAlignedStimulusData1([(1+dx):end 1:dx]);
        
        sumGPU = twod_gpu(maxTau,newAlignedStimulusData1,...
            newAlignedStimulusData2,...
            responseDataCell);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% change the second order kernel into 30....change it in the
        %%%%% future.
        kernels(maxTau*maxTau,nMultiBars,nRoi) = 0;
        for bar = 1:nMultiBars
            varSquared = repmat(reshape(variance{bar}.^2,1,1,nRoi),maxTau,maxTau); %variance^2 gets reshaped to be maxTauxmaxTauxROI
            numElementsSummed = length(kernelInds)-shiftBy-maxTau+1;
            kernelsGPU = sumGPU{bar}./(numElementsSummed*varSquared);
            kernels(:,bar,:) = reshape(kernelsGPU,maxTau*maxTau,1,nRoi);
        end
end

%% Save the kernels AND any information you might want to save about
% extraction in the kernels structure. If you save the kernels, this is
% the structure that will be saved.
Z.kernels.kernels = kernels;
Z.kernels.ROIuse = ROIuse;
%     Z.kernels.kernel_ROIs = Z.ROI.roiMasks(:,:,ROIuse);
Z.kernels.whichKernel = whichKernel;
Z.kernels.maxTau = maxTau;

%% Save?
if dx > 0
    specialName = sprintf('dx_%i',dx);
end
if saveKernels
    Z.kernels.fullKernelPathName = tp_saveKernels(Z.params.name,kernels, Z.params.whichKernel,[]);
    %     Z.kernels.fullKernelPathName = tp_saveKernels(Z,specialName);
end

end

