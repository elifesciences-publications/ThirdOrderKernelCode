function Z = tp_noiseKernels( Z )
% Create and save noiseKernels that have the stimulus randomly permuted to
% estimate the noise magnitude of the system.

    tic
    %% Default params
    noiseKernelReps = 100;
    saveKernels = 1;
    dx = 1;
    loadFlexibleInputs(Z)
    
    %% Load everything from Z.flick    
    flickNames = fieldnames(Z.flick);
    for ii = 1:length(flickNames)
        eval([flickNames{ii} '= Z.flick.' flickNames{ii} ';']);
    end
    nMultiBars = size(alignedStimulusData,2);
    nRoi = size(responseData,2);

    %% Mean subtract response data
    responseData(kernelInds,:) = responseData(kernelInds,:) - ...
        repmat(mean(responseData(kernelInds,:),1),[length(kernelInds) 1]);
    
    %% Set up things which will be constant across noseKernelReps
    for bar = 1:nMultiBars;
        newAlignedStimulusData1{bar} = single(alignedStimulusData{bar}(kernelInds,:));
        
        variance = var(alignedStimulusData{bar}(kernelInds,:));
        varSquared = repmat(reshape(variance.^2,1,1,nRoi),maxTau,maxTau); %variance^2 gets reshaped to be maxTau x maxTau x ROI
        varReshaped1D = repmat(reshape(variance,1,1,1,nRoi),maxTau,1); %variance gets reshaped to be maxTau x ROI
        numElementsSummed2D = length(kernelInds)-maxTau+1;
        numElementsSummed1D = length(kernelInds)-maxTau+1;
        normDenom2D{bar} = numElementsSummed2D*varSquared;
        normDenom1D{bar} = numElementsSummed1D*varReshaped1D;
    end
    newAlignedStimulusData2 = newAlignedStimulusData1([(1+dx):end 1:dx]);


    %% Loop over N noise noiseKernels
    
    for n = 1:noiseKernelReps
        nT = length(kernelInds);
        % rotBy(n) = floor(rand*nT);%maxTau+floor(rand*(nT-128));
        % temporary, change the number to variable in the future;
        rotBy(n) = maxTau + floor(rand*(nT - maxTau * 2));
        firstBunch = kernelInds(1:rotBy(n));
        secondBunch = kernelInds(rotBy(n)+1:end);
        kernelIndsUse = [secondBunch firstBunch];% shuffle(kernelInds)
        
        responseDataCell{1} = single(responseData(kernelIndsUse,:));
        %% Extract noiseKernels    
        switch whichKernel
            case 'first'   
                sumGPU = oned_gpu(maxTau,newAlignedStimulusData1,responseDataCell);
                % initiaion is inside the
                % loop??????????????????????????????????????????why is
                % that??????
                noiseKernels(maxTau,noiseKernelReps,nMultiBars,nRoi) = 0;
                for bar = 1:nMultiBars
                    noiseKernels(:,n,bar,:) = permute(sumGPU{bar},[1 3 4 2])./normDenom1D{bar};
                end 
            case 'second'

                sumGPU = twod_gpu(maxTau,newAlignedStimulusData1,...
                                      newAlignedStimulusData2,...
                                      responseDataCell);

                noiseKernels(maxTau*maxTau,noiseKernelReps,nMultiBars,nRoi) = 0;
                for bar = 1:nMultiBars
                    kernelsGPU = sumGPU{bar}./normDenom2D{bar};
                    noiseKernels(:,n,bar,:) = reshape(kernelsGPU,maxTau*maxTau,1,1,nRoi);
                end
        end
    end

    %% Save the noiseKernels AND any information you might want to save about 
    % extraction in the noiseKernels structure. If you save the noiseKernels, this is
    % the structure that will be saved. 
    Z.noiseKernels.rotBt = rotBy;
    Z.noiseKernels.noiseKernels = noiseKernels;
    Z.noiseKernels.kernel_ROIs = Z.ROI.roiMasks(:,:,ROIuse);
    Z.noiseKernels.whichKernel = whichKernel;
    Z.noiseKernels.maxTau = maxTau;

    %% Save?    
    if saveKernels
        Z.noiseKernels.fullKernelPathName = tp_saveKernels(Z.params.name,noiseKernels,whichKernel,'noise');
    end

end

