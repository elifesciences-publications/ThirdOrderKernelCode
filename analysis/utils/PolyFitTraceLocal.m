turnMax = zeros(numSep,1);
walkMin = zeros(numSep,1);
turnMaxSEM = zeros(numSep,1);
walkMinSEM = zeros(numSep,1);

turnScale = zeros(numSep,1);
walkScale = zeros(numSep,1);
turnScaleSEM = zeros(numSep,1);
walkScaleSEM = zeros(numSep,1);

bootMax = zeros(numBoot,numSep,2);
bootScale = zeros(numBoot,numSep,2);

traceFit = zeros(fitLength,numSep,2);
traceSEM = zeros(fitLength,numSep,2);

dataFit = repmat(dataX,[1 size(indTraces,2)]);
fitX = zeros(fitLength,numSep,2);

%% bootstrap the data
for ii = 1:numSep
    for tt = 1:2 % do both walk and turn
        
        % provide the bootstrap algo with what to run - calcPolyMax
        % it will select from rows of indTraces(:,:,tt,ii)' with
        % replacement provide them to calcPolyMax where calc will then fit
        % a polynomial around the hard maximum and return the maximum of
        % the polynomial
        
        boot = bootstrp(numBoot,@(x) calcPolyMax(x,tt==1,polyOrder,dataFit',fitLength,logScale,numAroundFit),indTraces(:,:,tt,ii)');
        bootMax(:,ii,tt) = boot(:,1);
        bootScale(:,ii,tt) = boot(:,2);
        
        if tt==1
            [~,maxLoc] = max(mean(indTraces(:,:,tt,ii),2));
        else
            [~,maxLoc] = min(mean(indTraces(:,:,tt,ii),2));
        end
        
        maxStart = max([maxLoc-numAroundFit,1]);
        maxEnd = min([maxLoc+numAroundFit+(maxStart-(maxLoc-numAroundFit)),size(indTraces,1)]);
        maxStart = max([maxLoc-numAroundFit+(maxEnd-(maxLoc+numAroundFit)),1]);
        
        pointsToFit = maxStart:maxEnd;
        polyDataX = repmat(dataX(pointsToFit),[1 size(indTraces,2)]);
        fitX(:,ii,tt) = linspace(dataX(maxStart),dataX(maxEnd),fitLength)';
        
        % plot out the representive polyfit for visualization
        [coefFit,S] = polyfit(polyDataX,indTraces(pointsToFit,:,tt,ii),polyOrder);
        [traceFit(:,ii,tt),traceSEM(:,ii,tt)] = polyval(coefFit,fitX(:,ii,tt),S);
        
        if tt == 1
            [turnScale(ii),turnMaxLoc] = max(traceFit(:,ii,tt));
            
            turnMax(ii) = fitX(turnMaxLoc,ii,tt);
            if logScale
                turnMax(ii) = exp(turnMax(ii));
            end
        else
            [walkScale(ii),walkMinLoc] = min(traceFit(:,ii,tt));
            
            walkMin(ii) = fitX(walkMinLoc,ii,tt);
            if logScale
                walkMin(ii) = exp(walkMin(ii));
            end
        end
    end

    turnMaxSEM(ii) = std(bootMax(:,ii,1));
    turnScaleSEM(ii) = std(bootScale(:,ii,1));
    walkMinSEM(ii) = std(bootMax(:,ii,2));
    walkScaleSEM(ii) = std(bootScale(:,ii,2));
end

D.analysis.polyFit.traceFit = traceFit;
D.analysis.polyFit.traceSEM = traceSEM;

%D.analysis.polyFit.bootMax = bootMax;
%D.analysis.polyFit.bootScale = bootScale;

D.analysis.polyFit.turnMax = turnMax;
D.analysis.polyFit.walkMin = walkMin;
D.analysis.polyFit.turnMaxSEM = turnMaxSEM;
D.analysis.polyFit.walkMinSEM = walkMinSEM;

D.analysis.polyFit.turnScale = turnScale;
D.analysis.polyFit.walkScale = walkScale;
D.analysis.polyFit.turnScaleSEM = turnScaleSEM;
D.analysis.polyFit.walkScaleSEM = walkScaleSEM;
