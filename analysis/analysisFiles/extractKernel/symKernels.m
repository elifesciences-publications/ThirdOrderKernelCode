function [ kernels ] = symKernels( kernels,order )
% Adds symmetrical kernel to output of catKernels

switch order
    case 1
        kernels.allVectors.k1_sym = (kernels.allVectors.k1_x - kernels.allVectors.k1_y)/2;
    case 2
        N = size(kernels.allVectors.k2_xy,2);
        maxTau = round(sqrt(size(kernels.allVectors.k2_xy,1)));
        for q = 1:N
            thisReshape = reshape(kernels.allVectors.k2_xy(:,q),[maxTau maxTau]);
            thisSym = (thisReshape - thisReshape')/2;
            kernels.allVectors.k2_sym(:,q) = thisSym(:);
        end
    case 3
        kernels.allVectors.k3_sym = (kernels.allVectors.k3_xxy - kernels.allVectors.k3_yyx)/2;
end

end

