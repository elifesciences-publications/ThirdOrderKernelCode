function [ void ] = seeKernels( kernels,order,threeDtype )
% Visualize kernels

if ~exist('threeDtype')
    threeDtype = 'slice';
end

meanKernels = kernels.meanKernels;

switch order
    case 1
        figure; 
        subplot(2,1,1);
        plot(kernels.meanKernels.k1_x);
        title('X filter');
        subplot(2,1,2);
        plot(kernels.meanKernels.k1_y);
        title('Y filter');        
    case 2
        figure; 
        if isfield(meanKernels,'k2_sym')            
            imagesc(kernels.meanKernels.k2_sym);
            maxVal = max(abs(kernels.meanKernels.k2_sym(:)));
        else
            imagesc(kernels.meanKernels.k2_xy);
            maxVal = max(abs(kernels.meanKernels.k2_xy(:)));
        end
        colormap_gen; colormap(mymap);
        set(gca,'Clim',[-maxVal maxVal]);
        
    case 3
        switch threeDtype
            case 'slice'
                numSlices = min([9 length(kernels.meanKernels.k3_xxy)]);
                if isfield(meanKernels,'k3_sym')
                    threeDvisualize_slices(length(kernels.meanKernels.k3_xxy),...
                        numSlices,removeDiag(kernels.meanKernels.k3_sym));                
                else
                    threeDvisualize_slices(length(kernels.meanKernels.k3_xxy),...
                        numSlices,kernels.meanKernels.k3_xxy);
                end
            case 'gobs'
                threeDvisualize_gobs(kernels.meanKernels.k3_xxy, 5.1);
        end
end

void = 0;

end

