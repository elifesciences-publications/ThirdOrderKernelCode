function [figHand,powerMapIntTf,powerMapIntVel,sfIntMesh,tfIntMesh,velIntMesh,pTfVsVelSvd,bootedPowerMapsTfAveVector] = CalcTuning(twIn,varargin)
    %% make a legend from the names of the input maps
    inLeg = cell(1,nargin-1);
    for lam = 1:nargin-1
        inLeg{lam} = inputname(lam+1);
    end
    
    inputMaps = [];
    figLeg = [];
    tw = [];
    
    % tw is a variable that determines whether the corresponding map is
    % turning or walking data. If this array is too small, assume the data
    % is for walking
    twCell = cell(length(varargin),1);
    twCell = cellfun(@(x){2},twCell); % initialize cell array to assume walking data
    
    for in = 1:length(twIn)
        twCell{in} = twIn(in);
    end
    
    %% first things first, seperate any map inputs that have more than one trace
    for nn = 1:length(varargin)
        numTraces = size(varargin{nn}.powerMap,4);
        newLeg = cell(1,numTraces);
        newMaps = cell(1,numTraces);
        newTw = cell(numTraces,1);
        
        for ss = 1:numTraces
            newLeg{ss} = inLeg{nn};
            newTw{ss} = twCell{nn};
            % set new map (the extra traces) to old map to duplicate all the meta data
            newMaps{ss} = varargin{nn};
            newMaps{ss}.powerMap = newMaps{ss}.powerMap(:,:,:,ss);
            newMaps{ss}.powerMapSem = newMaps{ss}.powerMapSem(:,:,:,ss);
            for ff = 1:length(newMaps{ss}.powerMapInd)
                newMaps{ss}.powerMapInd{ff} = newMaps{ss}.powerMapInd{ff}(:,:,:,ss);
            end
        end
        
        inputMaps = [inputMaps newMaps];
        figLeg = [figLeg newLeg];
        tw = [tw; newTw];
    end
    
    
    numMaps = length(inputMaps); % the number of power maps to deal with
    
    
    plotFigs = varargin{1}.plotFigs;
    figHand = cell(numMaps,1);
    
    
    
    
    %% initialize powerMap variables
    powerMap = cell(numMaps,1); % cell array to hold all the power maps
    powerMapSem = cell(numMaps,1); % cell array to hold all the SEM of the power maps
    powerMapInd = cell(numMaps,1); % cell array that holds each individual fly's response to a given SF {inputs}{SF} [TF,flies]
    
    numFlies = cell(numMaps,1); % number of flies for each SF in each powerMap
    numTotalFlies = cell(numMaps,1);
    
    %% initialization of lambda, sf, tf, and velocity variables
    % vector variables of the lambda, sf, tf, and vel
    tf = cell(numMaps,1); % TFs measured for each power map
    tfLog = cell(numMaps,1);
    numTf = cell(numMaps,1); % number of TFs for map
    
    lambda = cell(numMaps,1); % lambdas measured for each power map
    sf = cell(numMaps,1); % 1/lambda
    sfLog = cell(numMaps,1); 
    
    numLam = cell(numMaps,1); % number of lambdas for map
    
    vel = cell(numMaps,1); % velocities measured for each map
    velLog = cell(numMaps,1);
    numVel = cell(numMaps,1); % number of velocities for each map
    
    % mesh variables of lambda, sf, tf, and vel
    % mesh variables are a matrix that gives the value at every single
    % point in the matrix.
    lambdaMesh = cell(numMaps,1);
    sfMeshLog = cell(numMaps,1);
    tfMeshLog = cell(numMaps,1);
    
    sfIntMesh = cell(numMaps,1);
    tfIntMesh = cell(numMaps,1);
    velIntMesh = cell(numMaps,1);
    
    velMesh = cell(numMaps,1);
    velMeshLog = cell(numMaps,1);
    
    %% interpolated powerMaps
    powerMapIntTf = cell(numMaps,1);
    powerMapIntVel = cell(numMaps,1);
    
    %% plane angle data    
    planeAngle = cell(numMaps,1);
    planeVector = cell(numMaps,1);
    planeAngleAve = cell(numMaps,1);
    
    %% Tf vs Vel tuning
    rmseTf = cell(numMaps,1);
    rmseVel = cell(numMaps,1);
    
    pTfVsVelRmse = cell(numMaps,1);
    diffRmse = cell(numMaps,1);
    
    rmseTf = cell(numMaps,1);
    rmseVel = cell(numMaps,1);
    
    pTfVsVelRmse = cell(numMaps,1);
    diffRmse = cell(numMaps,1);
    %% number of bootstraps to do
    numBootstrap = 1000;
    
    %% number of permutations to do for p testing
    numPerm = 10000;
    
    %% n to use for statistical testing
    n = cell(numMaps,1);
    
    %% values for max fitting
    polyOrder = 4;
    numAroundFit = 5;
    
    tfMax = cell(numMaps,1);
    velMax = cell(numMaps,1);
    sfMax = cell(numMaps,1);
    
    tfMaxSem = cell(numMaps,1);
    velMaxSem = cell(numMaps,1);
    
    pTfMaxVsVelMax = cell(numMaps,1);
    
    %% SVD variables
    varianceExplainedDiff = cell(numMaps,1);
    
    uTf = cell(numMaps,1);
    sTf = cell(numMaps,1);
    vTf = cell(numMaps,1);
    
    uVel = cell(numMaps,1);
    sVel = cell(numMaps,1);
    vVel = cell(numMaps,1);
    
    numComponents = cell(numMaps,1);
    pTfVsVelSvd = cell(numMaps,1);
    
    reducedMapTf = cell(numMaps,1);
    reducedMapVel = cell(numMaps,1);
    
    componentsTf = cell(numMaps,1);
    componentsVel = cell(numMaps,1);
    
    explainedVarianceTf = cell(numMaps,1);
    explainedVarianceVel = cell(numMaps,1);
    
    %% define a variable to hold the sum of squares of the power maps
    totalEnergy = cell(numMaps,1);
    
    %% pull powerMap information out of inputMaps/structure format
    for mm = 1:numMaps
        %% read in inputMaps input
        % but only taking turning or walkign depending on tw

        powerMap{mm} = inputMaps{mm}.powerMap(:,:,tw{mm});
        powerMapSem{mm} = inputMaps{mm}.powerMapSem(:,:,tw{mm});

        powerMapInd{mm} = cell(length(inputMaps{mm}.powerMapInd),1);
        for ii = 1:length(inputMaps{mm}.powerMapInd)
            powerMapInd{mm}{ii} = inputMaps{mm}.powerMapInd{ii}(:,:,tw{mm});
        end

        lambda{mm} = inputMaps{mm}.lambda;

        tf{mm} = inputMaps{mm}.tf;

        % count the number of flies in each powerMap
        numFlies{mm} = inputMaps{mm}.numFlies;
        numTotalFlies{mm} = inputMaps{mm}.numTotalFlies;
        
        %% define the sf, tf, log, and velocity values the data was measured at
        sf{mm} = 1./lambda{mm};
        sfLog{mm} = log(sf{mm});
        numLam{mm} = size(lambda{mm},2);
        
        tfLog{mm} = log(tf{mm});
        numTf{mm} = size(tf{mm},1);
        
        velMesh{mm} = tf{mm}*lambda{mm};
        vel{mm} = [flipud(velMesh{mm}(1,:)'); velMesh{mm}(:,1)];
        vel{mm}(numLam{mm}) = [];
        velLog{mm} = log(vel{mm});
        numVel{mm} = length(vel{mm});
        
        lambdaMesh{mm} = repmat(lambda{mm},[numTf{mm} 1]);
        sfMeshLog{mm} = repmat(sfLog{mm},[numTf{mm} 1]);
        tfMeshLog{mm} = repmat(tfLog{mm},[1 numLam{mm}]);
        velMeshLog{mm} = log(velMesh{mm});

        
        %% interpolate from data coordinates to evenly sampled coordinates
        powerMapIntTf{mm} = InterpolatePowerMap(powerMap{mm},sfMeshLog{mm},tfMeshLog{mm},numLam{mm},numTf{mm});
        powerMapIntVel{mm} = InterpolatePowerMap(powerMap{mm},sfMeshLog{mm},velMeshLog{mm},numLam{mm},numVel{mm});
        
        
        %% convert walking speed to slowing for fitting
        % this metric increases the more the fly slows
        powerMapIndFit = cell(numLam{mm},1);
        
        for pp = 1:numLam{mm}
            if tw{mm} == 2
                powerMapFit = 1-powerMap{mm};
                powerMapIndFit{pp} = 1-powerMapInd{mm}{pp};
            else
                powerMapFit = powerMap{mm};
                powerMapIndFit{pp} = powerMapInd{mm}{pp};
            end
        end
        
        
        %% generate a distribution of powerMaps by bootstrapping
        [bootedPowerMapsTf,bootedPowerMapsTfSem] = MattBootstrap(@GetSingleFlyPowerMap,numBootstrap,powerMapIndFit);
        [bootedPowerMapsTfAve{mm},bootedPowerMapsTfSemPlot] = MattBootstrap(@GetAveragePowerMap,numBootstrap,powerMapIndFit);        
        
        % project into velocity space
        [bootedPowerMapsIntAveTf,~,tfIntMesh{mm}] = InterpolatePowerMap(bootedPowerMapsTfAve{mm},sfMeshLog{mm},tfMeshLog{mm},numLam{mm},numTf{mm});
        [bootedPowerMapsIntAveVel,sfIntMesh{mm},velIntMesh{mm}] = InterpolatePowerMap(bootedPowerMapsTfAve{mm},sfMeshLog{mm},velMeshLog{mm},numLam{mm},numVel{mm});

        
        %% calculate the maximums of the powerMap
        
        % calculate max TF, Vel, and SF for the mean data
        tfMax{mm} = FitPowerMapMax(tfMeshLog{mm},powerMapFit,polyOrder,numAroundFit,powerMapSem{mm});
        velMax{mm} = FitPowerMapMax(velMeshLog{mm},powerMapFit,polyOrder,numAroundFit,powerMapSem{mm});
%         sfMax{mm} = FitPowerMapMax(sfLog{mm},mean(powerMapFit,1)',polyOrder,numAroundFit);

        tfMax{mm} = exp(tfMax{mm});
        velMax{mm} = exp(velMax{mm});
        
%         sfMax{mm} = exp(sfMax{mm});
        
        % calculate max for the bootstrapped data
%         bootedTfMax = FitPowerMapMax(tfMeshLog{mm},bootedPowerMaps,polyOrder,numAroundFit,bootedPowerMapsSem);
%         bootedVelMax = FitPowerMapMax(velMeshLog{mm},bootedPowerMaps,polyOrder,numAroundFit,bootedPowerMapsSem);
% 
%         bootedTfMax = exp(bootedTfMax);
%         bootedVelMax = exp(bootedVelMax);
%         
%         tfMaxSem{mm} = std(bootedTfMax,[],3);
%         velMaxSem{mm} = std(bootedVelMax,[],3);
        
        tfMaxSem{mm} = zeros(1,numLam{mm});
        velMaxSem{mm} = zeros(1,numLam{mm});
        
        % convert maximum locations to indicies
        maxMat = repmat(tfMax{mm},[numTf{mm} 1]);
        maxMatSub = abs(bsxfun(@minus,maxMat,tf{mm}));
        [~,maxLoc] = min(maxMatSub);
        
        %% p test on maximums
        % test whether the coefficient of variation is signficantly
        % different between tf and vel maxima
%         
%         coefOfVarTf{mm} = abs(std(bootedTfMax,[],2)./mean(bootedTfMax,2));
%         coefOfVarVel{mm} = abs(std(bootedVelMax,[],2)./mean(bootedVelMax,2));
%         
%         pTfMaxVsVelMax{mm} = MattPermutationTest(coefOfVarTf{mm},coefOfVarVel{mm},numPerm);
%         
        %% calculate angle of powerMap
        % loop through bootstraped powermaps and measure their angle
        planeCoef = FitPlaneToPowerMap(sfMeshLog{mm},tfMeshLog{mm},bootedPowerMapsTf,bootedPowerMapsTfSem,maxLoc);

        % calculate plane angles from planeCoef
        planeAngle{mm} = atan2(planeCoef(3,:),planeCoef(2,:))';

        planeAngle{mm} = planeAngle{mm}(~isnan(planeAngle{mm}));
    
        %%% calculate the distribution of means of angles for plotting
        planeCoefPlot = FitPlaneToPowerMap(sfMeshLog{mm},tfMeshLog{mm},bootedPowerMapsTfAve{mm},bootedPowerMapsTfSemPlot,maxLoc);
        planeAngleAve{mm} = atan2(planeCoefPlot(3,:),planeCoefPlot(2,:))';
        planeAngleAve{mm} = planeAngleAve{mm}(~isnan(planeAngleAve{mm}));
        
        % fit a gaussian instead of a plane
%         planeAngle{mm} = FitGaussianToPowerMap(sfMeshLog{mm},tfMeshLog{mm},bootedPowerMaps,bootedPowerMapsSem);
        
        % convert the angle into a unit vector
        planeVector{mm} = exp(planeAngle{mm}*1i);
        
        %% calculate SVD of matricies
        normType = 'none';
        
        svdSize = numTf{mm}-2*(numLam{mm}-1);
        
        [uTf{mm},sTf{mm},vTf{mm},explainedVarianceTf{mm},componentsTf{mm}] = SvdOnPowerMap(bootedPowerMapsIntAveTf,normType,svdSize);
        [uVel{mm},sVel{mm},vVel{mm},explainedVarianceVel{mm},componentsVel{mm}] = SvdOnPowerMap(bootedPowerMapsIntAveVel,normType,svdSize);
        
        varianceExplainedDiff{mm} = explainedVarianceTf{mm}(1,1,:)-explainedVarianceVel{mm}(1,1,:);
        varianceExplainedDiff{mm} = varianceExplainedDiff{mm}(:);        
        
        if median(varianceExplainedDiff{mm})>0
            pTfVsVelSvd{mm} = 2*sum(varianceExplainedDiff{mm}<0)/numBootstrap;
        else
            pTfVsVelSvd{mm} = 2*sum(varianceExplainedDiff{mm}>0)/numBootstrap;
        end
        
        %% calculate distribution of amplitudes
        % reorganize powermaps to be vectors
        bootedPowerMapsTfAveVector{mm} = reshape(bootedPowerMapsTfAve{mm},[numTf{mm}*numLam{mm} numBootstrap]);
        
        
        totalEnergy{mm} = sum(bootedPowerMapsTfAveVector{mm}*diff(sfIntMesh{mm}(1,1:2))*diff(tfIntMesh{mm}(1:2,1)).^2,1)';
        
        %% calculate n to use for statistical testing
        % use the lowest n to be conservative
        n{mm} = min(numFlies{mm});

        %% calculate significance of Vel vs Tf tuning
        % calculate RMSE for plotting
        [~,rmseTf{mm}] = FitPlaneToPowerMap(sfMeshLog{mm},tfMeshLog{mm},bootedPowerMapsTfAve{mm},[],maxLoc,[1 0 1]);
        [~,rmseVel{mm}] = FitPlaneToPowerMap(sfMeshLog{mm},velMeshLog{mm},bootedPowerMapsTfAve{mm},[],maxLoc,[1 0 1]);
        diffRmse{mm} = rmseTf{mm}-rmseVel{mm};
        
        if median(diffRmse{mm})>0
            pTfVsVelRmse{mm} = 2*sum(diffRmse{mm}<0)/numBootstrap;
        else
            pTfVsVelRmse{mm} = 2*sum(diffRmse{mm}>0)/numBootstrap;
        end
    end
    
    %% calculate significance of angle vs other maps
    pAngleDifference = TestAngleDifference(planeVector,n);
    
%     pAngleDifference2 = ones(length(planeVector));
%     
%     for aa = 1:length(planeAngle)
%         for bb = aa+1:length(planeAngle)
%             pAngleDifference2(aa,bb) = MattTwoSampleTTest(mean(planeAngle{aa}),std(planeAngle{aa}),n{aa},mean(planeAngle{bb}),std(planeAngle{bb}),n{bb});
%             pAngleDifference2(bb,aa) = pAngleDifference2(aa,bb);
%         end
%     end
%     disp('linear p values');
%     disp(pAngleDifference2);
    
    
    %% get map limits to use when plotting
    [mapLimits,mapLimitsCentered] = GetMapLimits(powerMap,tw,powerMapSem);
        

    
    
    
    
    
    
    
    
    
    
    
    %% %%%%%%%%%%%%%%%%%%% plotting %%%%%%%%%%%%%%%%%
    if plotFigs
        numHist = numBootstrap/10;

        %% plot powerMap angle
        MakeFigure;

        planeAngleHist = nan(numBootstrap,numMaps);
        for mm = 1:numMaps
            numAngles = length(planeAngleAve{mm});
            planeAngleHist(1:numAngles,mm) = planeAngleAve{mm}(:)*180/pi;
        end

        hist(planeAngleHist,numHist);

        ConfAxis('figLeg',figLeg);
        xlabel('angle of powermap (deg)');

        disp('p values for a difference in mean angle');
        disp(pAngleDifference);

        %% plot tf max vs vel max
        figureHandle = zeros(numMaps,1);
        lineColors = lines(numMaps);

        MakeFigure;
        hold on;
        for mm = 1:numMaps
            h=PlotErrBars(tfMax{mm},velMax{mm},tfMaxSem{mm},velMaxSem{mm},'o');

            figureHandle(mm) = h(1);
            set(h,'color',lineColors(mm,:));
        end
        hold off;

        legend(figureHandle,figLeg);
        ConfAxis();
        xlabel('temporal frequency maximum');
        ylabel('velocity maximum');

        %% plot powerMaps
        nPlot = cell(numMaps,1);
        for mm = 1:numMaps
            nPlot{mm} = cell(1,numLam{mm});
            for lam = 1:length(numFlies{mm})
                nPlot{mm}{lam} = [num2str(numFlies{mm}(lam)) '/' num2str(numTotalFlies{mm}(lam)) '   '];
            end
        end

        % number of contours to plot for each powerMap
        numContours = 20;
        numTicksY = 10;
        tuning = cell(numMaps,1);

        for mm = 1:numMaps
            MakeFigure;
    %         subplot(1,2,1);

            if median(varianceExplainedDiff{mm}) < 0
                tuning{mm} = 'Velocity tuned p = ';
            else
                tuning{mm} = 'TF tuned p = ';
            end

            PlotPowerMap(powerMapIntTf{mm},mapLimitsCentered(:,tw{mm}),numContours,sfLog{mm},tfLog{mm});
            title({figLeg{mm} [' n = ' nPlot{mm}{:}] [tuning{mm} num2str(pTfVsVelSvd{mm})]});

    %         subplot(1,2,2);
    %         PlotPowerMap(powerMapIntVel{mm},mapLimitsCentered(:,tw{mm}),numContours,sfLog{mm},velLog{mm});
        end


        %% plot overlayed curves
        numTicksX = 5;

        for mm = 1:numMaps
            curvesTfPlot = round(exp(linspace(tfLog{mm}(1),tfLog{mm}(end),numTicksX))*10)/10;
            curvesVelPlot = round(exp(linspace(velLog{mm}(1),velLog{mm}(end),numTicksX)));

            switch tw{mm}
                case 1
                    units = '(deg/s)';
                case 2
                    units = '(fold change)';
            end

            MakeFigure;

            % tf vs slowing
            subplot(1,2,1);
            PlotXvsY(tfLog{mm},powerMap{mm},'error',powerMapSem{mm});

            LegendWithTitle(cellfun(@num2str,num2cell(lambda{mm}),'UniformOutput',0),'lambda (deg)');

            ylim(mapLimits(:,tw{mm}));
            xlabel({'temporal frequency (Hz)' ['n = ' nPlot{mm}{:}]});
            ylabel(['fly response ' units]);

            hold on;
            PlotConstLine(0);

            if tw{mm} == 2
                PlotConstLine(1);
            end
            hold off;

            ConfAxis('tickX',log(curvesTfPlot),'tickLabelX',curvesTfPlot,'fTitle',figLeg{mm});


            % vel vs slowing
            subplot(1,2,2);
            PlotXvsY(velMeshLog{mm},powerMap{mm},'error',powerMapSem{mm});


            ylim(mapLimits(:,tw{mm}));
            xlabel('velocity (deg/sec)');

            hold on;
            PlotConstLine(0);

            if tw{mm} == 2
                PlotConstLine(1);
            end
            hold off;

            ConfAxis('tickX',log(curvesVelPlot),'tickLabelX',curvesVelPlot,'fTitle', [tuning{mm} num2str(pTfVsVelSvd{mm})]);
        end

        MakeFigure;
        imagesc(pAngleDifference<0.05);

        %% plot tf vs vel rmse
        for mm = 1:numMaps
            MakeFigure;
            subplot(1,2,1);
            histfit(diffRmse{mm}(:),numHist);
            ConfAxis('fTitle',[figLeg{mm} ', p = ' num2str(pTfVsVelRmse{mm})]);
            xlabel('RMSE (TF-Vel)');
            ylabel('counts');

            subplot(1,2,2);
            histfit(varianceExplainedDiff{mm},100,'kernel');
            ConfAxis('fTitle',[figLeg{mm} ', p = ' num2str(pTfVsVelSvd{mm})]);
            xlabel('SVD variance explained (TF-Vel)');
            ylabel('counts');
        end

        %% plot SVD

    %     for mm = 1:numMaps
    %         % plot original vs reconstruction
    %         MakeFigure;
    %         subplot(2,2,1);
    %         PlotPowerMap(introMapTf{mm},mapLimitsCentered(:,tw{mm})-1,numContours,sfLog{mm},tfLog{mm});
    %         ConfAxis('labelX','original');
    %         
    %         subplot(2,2,2);
    %         PlotPowerMap(reducedMapTf{mm},mapLimitsCentered(:,tw{mm})-1,numContours,sfLog{mm},tfLog{mm});
    %         ConfAxis('labelX','SVD reconstructed');
    %         
    %         subplot(2,2,3);
    %         PlotPowerMap(introMapTf{mm}-reducedMapTf{mm},mapLimitsCentered(:,tw{mm})-(tw{mm}==2),numContours,sfLog{mm},tfLog{mm});
    %         ConfAxis('labelX','original - SVD reconstructed');
    %         
    %         subplot(2,2,4);
    %         hold on;
    %         plot(varianceExplainedTf{mm});
    %         scatter(1:numComponents{mm},varianceExplainedTf{mm}(1:numComponents{mm}));
    %         hold off;
    %         ConfAxis('labelX','components','labelY','% variance explained');
    %         
    %         % calculate the best way to organize subplots
    %         biggerThanLam = ceil(sqrt(numLam{mm}))*floor(sqrt(numLam{mm}))>=numLam{mm};
    %         
    %         if biggerThanLam
    %             subRows = floor(sqrt(numLam{mm}));
    %             subCols = ceil(sqrt(numLam{mm}));
    %         else
    %             subRows = ceil(sqrt(numLam{mm}));
    %             subCols = ceil(sqrt(numLam{mm}));
    %         end
    %         
    %         % plot SVD components
    %         MakeFigure;
    %         subplot(subRows,subCols,ll)
    %         ConfAxis('fTitle',['components for ' figLeg{mm}]);
    %         for ll = 1:numLam{mm}
    %             subplot(subRows,subCols,ll);
    %             imagesc(flipud(componentsTf{mm}(:,:,ll)));
    %             colormap(flipud(cbrewer('div','RdBu',100)));
    %             ConfAxis('labelX',ll);
    %         end
    %         
    %         MakeFigure;
    %         subplot(1,2,1);
    %         imagesc(flipud(uTf{mm}));
    %         ConfAxis('labelX','U');
    %         colormap(flipud(cbrewer('div','RdBu',100)));
    %         colorbar;
    %         subplot(1,2,2);
    %         imagesc(vTF{mm});
    %         ConfAxis('labelX','V');
    %         colormap(flipud(cbrewer('div','RdBu',100)));
    %         colorbar;
    %     end
    end
end
 