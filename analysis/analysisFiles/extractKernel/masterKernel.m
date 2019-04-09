function [ Z ] = masterKernel( order, varargin )
% gets you from raw data to kernel plots

which = [2 3 4 5 6];
normType = 'external';
whichBehav = 'turn';
isOLS = 0;

for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if ~exist('kernelPaths')
    kernelPaths = 0;
end

if any(find(which == 1))
    extractKernels();
end

if any(find(which == 2))
    kernels = catKernels(order,whichBehav,kernelPaths,isOLS);
    Z.cated = kernels;
end

if any(find(which == 3))
    kernels = symKernels(kernels,order);
    Z.symed = kernels;
end

if any(find(which == 4))
    [ kernels, sds ] = normKernels(kernels,order);
    Z.normed = kernels;
    Z.sds = sds;
end

if any(find(which == 5))
    kernels = combKernels(kernels,order);
    Z.combed = kernels;
end

if any(find(which == 6))
    seeKernels(kernels,order);
end

Z.kernels = kernels;
Z.vararg = varargin;

end

