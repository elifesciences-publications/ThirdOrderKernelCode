function Z = tp_kernelPrediction( Z, inKernels )
% Generate linear expected response to stimulus from kernels selected

    which = [1 1 0];
    kernelPaths = [];
    comparePredPlots = 0;
    filterRespCos = [];
    multiBarsUse = [];
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
    if isempty(multiBarsUse)
        multiBarsUse = 1:nMultiBars;
    end
    
    if nargin < 2 || isempty(inKernels)
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
    
    %% Optionally - filter response 
%     highFreq = 2.5;
%     lowFreq = 1/4;
%     filterRespCos = [lowFreq highFreq]/60;
% %     if ~isempty(filterRespCos)
%         [B, A] = butter(2,filterRespCos);
%         responseDataOriginal = responseData;
%         for q = 1:size(responseData,2);
%             responseData(:,q) = filtfilt(B, A, responseData(:,q));
%         end
% %     end
%     keyboard
        
    %% Reorganize for compatibility with flyResp
    maxTau = round(sqrt(size(inKernels{2},1)));
    for qp = 1:length(multiBarsUse)
        q = multiBarsUse(qp);
        for r = 1:nRoi
            useKernels{q,r}{1} = inKernels{1}(1:maxTau,q,r);
            useKernels{q,r}{2} = reshape( inKernels{2}(:,q,r), [ maxTau maxTau ] );
        end   
    end      

    %% Create predicted response
    tic;
    expected = zeros(nT,nRoi);
    for qp = 1:length(multiBarsUse)
        q = multiBarsUse(qp);
        firstInd = q;
        secondInd = mod(q,nMultiBars) + 1;               
        for r = 1:nRoi
            x = alignedStimulusData{firstInd}(kernelInds,r);
            y = alignedStimulusData{secondInd}(kernelInds,r);
            expected(:,r) = expected(:,r) + ...
                flyResp( which,useKernels{q,r},maxTau,x,y );
            fprintf(['Response prediction generated for ROI ' num2str(r) ', bar ' num2str(q) '. ']); toc;
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
    Z.kPred.kernelPaths = kernelPaths;
    Z.kPred.expected = expected;
    Z.kPred.kernelR = kernelR;
    Z.kPred.which = which;
%     Z.flick.responseData = responseData;
%     Z.flick.responseDataOriginal = responseDataOriginal;
%     Z.flick.filterRespCos = filterRespCos;
    
end

