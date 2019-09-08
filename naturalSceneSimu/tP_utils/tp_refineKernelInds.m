function Z = tp_refineKernelInds( Z, remove )
% Manually cut out movement artifacts from the aligned data. Assumes the
% input of Z.flick.
 
    allRemove = [];
    if nargin < 2
        figure;
        subplot(2,1,1);
        plot(Z.flick.spatialAlignTrace);
        title('Alignment trace');
        subplot(2,1,2);
        plot(Z.filtered.roi_avg_intensity_filtered_normalized);
        numSegments = input('How many segments would you like to remove?');
        for q = 1:numSegments
            remove{q,1} = input('Start cut.');
            remove{q,2} = input('End cut.');        
        end
    end
    for q = 1:size(remove,1)
        allRemove = cat(1,allRemove,[ remove{q,1}:remove{q,2} ]');
    end
    allRemove = allRemove - (min(Z.flick.kernelInds) - 1);
    
    Z.flick.kernelIndsOrig = Z.flick.kernelInds;
    Z.flick.kernelInds(allRemove) = [];
    Z.flick.allRemove = allRemove;

end

