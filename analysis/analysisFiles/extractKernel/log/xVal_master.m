function [ dataParts,kernelParts,Rs ] = xVal_master( numParts )

HPathIn = fopen('dataPath.csv');
C = textscan(HPathIn,'%s');
data_folder = C{1}{1};
kernel_folder = C{1}{3};
dataParts = cell(1,numParts);

for q = 1:numParts
    dataParts{q} = uipickfiles('FilterSpec',data_folder,'Prompt','Choose folders containing the files to be analyzed');
    kernelParts{q} = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose folders containing the kernels corresponding to each file chunk');
end

%% run xVal

Rs = cell(1,numParts);
for q = 1:numParts
    Z = masterKernels(order,'which',[2 3 4 5 6],'normType','external','kernelPaths',kernelParts{q});
    Rs{q} = xVal(order,'inPaths',dataParts{q},'inKernel',Z.kernels.meanKernels.k2_sym);
end

end

