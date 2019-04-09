function maxLoc = FitPowerMapMax(xMesh,bootedPowerMaps,polyOrder,numAroundFit,bootedPowerMapsSem)
    % take any number of power maps in the form [y x powerMaps]
    % find the maximums along y for every x in every power map
    % extract maximums for finding the linear max and fitting a polynomial
    % to the numAroundFit points around the linear max. Take the maximum of
    % that polynomial

    if nargin<5
        bootedPowerMapsSem = ones(size(bootedPowerMaps));
    end
    
    % number of powermaps
    numBoot = size(bootedPowerMaps,3);
    
    % number of lambdas
    numLam = size(bootedPowerMaps,2);
    
    numTf = size(bootedPowerMaps,1);
    
    % locations of the maxima, same units as xMesh
    maxLoc = zeros(1,numLam,numBoot);
    
    % resolution at which to evaluate the polynomial
    xRes = 100;
    
    % if xMesh is a vector, make it have the same number of columns as the
    % powermaps
    if size(xMesh,2) == 1
        xMesh = repmat(xMesh,[1 numLam]);
    end
    
    for bb = 1:numBoot
        powerMap = bootedPowerMaps(:,:,bb);
        powerMapSem = bootedPowerMapsSem(:,:,bb);
        
        numStd = 2;
        filtStd = 1;
        w = ((-numStd*filtStd):(numStd*filtStd))';
        wFilt = normpdf(w,0,filtStd);
        
        powerMap = imfilter(powerMap,wFilt);
        powerMapSem = imfilter(powerMapSem,wFilt);
        
        for lam = 1:numLam
            % find the linear maximum
            [~,linMax] = max(powerMap(:,lam));
            
            % take the numAroundFit points around the maximum
            % make sure that the range does not exceed the length of the
            % vector
            fitMin = max([1 linMax-numAroundFit]);
            fitMax = min([numTf linMax+numAroundFit]);
            
            fitRange = fitMin:fitMax;
            
            % fit a polynomial to these points
            coef = polyfitweighted(xMesh(fitRange,lam),powerMap(fitRange,lam),polyOrder,1./powerMapSem(fitRange,lam).^2);

            % defint the x vector along which to evaluate the polynomial
            interpX = linspace(xMesh(fitMin,lam),xMesh(fitMax,lam),xRes);
            
            % evaluate the polynomial
            fittedPolynomial = polyval(coef,interpX);
            
%             MakeFigure;
%             hold on;
%             plot(xMesh(:,lam),powerMap(:,lam));
%             plot(interpX,fittedPolynomial);
%             hold off;
            
            % find its maximum
            [~,maxInd] = max(fittedPolynomial);
            
            % return that maximum
            maxLoc(:,lam,bb) = interpX(maxInd);
        end
    end
end