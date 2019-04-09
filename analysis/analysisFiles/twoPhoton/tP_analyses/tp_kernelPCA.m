function Z = tp_kernelPCA( Z, ROIs, kernels, order )
% Do principal component analysis of extracted kernels, see how principal
% component weighting correlates with direction selectivity. 

    PCuse = [1:50];
    loadFlexibleInputs(Z);
    
    %% Run PCA on kernels
    %% Get Kernels
    if isstr(kernels)
        load(kernels);
        kernels = saveKernels.kernels;
    elseif isstruct(kernels)  
        kernels = saveKernels.kernels;
    elseif ~isnumeric(kernels)
        error('Kernel input is not one of the accepting formats.');
    end
    assert(length(ROIs) == size(kernels,3));
    
    %% Reshape so that all bars from all ROIs are adjacent
    maxTau = round(size(kernels,1) ^ (1/order));
    numBars = size(kernels,2);
    numROIs = size(kernels,3);
    kernels = reshape(kernels,[maxTau^order numBars*numROIs]);
    origIds = repmat(ROIs,[numBars 1]);
    origIds = reshape(origIds,[1 numBars*numROIs]);
    
    %% Preprocessing
    kernels = kernels - repmat(mean(kernels,2),[1 numBars*numROIs]);
%     kernels = kernels - repmat(mean(kernels,1),[maxTau^order 1]);
    kernelNorms = kernels'*kernels;
    kernelNorms = diag(kernelNorms);
    kernels = kernels * diag(kernelNorms)^(-1/2);

    %% SVD
    [ U S V ] = svd(kernels);
    
    %% Visualize top ten PCs and spectrum
    MakeFigure; 
    subplot(5,1,1);
    plot(diag(S));
    title('PC spectrum');
    switch order
        case 1
            for q = 1:20;
                subplot(5,5,5+q);
                plot(U(:,q));
            end
        case 2
            for q = 1:20;
                subplot(5,5,5+q);
                imagesc(reshape(U(:,q),[maxTau maxTau]));
                maxVal = max(abs(U(:,q)));
                set(gca,'Clim',[-maxVal maxVal]);
                colormap(parula);
            end
    end
          
    %% Relate to direction selectivity
    if ~isfield(Z,'eval')
        Z = tp_roiEval( Z );       
    end
    
    [ valsL sortL ] = sort(Z.eval.direction_selectivity(ROIs) .* (Z.eval.direction_selectivity(ROIs) > 0));
    [ valsR sortR ] = sort(-Z.eval.direction_selectivity(ROIs) .* (Z.eval.direction_selectivity(ROIs) < 0));
    
    numlook = 5;
    mostL = ROIs(sortL(end-(numlook-1):end));
    mostLIds = [];
    for q = 1:length(mostL)
        mostLIds = cat(2,mostLIds,find(origIds == mostL(q)));
    end
    mostR = ROIs(sortR(end-(numlook-1):end));
    mostRIds = [];
    for q = 1:length(mostR)
        mostRIds = cat(2,mostRIds,find(origIds == mostR(q)));
    end
    most = [mostL mostR];
    mostIDs = [mostLIds mostRIds];
    
    figure;
    subplot(1,2,1); imagesc(V(1:100,fliplr(mostLIds))); title('mostL');
    ylabel('PC'); xlabel('ROI rank');
    subplot(1,2,2); imagesc(V(1:100,fliplr(mostRIds))); title('mostR');  
    ylabel('PC'); xlabel('ROI rank');
    
    %% view all kernels in pc 2-10
    colormap_gen;
    subplotWd = ceil(sqrt(numBars*2));
    subplotWd = subplotWd + mod(subplotWd,2);
    subplotHt = ceil(2*numBars/subplotWd);
    projKernels = U(:,PCuse)*S(PCuse,PCuse)*V(PCuse,:);
    for qp = most
        q = find(ROIs == qp);
        MakeFigure;
        suptitle(['ROI ' num2str(q)]);
        maxPCA = max(max(abs(projKernels(:,numBars*(q-1)+1:numBars*q))));
        maxKer = max(max(abs(kernels(:,numBars*(q-1)+1:numBars*q))));
        meanThisRoi = mean(kernels(:,numBars*(q-1)+1:numBars*q),2);
        maxMean = max(abs(meanThisRoi));
        meanProjThisRoi = mean(projKernels(:,numBars*(q-1)+1:numBars*q),2);
        maxMeanProj = max(abs(meanProjThisRoi));
        for r = 1:numBars
            subplot(subplotHt,subplotWd,2*(r-1)+1);
            thisProj = reshape(projKernels(:,(numBars*(q-1))+r),[maxTau maxTau]);
            imagesc(thisProj);
            set(gca,'Clim',[-maxPCA maxPCA]);
            title(['PC bar ' num2str(r)]);
            subplot(subplotHt,subplotWd,2*r);
            imagesc(reshape(kernels(:,(numBars*(q-1))+r),[maxTau maxTau]));
            hold all; plot([1:maxTau],[1:maxTau],'k');
            title(['Original bar ' num2str(r)]);
            set(gca,'Clim',[-maxKer maxKer]);
            colormap(mymap);
        end
        figure; 
        subplot(1,2,1); imagesc(reshape(meanThisRoi,[60 60]));
        set(gca,'Clim',[-maxMean maxMean]); title('mean');
        subplot(1,2,2); imagesc(reshape(meanProjThisRoi,[60 60]));
        set(gca,'Clim',[-maxMeanProj maxMeanProj]); title('mean proj');
        colormap(mymap);
    end
    
    Z.kPCA.projKernels = projKernels;
    Z.kPCA.U = U;
    Z.kPCA.S = S;
    Z.kPCA.V = V;
    
end

