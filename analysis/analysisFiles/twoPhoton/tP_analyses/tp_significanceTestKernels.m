function Z = tp_significanceTestKErnels( Z, kernelPath, noisePath )
% Compute statistics of a set of noise kernels and do significance testing
% on the corresponding real kernels.

    %% Load Default Params
    zThresh = 4;
    loadFlexibleInputs(Z)
    
    %% Get paths, in they don't exist   
    if nargin < 3
        HPathIn = fopen('dataPath.csv');
        C = textscan(HPathIn,'%s');
        kernel_folder = C{1}{3}; 
        kernelPath = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose the files containing the actual kernel.'); 
    end
    if nargin < 2      
        noisePath = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose the files containing the noise kernels.');   
    end 
    % You can technically do this analysis for multiple files, but you need
    % to select the kernels in the same order for each, so maybe this is
    % not recommended. 
    
    %% Loop through elements in input paths
    nFiles = length(kernelPath);
    for q = 1:nFiles
        clear kernelSd
        clear kernelZ
        clear flag
        
        %% Load kernels
        load(kernelPath{q});
        kernel = saveKernels.kernels;
        load(noisePath{q});
        noiseKernel = saveKernels.noiseKernels;
        nReps = size(noiseKernel,2);
        nMultiBars = size(noiseKernel,3);
        nRoi = size(noiseKernel,4);
    
        %% Compute standard deviation of noise kernels
        %(:,n,q,r) 
        for r = 1:nMultiBars
            for s = 1:nRoi
            	kernelSd(:,r,s) = std(noiseKernel(:,:,r,s),[],2);
                kernelZ(:,r,s) = kernel(:,r,s) ./ kernelSd(:,r,s);
                % Flag Kernels with Z score above a certain threshold
                flag(r,s) = any(any(kernelZ(:,r,s) >= zThresh));
            end
        end               
        Z.signif.kernelSd{q} = kernelSd;
        Z.signif.kernelZ{q} = kernelZ;
        Z.signif.flag{q} = flag;
        
    end    
    Z.signif.kernelPath = kernelPath;
    Z.signif.noisePath = noisePath;
        
end

