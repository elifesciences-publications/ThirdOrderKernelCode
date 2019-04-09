function Z = tp_kernelTestData( Z )
% Creates test data that emulates the output of alignStimulusAndResponse
% for kernel extraction. 

    %% Generate Test Kernel Data
    
    nMultiBars = 4;
    nonlinearity = 'identity';
    nSamples = 1e4;
    inVar = 1;
    dist = 1;
    maxTau = 10;
    noiseVar = 0;
    saveKernels = 1;
    which = [1 1 0];
    multiBarsUse = [1:nMultiBars];
    
    loadFlexibleInputs(Z);
    
    % Need to overwrite the ROI number from the original file
    nRoi = 2;
    
    %% Generate flicker input
    
    for q = 1:nMultiBars
        alignedStimulusData{q} = ...
            repmat( randInput(inVar,dist,nSamples)', [ 1 nRoi ] );
    end

    %% Create stimulus with first and second-order dependence on flicker input
   
    tic; 
    fprintf('\n\n');
    filters = exampleFilters(which,maxTau);
    responseData = zeros(nSamples,nRoi);
    for r = 1:nRoi
        for q = multiBarsUse
            firstInd = q;
            secondInd = mod(q,nMultiBars)+1;
            responseData(:,r) = responseData(:,r) + flyResp( which,filters,maxTau,...
                alignedStimulusData{firstInd}(:,1),alignedStimulusData{secondInd}(:,1),noiseVar,[1 0],nonlinearity );
            fprintf('Bar %i, Roi %i has been added!  ',q,r); toc;
        end
    end
    fprintf('\n\n');
    
    %% Save filters in correct format
    
    if saveKernels
        % Make directory
        HPathIn = fopen('dataPath.csv');
        C = textscan(HPathIn,'%s');
        kernelFolder = C{1}{3};
        kernelFolderPath = sprintf('%s/twoPhoton/testKernels/%s',kernelFolder,datestr(now,'dd_mm_yy'));  
        if ~isdir(kernelFolderPath)
            mkdir(kernelFolderPath);       
        end
        
        % Save first order
        for q = 1:nMultiBars
            saveKernels.kernels = repmat(filters{1}',[1 nMultiBars,nRoi]);
        end
        kernelName = sprintf('first_test_%s',datestr(now,'HH_MM'));
        fullKernelPathName = sprintf('%s/%s',kernelFolderPath,kernelName);
        save(fullKernelPathName,'saveKernels');
        
        % Save second order
        for q = 1:nMultiBars
            saveKernels.kernels = repmat(filters{2}(:),[1 nMultiBars,nRoi]);
        end
        kernelName = sprintf('second_test_%s',datestr(now,'HH_MM'));
        fullKernelPathName = sprintf('%s/%s',kernelFolderPath,kernelName);
        save(fullKernelPathName,'saveKernels');      
    end        
    
    %% Put everything in format as if had run flickerSelectAndAlign
    
    Z.flick.kernelInds = [1:nSamples];
    Z.flick.alignedStimulusData = alignedStimulusData;
    Z.flick.responseData = responseData;
    Z.flick.ROIuse = [1:nRoi];
    Z.flick.filters = filters;
    Z.flick.noiseVar = noiseVar;
    Z.flick.inVar = inVar;
    
end

