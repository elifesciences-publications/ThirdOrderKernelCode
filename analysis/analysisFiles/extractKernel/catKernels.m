function [ cated ] = catKernels( order,whichBehav,kernelPaths,isOLS )
% Takes the fly-by-fly kernel vectors saved by extractKernel and puts them
% together within single variables

if nargin < 4
    isOLS = 0;   
end

% Read in paths to kernels, if not entered as argument
if isnumeric(kernelPaths)
        HPathIn = fopen('dataPath.csv');
        C = textscan(HPathIn,'%s');
        kernel_folder = C{1}{3};        
        paths.folders = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose folders containing kernel vectors');
        kernelPaths = paths.folders;
end
  
% get every kernel file of given order within kernelPaths. Flag the issue
% if there are multiple kernels of the same order within a folder, but 
% default to choosing the first kernel.
kernelFiles = cell(0,1);
if isOLS
    prefix = sprintf('%s_*',whichBehav);
else
    prefix = sprintf('%s_%io*',whichBehav,order);
end

for ii = 1:size(kernelPaths,2)
        thisFold = dirrec(kernelPaths{ii},prefix)';
        kernelFiles = cat(1,kernelFiles,thisFold);
end
rr = size(kernelFiles,1);

% loop over "rightOrderFiles', save individual kernel vectors
seqInd = ones(4,1);
for qq = 1:rr
    evalc(['load ' kernelFiles{qq}]);
    if isOLS
        kernels = renameOLS(kernels,order);
    end
    switch order
        case 1            
            getNumFlies = size(kernels.k1_x_all,2);
            allVectors.k1_x(:,seqInd(1):seqInd(1)+getNumFlies-1) = kernels.k1_x_all;
            allVectors.k1_y(:,seqInd(2):seqInd(2)+getNumFlies-1) = kernels.k1_y_all;
            seqInd(1:2) = seqInd(1:2) + getNumFlies;
        case 2
            getNumFlies = size(kernels.k2_xy_all,2);
            allVectors.k2_xy(:,seqInd(1):seqInd(1)+getNumFlies-1) = kernels.k2_xy_all;
            if isfield(kernels,'k2_xx_all')
                allVectors.k2_xx(:,seqInd(2):seqInd(2)+getNumFlies-1) = kernels.k2_xx_all;
                allVectors.k2_yy(:,seqInd(3):seqInd(3)+getNumFlies-1) = kernels.k2_yy_all;
            end
            seqInd(1:3) = seqInd(1:3) + getNumFlies;
        case 3
            getNumFlies = size(kernels.k3_xxy_all,2);
            allVectors.k3_xxy(:,seqInd(1):seqInd(1)+getNumFlies-1) = kernels.k3_xxy_all;
            allVectors.k3_yyx(:,seqInd(2):seqInd(2)+getNumFlies-1) = kernels.k3_yyx_all;
            if isfield(kernels,'k3_xx_all')
                allVectors.k3_xxx(:,seqInd(3):seqInd(3)+getNumFlies-1) = kernels.k3_xxx_all;
                allVectors.k3_yyy(:,seqInd(4):seqInd(4)+getNumFlies-1) = kernels.k3_yyy_all;
            end
            seqInd(1:4) = seqInd(1:4) + getNumFlies;
    end
end

cated.allVectors = allVectors;
cated.kernelFiles = kernelFiles;

end

