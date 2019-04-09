function [ dataParts,kernelParts,Rs ] = xVal_master_n( numParts,order,N,varargin )

HPathIn = fopen('dataPath.csv');
C = textscan(HPathIn,'%s');
data_folder = C{1}{1};
kernel_folder = C{1}{3};
dataParts = cell(1,numParts);
isOLS = 0;
maxTau = 50;

for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

for q = 1:numParts
    if ~exist('dataParts','var')
        dataParts{q} = uipickfiles('FilterSpec',data_folder,'Prompt','Choose folders containing the files to be analyzed');
    end
    if ~exist('kernelParts','var') && ~exist('inKernel','var')
        kernelParts{q} = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose folders containing the kernels corresponding to each file chunk');
    end
end

%% run xVal

Rs = cell(1,numParts);
for q = 1:numParts
    Z = masterKernels(order,'which',[2 3 5],'kernelPaths',kernelParts{q},'isOLS',isOLS);
    switch order
        case 1
            inKernel = Z.kernels.meanKernels.k1_x;
        case 2
            inKernel = Z.kernels.meanKernels.k2_sym;
        case 3
            inKernel = Z.kernels.meanKernels.k3_sym;
    end
    Rs{q} = xVal_n(order,N,'maxTau',maxTau,'isOLS',1,'inPaths',dataParts{q},'inKernel',inKernel);
end

end

