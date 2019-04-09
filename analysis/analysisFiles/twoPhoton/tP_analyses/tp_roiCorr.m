function R = tp_roiCorr( Z, whichEpoch, ROIs, title )
% Correlates the response of chosen ROIs.

    roiInds = getEpochInds(Z,whichEpoch);
    roiInds = [ min(roiInds{1}):size(Z.filtered.roi_avg_intensity_filtered_normalized,1) ];

    if nargin < 3
        ROIs = [ 1:size(Z.ROI.roiMasks,3)-1 ];
    end
    
    if nargin < 4 
        title = [];
    end
    
    if ~isnumeric(ROIs)
        switch ROIs
            case 'all'
                ROIs = [1:size(Z.ROI.roiMasks,3)-1];
        end
    end
    
    % Pick out correct subset of traces
    traceMat = Z.filtered.roi_avg_intensity_filtered_normalized(roiInds,ROIs);
    
    % Normalize
    traceMatNorm = sphereColumns(traceMat);
    
    % View R^2
    R = traceMatNorm'*traceMatNorm;
    figure;
    subplot(1,2,1);
    imagesc(R .* (ones(length(ROIs)) - eye(length(ROIs)))); colormap(parula);
    set(gca,'FontSize',16); xlabel('ROI id'); ylabel('ROI id');
    subplot(1,2,2);
    viewMaps = zeros(size(Z.ROI.roiMasks,1),size(Z.ROI.roiMasks,2));
    for q = 1:length(ROIs);
        viewMaps = viewMaps + q * Z.ROI.roiMasks(:,:,ROIs(q));
    end 
    imagesc(viewMaps); set(gca,'FontSize',16); colormap(parula);
    suptitle(title);  
    
end

