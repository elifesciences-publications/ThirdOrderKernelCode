function Z = tp_multiPrediction( Z, inKernels )
% Generate separate linear prediction to corresponding to each bar pair
    which = [1 1 0];
    kernelPaths = [];
    comparePredPlots = 0;
    filterRespCos = [];
    loadFlexibleInputs(Z);
    
    %% Load everything from flickerSelectAndAlign
    flickNames = fieldnames(Z.flick);
    for ii = 1:length(flickNames)
        eval([flickNames{ii} '= Z.flick.' flickNames{ii} ';']);
    end
    
    %% Get Data
    nRoi = size(responseData,2);
    nMultiBars = size(alignedStimulusData,2);
    nT = length(kernelInds);     
    
    if nargin < 2
    %% Select kernels
        if size(kernelPaths,1)==0
            HPathIn = fopen('dataPath.csv');
            C = textscan(HPathIn,'%s');
            kernel_folder = C{1}{3};        
            kernelPaths{1} = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose the file containing the linear kernel.');
            kernelPaths{2} = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose the file containing the 2o kernel.');     
        end

        %% Load kernels
        for q = 1:2
            load(kernelPaths{q}{1});
            inKernels{q} = saveKernels.kernels;
        end  
    end

    %% Reorganize for compatibility with flyResp
    maxTau = size(inKernels{1},1);
    for q = 1:nMultiBars
        for r = 1:nRoi
            useKernels{q,r}{1} = inKernels{1}(:,q,r);
            useKernels{q,r}{2} = reshape( inKernels{2}(:,q,r), [ maxTau maxTau ] );
        end   
    end      

    %% Create predicted response
    expected = zeros(nT,nRoi,nMultiBars);
    for q = 1:nMultiBars
        firstInd = q;
        secondInd = mod(q,nMultiBars) + 1;               
        for r = 1:nRoi
            x = alignedStimulusData{firstInd}(kernelInds,r);
            y = alignedStimulusData{secondInd}(kernelInds,r);
            expected(:,r,q) = flyResp( which,useKernels{q,r},maxTau,x,y );
        end
    end            
    
    %% Calculate angle
    for r = 1:nRoi        
        expt_ms(:,r) = expected(:,r) - repmat( mean( expected(:,r),1 ), [ nT 1 ]);
        resp_ms(:,r) = responseData(kernelInds,r) - repmat( mean( responseData(kernelInds,r),1 ), [ nT 1 ] );
        kernelR(r) = expt_ms(:,r)'*resp_ms(:,r) / sqrt(expt_ms(:,r)'*expt_ms(:,r) * ...
            resp_ms(:,r)'*resp_ms(:,r));              
    end
    
    if comparePredPlots
        for r = 1:nRoi
            figure; 
%             plot(expt_ms(:,r)/max(abs(expt_ms(:,r)))); 
            plot(expt_ms(:,r));
            hold all;
%             plot(resp_ms(:,r)/max(abs(resp_ms(:,r))));
            plot(resp_ms(:,r));
%             plot(filter(ones(1,20),20,resp_ms(:,r)));
            legend('Kernel Prediction','Actual Response');
            thisTitle = sprintf('ROI %i',ROIuse(r));
            title(thisTitle);
        end
        figure;
        scatter(expt_ms(:),resp_ms(:));
        title('Expected versus measured responses - all ROIs');        
    end
    
    %% save everything    
    Z.multiPred.kernelPaths = kernelPaths;
    Z.multiPred.expected = expected;
    Z.multiPred.kernelR = kernelR;
    Z.multiPred.kernels = useKernels;
%     Z.flick.responseData = responseData;
%     Z.flick.responseDataOriginal = responseDataOriginal;
%     Z.flick.filterRespCos = filterRespCos;

end

