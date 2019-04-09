function [planeCoef,rmse] = FitPlaneToPowerMap(xMesh,yMesh,bootedPowerMaps,bootedPowerMapsSem,maxLoc,toFit)
    % each powerMapInd should be a fly's response measured at a single spatial
    % frequency such that it is a matrix where each row is a temporal
    % frequency and each column is a different fly.
    polyOrder = 3;
    numAroundFit = 6;
    
    if nargin<6
        toFit = true(1,3);
    end
    
    if nargin<5
        maxLoc = [];
    end
    
    toFit = logical(toFit);
    
    numParams = sum(toFit);
    numBoot = size(bootedPowerMaps,3);
    
    planeCoef = zeros(numParams,1,numBoot);
    rmse = zeros(1,1,numBoot);
    
    for bb = 1:numBoot;
        powerMap = bootedPowerMaps(:,:,bb);
        
        if isempty(bootedPowerMapsSem)
            powerMapSem = ones(size(bootedPowerMaps(:,:,bb)));
        else
            powerMapSem = bootedPowerMapsSem(:,:,bb);
        end
        
        if any(any(powerMapSem==0))
            planeCoef(:,:,bb) = nan(sum(toFit),1);
            rmse(:,:,bb) = nan;
            continue;
        end
    
        % powerMapMask will get rid of all responses at TFs greater than the
        % maximum TF response at that lambda
        powerMapMask = true(size(powerMap));

        %% get max loc
        
        if isempty(maxLoc)
            [~,maxLoc] = max(powerMap);
        end
        
        for lam = 1:size(powerMap,2);
            powerMapMask(maxLoc(lam)+1:end,lam) = false;
        end
        
%         MakeFigure;
%         subplot(1,2,1);
%         imagesc(flipud(powerMap));
%         subplot(1,2,2);
%         imagesc(flipud(powerMapMask));
%         keyboard;
        

        %% convert from matricies to arrays for fitting
        powerMapMaskLin = powerMapMask(:);
        powerMapLin = powerMap(:);
        powerMapSemLin = powerMapSem(:);
        xVals = xMesh(:);
        yVals = yMesh(:);

        % remove nans
        powerMapLin = powerMapLin(powerMapMaskLin);
        powerMapSemLin = powerMapSemLin(powerMapMaskLin);
        xVals = xVals(powerMapMaskLin);
        yVals = yVals(powerMapMaskLin);

        % create an array of ones for fitting the plane offset
        constVals = ones(size(yVals));

        % fit mat is const + x + y
        fitMat = [constVals xVals yVals];

        % choose which terms to fit on
        fitMat = fitMat(:,toFit);

        % fit the plane
        planeCoef(:,:,bb) = lscov(fitMat,powerMapLin,1./(powerMapSemLin.^2));

        % calculate residuals
        rmse(:,:,bb) = sqrt(mean((fitMat*planeCoef(:,:,bb) - powerMapLin).^2));
    end
end