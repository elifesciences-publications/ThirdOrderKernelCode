function Z = tp_STC( Z )
% Subtract off linear prediction, then compute eigenvectors of resulting
% covariance matrix

    %% Params
    loadFlexibleInputs(Z);       
    expected = Z.multiPred.expected;
    responseData = Z.flick.responseData;  
    stimulusData = Z.flick.alignedStimulusData;
    kernelInds = Z.flick.kernelInds;
    nMultiBars = size(stimulusData,2);
    nT = size(expected,1);
    nRoi = size(responseData,2); 
    stcMethod = 1;
    
    switch stcMethod
        case 1
            %% Way 1: pre-subtract expected    
            subtractExp = repmat(responseData(kernelInds,:),[1 1 nMultiBars]) - expected;
            covMat = zeros(maxTau*nMultiBars,maxTau*nMultiBars,nRoi);
            tic;
            for r = 1:nRoi;
                thisVect = zeros(nMultiBars*maxTau,nT-(maxTau-1));
                for s = 1:nMultiBars         
                    for t = maxTau:nT
                        thisVect((s-1)*maxTau+1:s*maxTau,t) = flipud(stimulusData{s}(kernelInds(t-(maxTau-1):t),r) * ...
                            subtractExp(t,r,s))/nT;
                    end
                    fprintf('Bar %i completed! ',s); toc;
                end
                covMat(:,:,r) = thisVect*thisVect';
            end
            
        case 2
            %% Way 2: individually subtract kernel
            kernels = Z.multiPred.kernels;
            covMat = zeros(maxTau*nMultiBars,maxTau*nMultiBars,nRoi);
            repExp = repmat(responseData(kernelInds,:),[1 1 4]);
            tic;
            for r = 1:nRoi;
                thisVect = zeros(4*maxTau,nT-(maxTau-1));
                for s = 1:nMultiBars         
                    for t = maxTau:nT
                        thisVect((s-1)*maxTau+1:s*maxTau,t) = flipud(stimulusData{s}(kernelInds(t-(maxTau-1):t),r)...
                            - kernels{s,r}{1}(:)) * repExp(t,r,s)/nT;
                    end
                    fprintf('Bar %i completed! ',s); toc;
                end
                covMat(:,:,r) = thisVect*thisVect';
            end
    end
    
    %% Visualize
     for r = 1:nRoi
        figure;
        [ vects{r} vals{r} ] = eigs(covMat(:,:,r));
        for s = 1:6        
            for t = 1:nMultiBars
                subplot(7,1,1);
                plot(diag(vals{r})); title('eigenvalues');
                subplot(7,nMultiBars,s*nMultiBars+t); 
                plot(vects{r}((t-1)*maxTau+1:t*maxTau,s)); 
            end
        end
     end
    
    %% How much does this predict
    keyboard
    useEigs = [1:2];
    eigPred = zeros(nT,nRoi);
    for r = 1:nRoi
        for s = 1:nMultiBars
            for t = useEigs
                filters{1} = vects{r}((s-1)*maxTau+1:s*maxTau,t);
                firstInd = s;
                secondInd = mod(s,nMultiBars) + 1;
                eigPred(:,r) = eigPred(:,r) + ...
                    flyResp( [1 0 0],filters,maxTau,stimulusData{firstInd}(kernelInds,r),...
                    stimulusData{secondInd}(kernelInds,r),0 );
            end
        end
        eigpred_ms = eigPred(:,r) - mean(eigPred(:,r));
        resp_ms = responseData(:,r) - mean(responseData(:,r));
        eigpred_r(r) = eigpred_ms'*resp_ms / sqrt( eigpred_ms'*eigpred_ms * ...
            resp_ms'*resp_ms );
    end  
    keyboard
    
end

