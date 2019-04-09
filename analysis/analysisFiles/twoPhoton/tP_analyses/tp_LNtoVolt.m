function Z = tp_LNtoVolt( Z )
% Extract first two volterra kernels based on LN model extracted

    %% Load LN model
    lnNames = fieldnames(Z.LN);
    for ii = 1:length(lnNames)
        eval([lnNames{ii} '= Z.LN.' lnNames{ii} ';']);
    end      
    nRoi = size(kernels,3);
    nMultiBars = size(kernels,2);
    maxTau = size(kernels,1);
    
    %% Create test data    
    tDur = 1e5;
    dist = 2;
    inVar = 1;
    linPred = zeros(tDur,nRoi);   
    for r = 1:nRoi
        for q = 1:nMultiBars
            stim(:,q,r) = randInput(inVar,dist,tDur);
        end
        for q = 1:nMultiBars
            firstInd = q;
            secondInd = mod(q,nMultiBars) + 1;
            tempFilters{1} = kernels(:,q,r);
            linPred(:,r) = linPred(:,r) + flyResp([1 0 0],tempFilters,maxTau,...
                stim(:,firstInd,r),stim(:,secondInd,r));
        end
        % automatically rescale predicted response to match range of
        % nonlinearity
        lowerNL = min(Z.LN.nl.mids(:,r));
        upperNL = max(Z.LN.nl.mids(:,r));
        nlAxis(:,r) = linspace(lowerNL,upperNL,100);
        minLimNL = min ( abs(lowerNL), abs(upperNL) );
        lowerPred = max(abs(linPred(:,r)));
        pred(:,r) = linPred(:,r) * minLimNL / lowerPred;
        pred(:,r) = nonlinearity(pred(:,r),r,nl);
    end
%     pred = (100*pred) .^ 10;
%     pred = pred .* (pred > 0);
    
    %% Extract Kernels    
    re1 = zeros(maxTau,nMultiBars,nRoi);
    re2 = zeros(maxTau^2,nMultiBars,nRoi);
    for q = 1:nMultiBars
        firstInd = q;
        secondInd = mod(q,nMultiBars) + 1;
        for r = 1:nRoi
            re1(:,q,r) = oneD_filter(stim(:,firstInd,r),pred(:,r),maxTau);
            re2(:,q,r) = twod_fast(maxTau,inVar,stim(:,firstInd,r),...
                stim(:,secondInd,r),pred(:,r),r);
        end
    end    
    for r = 1:nRoi
        figure;
        subplot(4,2,1);
        imagesc(kernels(:,:,r)); title('Original Filters');
        subplot(4,2,2);
        imagesc(re1(:,:,r)); title('Extracted Filters');
        subplot(4,1,2);
        plot(nlAxis(:,r),nonlinearity(nlAxis(:,r),r,nl));
        title('nonlinearity');
        subplot(4,1,3);
        hist(linPred(:,r),20); 
        title('filtered stimulus (pre-nonlinearity)  distribution');
        for q = 1:nMultiBars
            subplot(4,4,12+q);
            imagesc(reshape(re2(:,q,r),[maxTau maxTau]));
        end       
        figure; imagesc(reshape(mean(re2(:,:,r),2),[maxTau maxTau]));
    end   
keyboard
end

