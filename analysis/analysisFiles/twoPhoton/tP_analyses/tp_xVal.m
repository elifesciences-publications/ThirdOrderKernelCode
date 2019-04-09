function Z = tp_xVal( Z, forceModel )
%   Abandon all hope, ye who enter here.

    %% Default params
    nCuts = 10;
    which = [1 0 0];
    nonlinearity = 'identity';
    loadFlexibleInputs(Z);
    
    %% Load contents of Z flick
    flickNames = fieldnames(Z.flick);
    for ii = 1:length(flickNames)
        eval([flickNames{ii} '= Z.flick.' flickNames{ii} ';']);
    end
    nT = length(kernelInds);
    nRoi = size(responseData,2);
    nMultiBars = size(alignedStimulusData,2);
        
    %% Create a folder to save all of this
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    xValFolder = C{1}{3};
    xValFolderPath = sprintf('%s/twoPhoton/xVal/%s/%s/%s',xValFolder,Z.params.name,datestr(now,'dd_mm_yy'),datestr(now,'HH_MM'));         
    mkdir(xValFolderPath);
    
    %% Select which bars
    if nMultiBars > 4
        multiBarsUse = input('Input which bars to use:');
    else
        multiBarsUse = [1:nMultiBars];
    end

    %% Loop through segments and extract fractional kernels
    cutStarts = round(linspace(1,nT,nCuts+1));
    
    tic;
    for q = 1:nCuts        
        clear xVal
        % Set indices for small fraction (test data) and large fraction
        % (extraction data)
        minInds{q} = [cutStarts(q):cutStarts(q+1)-1];
        majInds{q} = [1:nT];
        majInds{q}(minInds{q}) = [];
        if nargin < 2
            %% Fit model to major segment of data
            %%  Make "pretend Z.flick"
            A = Z;
            A.flick.kernelInds = kernelInds(majInds{q});
            A.params.saveKernels = 0;
            A.params.multiBarsUse = multiBarsUse;
            possibleKernels = {'first','second'};
            % extract kernels
            clear kernels
            for r = 1:2          
                if which(r)
                    A.params.whichKernel = possibleKernels{r};
                    clear A.kernels
                    A = tp_kernels(A);
                    kernels{r} = A.kernels.kernels;
                else
                    kernels{r} = zeros(maxTau^r,nMultiBars,nRoi);
                end
            end          
            xVal.kernels = kernels;

            %% extract nonlinearity
            A = tp_kernelPrediction(A,xVal.kernels);
            A = tp_staticNonlinearity(A);            
            xVal.nlData = A.NL.nlData;
            xVal.nonlinearity = A.NL.nonlinearity;
            
        else
            xVal.kernels = forceModel.kernels;
            xVal.nonlinearity = forceModel.nonlinearity;
            xVal.nlData = forceModel.nlData;
            
        end
        
        %% put everything in xVal structure
        xVal.minInds = minInds;
        xVal.majInds = majInds;      
        
        %% Save model
        xValName = sprintf('xVal_model_%i',q);
        fullxValPathName{q} = sprintf('%s/%s',xValFolderPath,xValName);
        save(fullxValPathName{q},'xVal');
        fprintf('Section %i saved.\n',q); toc;
        
    end    

    %% Run on small remaining data fraction
    % Load the kernel you just conveniently saved above
    for q = 1:nCuts
        load(fullxValPathName{q});
        A = Z;
        A.flick.kernelInds = kernelInds(minInds{q});
        A = tp_kernelPrediction(A,xVal.kernels);
        A = tp_staticNonlinearity(A,xVal);
        kernelR(q,:) = A.kPred.kernelR;
        nlR(q,:) = A.NL.nlR;
        fprintf('Section %i tested.\n',q); toc;
    end
    
    Z.xVal.kernelR = kernelR;
    Z.xVal.nlR = nlR;
    Z.xVal.fullxValPathName = fullxValPathName;
    Z.xVal.majInds = majInds;
    Z.xVal.minInds = minInds;
    
end

