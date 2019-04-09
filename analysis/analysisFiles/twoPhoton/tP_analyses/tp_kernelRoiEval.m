function [ output_args ] = tp_kernelRoiEval( Z, inKernelPaths, ROIs )
% Compare strength and appearance of 2o kernel with characteristics of ROI.
% Using ROIuse not good enough here - explicitly enter the correspondence
% between kernels in the kernel input and original ROIs.

    loadFlexibleInputs(Z);  
    nRoi = length(ROIs);
    fs = 60;
    
    %% Load input kernels
    for r = 1:2
        evalc(['load ' inKernelPaths{r} ]);
        kernels{r} = saveKernels.kernels;
    end
    
    %% Compute direction selectivity of linear kernels: +/- 1 hz resp
    for r = 1:nRoi
        [ ftAxis linearTuning(:,r) ] = predictLinearTuning(kernels{1}(:,:,r),fs);
    end
    figure; imagesc(linearTuning);
    blockLen = (size(linearTuning,1)-1)/2;
    linearTuningMean = mean(linearTuning(2:blockLen+1,:),1) - mean(linearTuning(blockLen+2:end,:),1);
    linearDsIndex = linearTuning(:,r);
%     linearDsIndex = (flipud(linearTuning(1:blockLen,:)) - linearTuning(blockLen+2:end,:)) ...
%         ./ (flipud(linearTuning(1:blockLen,:)) + linearTuning(blockLen+2:end,:));
    linearDsIndex = ( linearTuning(blockLen+2:end,:) - flipud(linearTuning(1:blockLen,:)) );
    linearDsIndex = linearDsIndex * diag(max(abs(linearDsIndex),[],1))^-1;
%     figure; imagesc(linearDsIndex);

    %% Compute direction selectiviy of all 2o kernels
    % Admittedly I haven't noticed much visible here, but maybe computing
    % this index will make it easier to see. 
    
    %% Compare to Actual Direction Selectivity
    
    %% Project 
    
    
    
    


end

