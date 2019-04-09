function [ combed ] = combKernels( kernelVects,order )
% Averages and reshapes kernels

allVectors = kernelVects.allVectors;

for qq = 1:length(allVectors)
    switch order
        case 1
            numFiles.k1_x = size(allVectors.k1_x,2);
            meanKernels.k1_x = mean(allVectors.k1_x,2);
            numFiles.k1_y = size(allVectors.k1_y,2);
            meanKernels.k1_y = mean(allVectors.k1_y,2);
            if isfield(allVectors,'k1_sym')
                numFiles.k1_sym = size(allVectors.k1_sym,2);
                meanKernels.k1_sym = mean(allVectors.k1_sym,2);
            end
            
        case 2
            reSz = round(size(allVectors.k2_xy,1)^(1/2));
            numFiles.k2_xy = size(allVectors.k2_xy,2);
            meanKernels.k2_xy = mean(allVectors.k2_xy,2);
            meanKernels.k2_xy = reshape(meanKernels.k2_xy,[reSz reSz]);
            if isfield(allVectors,'k2_sym');
                numFiles.k2_sym = size(allVectors.k2_sym,2);
                meanKernels.k2_sym = mean(allVectors.k2_sym,2);
                meanKernels.k2_sym = reshape(meanKernels.k2_sym,[reSz reSz]);
            end
            if isfield(allVectors,'k2_xx')
                numFiles.k2_xx = size(allVectors.k2_xx,2);
                meanKernels.k2_xx = mean(allVectors.k2_xx,2);
                meanKernels.k2_xx = reshape(meanKernels.k2_xx,[reSz reSz]);
                numFiles.k2_yy = size(allVectors.k2_yy,2);
                meanKernels.k2_yy = mean(allVectors.k2_yy,2);
                meanKernels.k2_yy = reshape(meanKernels.k2_yy,[reSz reSz]);
            end
        case 3
            reSz = round(size(allVectors.k3_xxy,1)^(1/3));
            numFiles.k3_xxy = size(allVectors.k3_xxy,2);
            meanKernels.k3_xxy = mean(allVectors.k3_xxy,2);
            meanKernels.k3_xxy = reshape(meanKernels.k3_xxy,[reSz reSz reSz]);
            numFiles.k3_yyx = size(allVectors.k3_yyx,2);
            meanKernels.k3_yyx = mean(allVectors.k3_yyx,2);
            meanKernels.k3_yyx = reshape(meanKernels.k3_yyx,[reSz reSz reSz]);
            if isfield(allVectors,'k3_sym')
                numFiles.k3_sym = size(allVectors.k3_sym,2);
                meanKernels.k3_sym = mean(allVectors.k3_sym,2);
                meanKernels.k3_sym = reshape(meanKernels.k3_sym,[reSz reSz reSz]);
            end
            if isfield(allVectors,'k3_xxx')
                numFiles.k3_xxx = size(allVectors.k3_xxx,2);
                meanKernels.k3_xxx = mean(allVectors.k3_xxx,2);
                meanKernels.k3_xxx = reshape(meanKernels.k3_xxx,[reSz reSz reSz]);
                numFiles.k3_yyy = size(allVectors.k3_yyy,2);
                meanKernels.k3_yyy = mean(allVectors.k3_yyy,2);
                meanKernels.k3_yyy = reshape(meanKernels.k3_yyy,[reSz reSz reSz]);
            end
    end
end

combed.meanKernels = meanKernels;
combed.numFiles = numFiles;

end

