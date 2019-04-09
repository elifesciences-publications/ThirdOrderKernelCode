function Z = tp_flickerSelectAndAlign( Z )
% Select ROIs and align stimulus and response data for kernel extraction,
% LN modeling, etc.

    nMultiBars = 4;
    nROI = size(Z.ROI.roiMasks,3)-1;
    tauSpan = 60;
    roiChooseType = 'ttest';
    roiManualSelectCriterion = 'angle';
    nManualRoi = 10;
    testKernelData = 0;
    noiseVar = 0;
    inVar = 1;
    optionSet = 1;
    ROIuse = [];
    saveFlick = 0;
   epochForKernel = 3;
    
    roiChooseType = 'all';
    
    roiChooseType = 'all';
    loadFlexibleInputs(Z)
    
    %% Select ROIs

    if ~testKernelData && isempty(ROIuse)
        switch roiChooseType
            case 'ttest'
                [ROIuse, pValsSum] = extractROIsBySelectivity(Z);
                ROIuse = find(ROIuse);          
            case 'all'
                ROIuse = [1:1:size(Z.ROI.roiMasks,3)-1]; 
            case ''
        end
    end

    %% Interpolate and align stimulus and response
    
    if testKernelData    
        [alignedStimulusData, responseData, testDataSettings] = ...
            tp_genCheapTestKernelData('noiseVar',noiseVar,'inVar',inVar,'optionSet',optionSet);
        kernelInds = [1:1:size(responseData,1)];
        ROIuse = [1:1:size(responseData,2)];
        Z.flick.testDataSettings = testDataSettings;
        
    else              
        grabStimPath = fullfile(pathName, fn);
        if ~isfield(Z,'stimulus')
            [allStimulusBehaviorData] = grabStimulusData(Z);
        else
            allStimulusBehaviorData = Z.stimulus.allStimulusBehaviorData;
        end

        if ~isempty(stimulusDataCols)
            stimulusData = allStimulusBehaviorData.StimulusData(:,stimulusDataCols);
        else
            stimulusData = allStimulusBehaviorData.StimulusData;
        end

        filteredTraces = Z.filtered.roi_avg_intensity_filtered_normalized;
        roiCenterOfMass = Z.ROI.roiCenterOfMass;

        %% Concatenate spatial alignment trace onto response data
        if ~linescan
            filteredTraces = cat(2,filteredTraces,Z.grab.alignmentData);
            roiCenterOfMass = cat(1,roiCenterOfMass,[imgSize(1)/2 imgSize(2)/2]);
            ROIuse = cat(2,ROIuse,size(Z.ROI.roiMasks,3)); % plus one for add-on, minus one for background.
        end
        
        for q = 1:nMultiBars
            if ~linescan
                tic
                % 1 GB divided by double size, divided by #time points
                % divided by likely upsampling factor ~(13Hz to 60Hz). Sqrt
                % because of the weird things interp1 does.
                stepSize = 6;%round(sqrt(1e9/8/size(filteredTraces, 1)/4));
                for r = 1:stepSize:length(ROIuse)
                    if r+stepSize-1 > length(ROIuse)
                        saveInds = r:length(ROIuse);
                    else
                        saveInds = r:r+stepSize-1;
                    end
                    roi = ROIuse(saveInds);
%                      [alignedStimulusDataTemp, rDat, fsFactor, expectedFlashIndices] = alignStimulusAndResponse([1:length(allStimulusBehaviorData.Epoch)]', allStimulusBehaviorData, Z.grab.avg_linear_PDintensity, trigger_inds, Z);

                    [alignedStimulusDataTemp, responseData(:, saveInds), fsFactor, expectedFlashIndices] = alignStimulusAndResponse(stimulusData(:, q), allStimulusBehaviorData, filteredTraces(:, roi), trigger_inds, Z, roiCenterOfMass(roi)/imgSize(1));
                    fprintf('ROI %i out of %i aligned for bar %i. ',r,length(ROIuse),q); toc;
                end
                alignedStimulusData{q} = repmat(alignedStimulusDataTemp,[1,length(ROIuse)]);
                    
                
            else
                [alignedStimulusData{q}, responseData, fsFactor, expectedFlashIndices] = alignStimulusAndResponse(stimulusData(:, q), allStimulusBehaviorData, filteredTraces, trigger_inds, Z);
            end
        end  
        
%         epochForKernel = 3;
        epochBoundForKernel = expectedFlashIndices.(['epoch_' num2str(epochForKernel)]).bounds;
        kernelInds = epochBoundForKernel(1, 1):1:epochBoundForKernel(end, end); 

    end
        
    %% Output   
    Z.flick.kernelInds = kernelInds;
    
    if ~linescan
        for q = 1:nMultiBars
            Z.flick.alignedStimulusData{1,q} = alignedStimulusData{1,q}(:,1:end-1);
        end
        Z.flick.responseData = responseData(:,1:end-1);
        Z.flick.spatialAlignTrace = responseData(:,end);
        Z.flick.ROIuse = ROIuse(1:end-1);
    else
        Z.flick.alignedStimulusData = alignedStimulusData;
        Z.flick.responseData = responseData;
        Z.flick.ROIuse = ROIuse;
    end
        
    Z.flick.paramsUsed = Z.params;
    Z.flick.testKernelData = testKernelData;
    
    %% Save aligned traces
    if saveFlick
        Z.flick.fullFlickPathName = tp_saveFlick(Z);
    end 
    
end

