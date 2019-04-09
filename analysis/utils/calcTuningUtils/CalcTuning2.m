function CalcTuning(TW,varargin)
    ColorMapGen; % this generates a color map that goes from blue to white to red

    runPTest = 1;
    
    % RT is a variable that determines whether the corresponding map is
    % turning or walking data. If this array is too small, assume the data
    % is for walking
    if length(TW) < length(varargin)
        sizeDiff = length(varargin)-length(TW);
        TW = [TW ones(1,sizeDiff)*2];
    end
    
    numMaps = length(varargin); % the number of power maps to deal with
    
    powerMap = cell(numMaps,1); % cell array to hold all the power maps
    powerMapSem = cell(numMaps,1); % cell array to hold all the SEM of the power maps
    powerMapInd = cell(numMaps,1); % cell array that holds each individual fly's response to a given SF {inputs}{SF} [TF,flies]
    
    numFlies = cell(numMaps,1); % number of flies for each SF in each powermap
    tf = cell(numMaps,1); % TFs measured for each power map
    tfLog = cell(numMaps,1);
    numTf = zeros(numMaps,1);
    
    lambda = cell(numMaps,1); % lambdas measured for each power map
    sf = cell(numMaps,1); % 1/lambda
    sfLog = cell(numMaps,1);
    numLam = zeros(numMaps,1);
    
    vel = cell(numMaps,1);
    velLog = cell(numMaps,1);
    numVel = zeros(numMaps,1);
    
    lambdaMesh = cell(numMaps,1);
    
    sfMeshLog = cell(numMaps,1);
    tfMeshLog = cell(numMaps,1);
    
    velMesh = cell(numMaps,1);
    velMeshLog = cell(numMaps,1);
    
    %% pull powerMap information out of varargin/structure format
    for mm = 1:numMaps
        powerMap{mm} = varargin{mm}.powerMap(:,:,TW(mm));
        powerMapSem{mm} = varargin{mm}.powerMapSem(:,:,TW(mm));
        
        powerMapInd{mm} = cell(length(varargin{mm}.powerMapInd),1);
        for ii = 1:length(varargin{mm}.powerMapInd)
            powerMapInd{mm}{ii} = varargin{mm}.powerMapInd{ii}(:,:,TW(mm));
        end
        
        % count the number of flies in each powermap
        numFlies{mm} = zeros(1,size(powerMapInd{mm},1));
        for lam = 1:size(powerMapInd{mm},1)
            numFlies{mm}(lam) = size(powerMapInd{mm}{lam},2);
        end
        
        lambda{mm} = varargin{mm}.lambda;
        sf{mm} = 1./lambda{mm};
        sfLog{mm} = log(sf{mm});
        numLam(mm) = size(lambda{mm},2);
        
        tf{mm} = varargin{mm}.tf;
        tfLog{mm} = log(tf{mm});
        numTf(mm) = size(tf{mm},1);
        
        velMesh{mm} = tf{mm}*lambda{mm};
        vel{mm} = [flipud(velMesh{mm}(1,:)'); velMesh{mm}(:,1)];
        vel{mm}(numLam(mm)) = [];
        velLog{mm} = log(vel{mm});
        numVel(mm) = length(vel{mm});
        
        lambdaMesh{mm} = repmat(lambda{mm},[numTf(mm) 1]);
        sfMeshLog{mm} = repmat(sfLog{mm},[numTf(mm) 1]);
        tfMeshLog{mm} = repmat(tfLog{mm},[1 numLam(mm)]);
        velMeshLog{mm} = log(velMesh{mm});
    end
    
    % map limits of the form [minTurn minWalk; maxTurn maxWalk];
    % just set the max min values to a very high / very low value that will
    % be overwritten
    tempMaxPlaceholder = 5000;
    mapLimits = [tempMaxPlaceholder tempMaxPlaceholder; -tempMaxPlaceholder -tempMaxPlaceholder];
    
    mapCenterValue = [0 1]; % center maps around 0 for turning and 1 for walking
        
    for mm = 1:numMaps
        %% set the maximum and minimum values of the power maps.
        % map limits is [turnMin walkMin; turnMax walkMax]
        
        % this gets the max / min values of the current power map. Compare
        % against the error added and subtracted matricies make sure it the limits
        % dont cut off errrobars
        tempMin = min(min([powerMap{mm}+powerMapSem{mm} powerMap{mm}-powerMapSem{mm}]));
        tempMax = max(max([powerMap{mm}+powerMapSem{mm} powerMap{mm}-powerMapSem{mm}]));
        
        if  tempMin < mapLimits(1,TW(mm))
            mapLimits(1,TW(mm)) = tempMin;
        end
        
        if  tempMax > mapLimits(2,TW(mm))
            mapLimits(2,TW(mm)) = tempMax;
        end
    end
    
    % round the mapLimits to give them wiggle room
    mapLimits(1,:) = floor(mapLimits(1,:)*10)/10;
    mapLimits(2,:) = ceil(mapLimits(2,:)*10)/10;
    
    % set the centered limits to center around mapCenterValue
    absLimits = max(abs(bsxfun(@minus,mapLimits,mapCenterValue)));
    mapLimitsCentered = bsxfun(@plus,[-absLimits; absLimits],mapCenterValue);
        
    %% initialize a cell array for figure legends
    figLeg = cell(nargin-1,1);
    for lam = 1:nargin-1
        figLeg{lam} = inputname(lam+1);
    end
    
    
    %% plot lambda vs TF and vs Vel
    % plot each powermap as a heatmap with lambda vs tf and lambda vs
    % velocity
    
    interpRes = 1; % number of times to interpolate between data points
    
    % interpolate the data and sample it evenly on a log-linear scale.
    % Currently the data is sampled approximately on a sqrt(2)^n scale but
    % not exactly
    
    % the following variables are after interpolation
    
    % sf, tf, and vel vectors after interpolation
    sfLogInt = cell(numMaps,1);
    tfLogInt = cell(numMaps,1);
    velLogInt = cell(numMaps,1);
    
    powerMapTfInt = cell(numMaps,1);
    powerMapVelInt = cell(numMaps,1);
    
    sfLogIntMesh_Tf = cell(numMaps,1);
    tfLogIntMesh_Tf = cell(numMaps,1);
    sfLogIntMesh_Vel = cell(numMaps,1);
    velLogIntMesh_Vel = cell(numMaps,1);
    
    for mm = 1:numMaps
        % set up the DESIRED x and y coordinates for the power map. These
        % are the coordinates that will be used after linear interpolation
        
        % exponentially interpolate between min and max vel
        sfLogInt{mm} = linspace(sfLog{mm}(1),sfLog{mm}(end),interpRes*numLam(mm)); % upsampled SF for interpolation (samples exponentially)
        tfLogInt{mm} = linspace(tfLog{mm}(1),tfLog{mm}(end),interpRes*numTf(mm))'; % upsampled TF for interpolation (samples exponentially)
        velLogInt{mm} = linspace(velLog{mm}(1),velLog{mm}(end),interpRes*numVel(mm))'; % upsampled velocities (samples exponentially)
        
        % mesh grid of TF x and y, and Vel x and y
        [sfLogIntMesh_Tf{mm},tfLogIntMesh_Tf{mm}] = meshgrid(sfLogInt{mm},tfLogInt{mm});
        [sfLogIntMesh_Vel{mm},velLogIntMesh_Vel{mm}] = meshgrid(sfLogInt{mm},velLogInt{mm});
        
        % linearly interpolate the data so its on a strict log(2) scale
        powerMapTfInt{mm} = scatteredInterpolant(sfMeshLog{mm}(:),tfMeshLog{mm}(:),powerMap{mm}(:),'linear','none');
        powerMapVelInt{mm} = scatteredInterpolant(sfMeshLog{mm}(:),velMeshLog{mm}(:),powerMap{mm}(:),'linear','none');
        
        powerMapTfInt{mm} = powerMapTfInt{mm}(sfLogIntMesh_Tf{mm},tfLogIntMesh_Tf{mm});
        powerMapVelInt{mm} = powerMapVelInt{mm}(sfLogIntMesh_Vel{mm},velLogIntMesh_Vel{mm}); 
    end
    
    numBootstrap = 1000;
    planeCoef = cell(numMaps,1);
    planeError = cell(numMaps,1);
    
    planeAngle = cell(numMaps,1);
    planeVector = cell(numMaps,1);
    
    meanPlaneVector = cell(numMaps,1);
    meanResultant = cell(numMaps,1);
    meanAngle = cell(numMaps,1);
    
    powerMapIndFit = cell(numMaps,1);
    
    %% calculate relative velocity tuning vs tf tuning
    for mm = 1:numMaps
        % convert walking speed to slowing index which gets bigger the more
        % the flies slow
        powerMapIndFit{mm} = cell(numLam(mm),1);
        
        for pp = 1:length(powerMapIndFit{mm})
            if TW(mm) == 2
                powerMapIndFit{mm}{pp} = 1-powerMapInd{mm}{pp};
            else
                powerMapIndFit{mm}{pp} = powerMapInd{mm}{pp};
            end
        end
    
        %% bootstrap flies to create different powermaps and measure their angle
        planeCoef{mm} = MattBootstrap(@(varsToResample)FitPlaneToPowermap(sfMeshLog{mm},tfMeshLog{mm},varsToResample),numBootstrap,powerMapIndFit{mm});
        
        percentNan = 100*sum(any(isnan(planeCoef{mm}))/numBootstrap);
        disp([num2str(percentNan) '% of bootstraps returned nan for ' figLeg{mm} ' angle measurement']);
        
        planeCoef{mm} = squish(planeCoef{mm});
        
        %% calculate average plane angle from plane Coef
        planeAngle{mm} = atan2(planeCoef{mm}(3,:),planeCoef{mm}(2,:))';
        
        planeAngle{mm} = planeAngle{mm}(~isnan(planeAngle{mm}));
        
        % convert the angle into a unit vector
        planeVector{mm} = exp(planeAngle{mm}*1i);
        
        % find the mean vector
        meanPlaneVector{mm} = nanmean(planeVector{mm});
        
        % find the mean vector length
        meanResultant{mm} = abs(meanPlaneVector{mm});
        
        % find the mean angle
        meanAngle{mm} = atan2(imag(meanPlaneVector{mm}),real(meanPlaneVector{mm}));
    end
    
    %% calculate significance
    
    chiSquaredTf = cell(numMaps,1);
    chiSquaredVel = cell(numMaps,1);
    
    numPerms = 10000;
    
    % compare velocity tuning fit to TF tuning fit
    for mm = 1:numMaps
        [~,chiSquaredTf{mm}] = MattBootstrap(@(varsToResample)FitPlaneToPowermap(sfMeshLog{mm},tfMeshLog{mm},varsToResample,[1 0 1]),numBootstrap,powerMapIndFit{mm});
        [~,chiSquaredVel{mm}] = MattBootstrap(@(varsToResample)FitPlaneToPowermap(sfMeshLog{mm},velMeshLog{mm},varsToResample,[1 0 1]),numBootstrap,powerMapIndFit{mm});
        
        percentNan = 100*sum(isnan(chiSquaredTf{mm})/numBootstrap);
        disp([num2str(percentNan) '% of bootstraps returned nan for ' figLeg{mm} 'Tf vs Vel']);
        
        p = MattPermutationTest(chiSquaredTf{mm},chiSquaredVel{mm},numPerms);
        
        if mean(chiSquaredTf{mm}) < mean(chiSquaredVel{mm})
            disp([figLeg{mm} ' is TF tuned with p value ' num2str(p)]);
        else
            disp([figLeg{mm} ' is Velocity tuned with p value ' num2str(p)]);
        end
        
        MakeFigure;
        hist([chiSquaredTf{mm}(:) chiSquaredVel{mm}(:)],100);
        legend({'TF' 'Vel'});
    end
    
    
    % calculate significant mean angle change between each of the maps
    % provided
    
    % make this a square matrix for convenience but only the top triangle
    % will be filled out
    
    pValue = eye(numMaps);
    
    if runPTest
        for aa = 1:numMaps-1
            for bb = aa+1:numMaps
                % choose the smallest n as the n for the test
                nA = min(numFlies{aa});
                nB = min(numFlies{bb});
                
                rA = nA*meanResultant{aa};
                rB = nB*meanResultant{bb};
                
                N = nA + nB;
                
                rw = (rA + rB)/N;
                
                checkAssumption(rw,N/2)

                % find the mean vector
                meanPlaneVectorComb = mean([planeVector{aa}; planeVector{bb}]);

                % find the mean vector length
                meanResultantComb = abs(meanPlaneVectorComb);
                
                R = N*meanResultantComb;

                %% calculate the p value
                % the code to calculate the correction factor K is taken
                % from
                % http://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox--directional-statistics-/content/circ_wwtest.m
                kk = circ_kappa(rw);
                K = 1+3/(8*kk);    % correction factor
                
                F = K*((N-2)*(rA + rB - R)/(N - rA - rB));
                
                pValue(aa,bb) = 1-fcdf(F,1,N-2);
                pValue(bb,aa) = 1-fcdf(F,1,N-2);
            end
        end
    end
    
    %% plotting
    disp(pValue);
    MakeFigure;
    
    for mm = 1:numMaps
        circ_plot(planeAngle{mm},'hist',[],100,true,false,'linewidth',2,'color','r');
        hold on;
    end
    ConfAxis('figLeg',figLeg);
    hold off;
    
    MakeFigure;
    hist(180/pi*cat(2,planeAngle{1:end}),100);

    
    for mm = 1:numMaps
        %% values of lambda,sf,tf, and vel to display on the graphs
        numToPlot = numLam(mm);
        plotLam = round(1./exp(sfLogInt{mm}(round(linspace(1,end,numToPlot))))*10)/10;
        plotTf = round(exp(tfLogInt{mm}(round(linspace(1,end,numToPlot))))*10)/10;
        plotVel = round(exp(velLogInt{mm}(round(linspace(1,end,numToPlot))))*10)/10;
        
        %% plot power maps
        MakeFigure;

        % number of contours to plot for each powermap
        numContours = 20;
        contours = linspace(mapLimitsCentered(1,TW(mm)),mapLimitsCentered(2,TW(mm)),numContours);
        axisLimits = [contours(1) contours(end)];

        % plot sf vs tf
        subplot(1,2,1);

        hold on;
        imagesc(sfLogInt{mm},tfLogInt{mm},powerMapTfInt{mm});
        contour(sfLogInt{mm},tfLogInt{mm},powerMapTfInt{mm},contours,'k');
        colorbar;
        hold off;

        ConfAxis('tickX',log(1./plotLam),'tickLabelX',plotLam,'tickY',log(plotTf),'tickLabelY',plotTf,'fTitle',figLeg{mm});
        xlabel({'lambda (deg)' ['n = ' num2str(numFlies{mm})]});
        ylabel('TF (Hz)')
        caxis(axisLimits);

        % plot sf vs vel
        subplot(1,2,2);

        hold on;
        imagesc(sfLogInt{mm},velLogInt{mm},powerMapVelInt{mm});
        contour(sfLogInt{mm},velLogInt{mm},powerMapVelInt{mm},contours,'k');
        colorbar;
        hold off;

        ConfAxis('tickX',log(1./plotLam),'tickLabelX',plotLam,'tickY',log(plotVel),'tickLabelY',plotVel);
        xlabel('lambda (deg)');
        ylabel('velocity (deg/sec)')
        caxis(axisLimits);

        colormap(mymap);
        
        
        %% plot traces overlayed
        switch TW(mm)
            case 1
                units = '(deg/s)';
            case 2
                units = '(fold change)';
        end
        
        MakeFigure;
        
        % tf vs slowing
        subplot(1,2,1);
        PlotXvsY(tfLog{mm},powerMap{mm},'error',powerMapSem{mm});
        
        legend(cellfun(@num2str,num2cell(lambda{mm}),'UniformOutput',0));
        ConfAxis('tickX',log(plotTf),'tickLabelX',plotTf,'fTitle',figLeg{mm});
        ylim(mapLimits(:,TW(mm)));
        xlabel({'temporal frequency (Hz)' ['n = ' num2str(numFlies{mm})]});
        ylabel(['fly response ' units]);
        
        % vel vs slowing
        subplot(1,2,2);
        PlotXvsY(velMeshLog{mm},powerMap{mm},'error',powerMapSem{mm});
        
        ConfAxis('tickX',log(plotVel),'tickLabelX',plotVel);
        ylim(mapLimits(:,TW(mm)));
        xlabel('velocity (deg/sec)');
        ylabel(['fly response ' units]);
        
%         MakeFigure;
%         hold on;
%         bar([1 2],[averageTfR2(mm) averageVelR2(mm)]);
%         h=PlotErrBars([1 2],[averageTfR2(mm) averageVelR2(mm)],[],[averageTfR2Sem(mm) averageVelR2Sem(mm)],'.');
%         set(h,'color','k');
%         ylabel('R squared for plane fit');
%         xlabel({'TF model','vel model'});
%         hold off;
%         ConfAxis;
%         
%         MakeFigure;
%         hist([tfR2(:,mm) velR2(:,mm)],numBootstrap/4);
    end
% 
%     tfVelTuningY = [135 90; 135 90];
%     tfVelTuningX = [0.5 0.5; numMaps+0.5 numMaps+0.5];
%     CIplot = {planeAngleCI(:,1)+planeAngle,planeAngleCI(:,2)+planeAngle};
%     MakeFigure;
%     hold on;
%     bar(planeAngle);
%     h=PlotErrBars((1:numMaps)',planeAngle,[],CIplot,'.');
%     set(h,'color','k');
%     h=plot(tfVelTuningX,tfVelTuningY,'--');
%     legend(h,{'Vel tuning','TF tuning'});
%     ylabel('average angle of best plane fit for powermap');
%     xlabel(figLeg');
%     hold off;
%     ConfAxis;
end



%% this code is borrowed from the circular statistics toolbox where they
% implement the same watson  an williams parametric test
% http://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox--directional-statistics-/content/circ_wwtest.m
function checkAssumption(rw,n)

  if n >= 11 && rw<.45
    warning('Test not applicable. Average resultant vector length < 0.45.') %#ok<WNTAG>
  elseif n<11 && n>=7 && rw<.5
    warning('Test not applicable. Average number of samples per population 6 < x < 11 and average resultant vector length < 0.5.') %#ok<WNTAG>
  elseif n>=5 && n<7 && rw<.55
    warning('Test not applicable. Average number of samples per population 4 < x < 7 and average resultant vector length < 0.55.') %#ok<WNTAG>
  elseif n < 5
    warning('Test not applicable. Average number of samples per population < 5.') %#ok<WNTAG>
  end

end