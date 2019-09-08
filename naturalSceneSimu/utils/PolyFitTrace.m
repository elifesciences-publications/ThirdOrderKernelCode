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

fitX = linspace(dataX(1),dataX(end),fitLength)';

for ii = 1:numSep
    for tt = 1:2 % do both walk and turn
        dataXin = repmat(dataX',[size(indTraces(:,:,tt,ii)',1) 1]);
        boot = bootstrp(numBoot,@calcPolyMax,indTraces(:,:,tt,ii)',tt==1,polyOrder,dataXin,fitLength,logScale);
        bootMax(:,ii,tt) = boot(:,1);
        bootScale(:,ii,tt) = boot(:,2);
        
        % plot out the representive polyfit for visualization
        [coefFit,S] = polyfit(dataXin',indTraces(:,:,tt,ii),polyOrder);
        [traceFit(:,ii,tt),traceSEM(:,ii,tt)] = polyval(coefFit,fitX,S);
    end

    turnMax(ii) = mean(bootMax(:,ii,1));
    turnMaxSEM(ii) = std(bootMax(:,ii,1));

    turnScale(ii) = mean(bootScale(:,ii,1));
    turnScaleSEM(ii) = std(bootScale(:,ii,1));

    walkMin(ii) = mean(bootMax(:,ii,2));
    walkMinSEM(ii) = std(bootMax(:,ii,2));

    walkScale(ii) = mean(bootScale(:,ii,2));
    walkScaleSEM(ii) = std(bootScale(:,ii,2));
end

D.analysis.polyFit.traceFit = traceFit;
D.analysis.polyFit.traceSEM = traceSEM;

D.analysis.polyFit.bootMax = bootMax;
D.analysis.polyFit.bootScale = bootScale;

D.analysis.polyFit.turnMax = turnMax;
D.analysis.polyFit.walkMin = walkMin;
D.analysis.polyFit.turnMaxSEM = turnMaxSEM;
D.analysis.polyFit.walkMinSEM = walkMinSEM;

D.analysis.polyFit.turnScale = turnScale;
D.analysis.polyFit.walkScale = walkScale;
D.analysis.polyFit.turnScaleSEM = turnScaleSEM;
D.analysis.polyFit.walkScaleSEM = walkScaleSEM;
