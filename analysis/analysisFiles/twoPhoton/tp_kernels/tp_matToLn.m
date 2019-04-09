function Z = tp_matToLn( Z, epochForKernel, varargin )
% takes the output of the pre-analysis of twoPhotonMaster, extracts and
% saves LN model corresponding to usual default parameters.

    %% Defaults
    whichKernels = [ 1 1 ];
    maxTaus = [30 64];
    roiChooseType = 'ttest';
    epochsForSelectivity = {'Square Left','Square Right'; 'Square Right','Square Left'};
    saveKernels = 1;
    saveNL = 1;
    nType = 'polyfit';
    polyOrder = 4;
    saveFlick = 1;
    flickPath = [];
    nMultiBars = 4;
    specialName = [];
    Z.params.epochForKernel = epochForKernel;  
    doKernel = 1;
    doLN = 0;
    doNoise = 0;
    ROIuse = [];
    inKernels = [];
    
    %% varargin
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end   
    Z.params.specialName = specialName;

    %% Run filtering % this might be omitted...
    if ~isfield(Z,'filtered');
        Z = filterRoiTraces(Z);
    end
    
    %% Get stimulus data
    if ~isfield(Z,'stimulus')
        Z.stimulus = loadStimulusData(Z);
    end
    
    %% Run and save alignment
    Z.params.nMultiBars = nMultiBars;
    if ~isempty(flickPath)
        evalc(['load ' flickPath]);
        Z.flick = saveFlick;
    elseif ~isfield(Z,'flick')
        Z.params.roiChooseType = roiChooseType;
        Z.params.ROIuse = ROIuse;
        Z.params.epochsForSelectivity = epochsForSelectivity;
        if saveFlick
            Z.params.saveFlick = 1;
        end
        Z = tp_flickerSelectAndAlign(Z);
    end 
    respData = Z.flick.responseData;
    respData(isnan(respData)) = 0;
    Z.flick.responseData = respData;
    
    %% Extract kernels
    if doKernel
        kernelTypes = {'first','second'};
        minMaxTau = min(maxTaus);
        Z.params.epochForKernel = epochForKernel;
        for q = find(whichKernels)
            Z.params.whichKernel = kernelTypes{q};
            Z.params.maxTau = maxTaus(q);
            Z.params.saveKernels = saveKernels;
            Z = tp_kernels(Z);         
            kernelPaths{q} = Z.kernels.fullKernelPathName;
            inKernels{q} = Z.kernels.kernels(1:minMaxTau^q,:,:);
        end
    end
    
    %% Extract Noise Kernels
    if doNoise
        kernelTypes = {'first','second'};
        for q = find(whichKernels)          
            Z.params.whichKernel = kernelTypes{q};
            Z.params.maxTau = maxTaus(q);
            Z = tp_noiseKernels(Z);
        end
    end
        
    %% Fit LN models
    if doLN
        Z = tp_kernelPrediction( Z, inKernels );
        Z.params.nType = nType;
        Z.params.saveNL = saveNL;
        Z.params.polyOrder = polyOrder;
        Z = tp_staticNonlinearity(Z);
    end

end

