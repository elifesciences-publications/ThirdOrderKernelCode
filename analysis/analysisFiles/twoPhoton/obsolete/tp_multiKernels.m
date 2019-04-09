function Z = tp_multiKernels( Z )

    pathName = [];
    nMultiBars = 4;
    nROI = size(Z.ROI.roiMasks,3)-1;
    tauSpan = 60;
    roiChooseType = 'manual';
    roiManualSelectCriterion = 'angle';
    nManualRoi = 10;
    whichKernel = 'first';
    maxTau = 10;
    saveKernels = 0;
    testKernelData = 0;
    parDisp = 1;
    lookBothWays = 0;
    pushStart = 0;
    noiseKernel = 0;
    startBack = 10;
    
    loadFlexibleInputs(Z)
    
    %% Pick which ROIs to extract
    
    if ~testKernelData
        
        nManualRoi = min(nManualRoi,size(Z.ROI.roiMasks,3)-1);

        switch roiChooseType
            case 'manual'

                % left, right, up, down
                endTrace = max(Z.diffEp.lowerInds{2}(:));
                diffEpTrace = zeros(endTrace,2);
                for q = 1:2
                    getInds = Z.diffEp.lowerInds{q};
                    diffEpTrace(getInds,q) = 1;
                end
                traces = Z.filtered.roi_avg_intensity_filtered_normalized(1:endTrace,:);

                switch roiManualSelectCriterion
                    case 'magnitude'
                        tracesNormed = traces;
                    case 'angle'
                        for q = 1:size(traces,2)
                            thisNorm = norm(traces(:,q));
                            if thisNorm ~= 0
                                tracesNormed(:,q) = traces(:,q) / norm(traces(:,q));
                            else
                                tracesNormed(:,q) = traces(:,q);
                            end
                        end
                end

                leftProj = tracesNormed'*diffEpTrace(:,1);
                rightProj = tracesNormed'*diffEpTrace(:,2);

                [ leftSort leftSortInds ] = sort(leftProj);
                [ rightSort rightSortInds ] = sort(rightProj);

                % Pick left-selective epochs
                ID = leftSortInds(end-(nManualRoi-1):end);
                traceData = Z.filtered.roi_avg_intensity_filtered_normalized(1:endTrace,ID);
                overlay = diffEpTrace(:,1);
                plotTracesAndMaps( Z, ID, traceData, overlay );
                ROIuse_left = input('Pick which left-selective epochs to use:\n');
                close;

                % Pick right-selective epochs
                ID =rightSortInds(end-(nManualRoi-1):end);
                traceData = Z.filtered.roi_avg_intensity_filtered_normalized(1:endTrace,ID);
                overlay = diffEpTrace(:,2);
                plotTracesAndMaps( Z, ID, traceData, overlay );
                ROIuse_right = input('Pick which right-selective epochs to use:\n');
                close;

                ROIuse = [ ROIuse_left(:); ROIuse_right(:) ]';

            case 'all'
                ROIuse = [1:1:size(Z.ROI.roiMasks,3)-1];       
        end
        
    end
        
    %% Interpolate and align stimulus and response
    
    if testKernelData               
        [alignedStimulusData responseData] = tp_genCheapTestKernelData('which',[0 1 0]);
        kernelInds = [1:1:size(responseData,1)];
        ROIuse = [1:1:size(responseData,2)];
        
    else              
%         grabStimpathName = fullfile(pathName, fn);
        [allStimulusBehaviorData] = Z.stimulus.allStimulusBehaviorData;%grabStimulusData(grabStimpathName);

        if ~isempty(stimulusDataCols)
            stimulusData = allStimulusBehaviorData.StimulusData(:,stimulusDataCols);
        else
            stimulusData = allStimulusBehaviorData.StimulusData;
        end

        filteredTraces = Z.filtered.roi_avg_intensity_filtered_normalized;
%         filteredTraces = Z.rawTraces.roi_intensities;
        roiCenterOfMass = Z.ROI.roiCenterOfMass;

        for q = 1:nMultiBars
            if ~linescan
                for r = 1:length(ROIuse)
                    roi = ROIuse(r);
                    [alignedStimulusData{q}(:, r), responseData(:, r), fsFactor, expectedFlashIndices] = alignStimulusAndResponse(stimulusData(:, q), allStimulusBehaviorData, filteredTraces(:, roi), trigger_inds, Z, roiCenterOfMass(roi)/imgSize(1));
                end
            else
                for r = 1:length(ROIuse)
                    roi = ROIuse(r);
                    [alignedStimulusData{q}(:, r), responseData(:, r), fsFactor, expectedFlashIndices] = alignStimulusAndResponse(stimulusData(:, q), allStimulusBehaviorData, filteredTraces(:, roi), trigger_inds, Z);
                end
            end
        end  

        epochBoundForKernel = expectedFlashIndices.(['epoch_' num2str(epochForKernel)]).bounds;
        kernelInds = epochBoundForKernel(1, 1):1:epochBoundForKernel(end, end); 
    end
    
    %% Kernel extraction

    shiftStart = 0;
    maxTauUse = maxTau;
    
    % shiftStart if lookBothWays or simply shift (pushStart)
    if lookBothWays
        shiftStart = maxTau;
        maxTauUse = 2*maxTau + 1;
    elseif pushStart
        shiftStart = maxTau;
        maxTauUse = maxTau;
        endNum = length(kernelInds);
    end
    kernelIndsUse = kernelInds(shiftStart+1:end);
    
    % Rotation if noiseKernel
    for q = 1:length(alignedStimulusData)
        rotBy = floor(length(kernelIndsUse)/2);
        stimDataUse{q} = alignedStimulusData{q}(kernelIndsUse(1:end),:);
        if noiseKernel
            firstBunch = stimDataUse{q}(1:rotBy,:);
            secondBunch = stimDataUse{q}(rotBy+1:end,:);
            stimDataUse{q} = [secondBunch; firstBunch];
        end
    end
    
    %% Mean subtract response
    % Even though traces are in delta F / F, those means are computed over
    % the whole imaging session and not just the part used for kernel
    % extraction, so will not be zero mean without this
    
    responseData(kernelInds,:) = responseData(kernelInds,:) - repmat( ...
        mean(responseData(kernelInds,:),1), [ length(kernelInds) 1]);
    
    %% Extract Kernels
    switch whichKernel
        case 'first'
            for q = 1:nMultiBars
                for r = 1:length(ROIuse)
                    kernels(:,q,r) = oneD_filter(stimDataUse{q}(:,r),...
                        responseData(kernelIndsUse(1:end) - shiftStart,r),maxTauUse);
                end
            end
            
        case 'second'
            for q = 1:nMultiBars
                firstInd = q;
                secondInd = mod(q,nMultiBars)+1;
                for r = 1:length(ROIuse)
                    inVar = var(stimDataUse{q}(:,r));
                    kernels(:,q,r) = twod_fast(maxTauUse,inVar,stimDataUse{firstInd}(:,r),...
                            stimDataUse{secondInd}(:,r),responseData(kernelIndsUse(1:end) - shiftStart,r));
                end
            end 
            
        case 'perpendicular'      
            perpSpan = 10;
            perpVals = [-perpSpan:1:perpSpan];
            cutInds = [startBack+perpSpan+maxTauUse+1:1:length(kernelIndsUse)];  
            kernels = zeros(2*perpSpan+1,nMultiBars,length(ROIuse));
            for q = 1:nMultiBars
                firstInd = q;
                secondInd = mod(q,nMultiBars)+1;
                for r = 1:length(ROIuse)
                    visualizeHits = zeros(perpSpan+startBack+maxTauUse);
                    X = zeros(length(cutInds),2*perpSpan+1);
                    tau1 = startBack;
                    for tau2 = startBack:startBack+perpSpan                        
                        for s = 0:maxTauUse-1
                            visualizeHits(tau1+s,tau2+s) = visualizeHits(tau1+s,tau2+s)+ (tau2);           
                            X(:,perpSpan+(tau2-startBack)+1) = X(:,perpSpan+(tau2-startBack)+1) + ...
                                stimDataUse{firstInd}(cutInds - (tau1+s),r) .* ...
                                stimDataUse{secondInd}(cutInds  - (tau2+s),r);
                            if tau2 ~= startBack
                                visualizeHits(tau2+s,tau1+s) = visualizeHits(tau2+s,tau1+s) + -1*(tau2-(startBack)+1);
                                X(:,perpSpan-(tau2-startBack)+1) = X(:,perpSpan-(tau2-startBack)+1) + ...
                                    stimDataUse{firstInd}(cutInds - (tau2+s),r) .* ...
                                    stimDataUse{secondInd}(cutInds  - (tau1+s),r);
                            end
                        end                       
                    end 
                    kernels(:,q,r) = (X'*X)^-1*X'*responseData(cutInds - shiftStart,r);
                end               
            end     
            figure; imagesc(visualizeHits);
    end

    %% Save the kernels AND any information you might want to save about 
    % extraction in the kernels structure. If you save the kernels, this is
    % the structure that will be saved. 
    
    Z.kernels.kernels = kernels;
    Z.kernels.kernel_ROIs = Z.ROI.roiMasks(:,:,ROIuse);
    Z.kernels.whichKernel = whichKernel;
    Z.kernels.maxTau = maxTau;
    
    %% Save?
    
    if saveKernels
        if noiseKernel
            tp_saveKernels(Z,'noise');
        else
            tp_saveKernels(Z);
        end
    end
   
end

