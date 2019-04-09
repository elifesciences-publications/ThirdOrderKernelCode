function CalcTuning(TW,varargin)
    % boy this code neads to be refactored

    ColorMapGen; % this generates a color map that goes from blue to white to red
    
    figLeg = cell(nargin-1,1); % initialize a cell array for figure legends
    for lam = 1:nargin-1
        figLeg{lam} = inputname(lam+1); % set the figure legend to the input variable names
    end
    
    % RT is a variable that determines whether the corresponding map is
    % turning or walking data. If this array is too small, assume the data
    % is for walking
    if length(TW) < length(varargin)
        sizeDiff = length(varargin)-length(TW);
        TW = [TW ones(1,sizeDiff)*2];
    end
    
    numMaps = length(varargin); % the number of power maps to deal with
    
    respMap = cell(numMaps,1); % cell array to hold all the power maps
    respMapSem = cell(numMaps,1); % cell array to hold all the SEM of the power maps
    
    respMapInd = cell(numMaps,1);
    numFlies = zeros(numMaps,1);
    TF = cell(numMaps,1);
    numTF = cell(numMaps,1);
    
    %% loop through each map, and put the responses together into one matrix
    % format of col: SF, row: TF, holds response of the flies at the TF,SF.
    % third diminsion: 1 is turning and 2 is walking
    for mm = 1:numMaps
        respMapInd{mm} = cell(size(varargin{mm},1),1);
        
        for jj = 1:size(varargin{mm},1);
            respMap{mm} = [respMap{mm} varargin{mm}{jj}.resp(:,:,TW(mm))];
            respMapSem{mm} = [respMapSem{mm} varargin{mm}{jj}.respSem(:,:,TW(mm))];
            
            % map data for each individual fly
            respMapInd{mm}{jj} = varargin{mm}{jj}.respInd(:,:,TW(mm));
        end
        
        % the standard TF range I test. Consider making this an optional input variable
        TF{mm} = [0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32 48 64]';

        if size(respMap{mm},1) == 15;
            TF{mm} = [0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32]';
        end

        numTF{mm} = length(TF{mm});
    end


    %% set up lambda
    lambda = cell(numMaps,1); % cell array keeping the lambda for each map
    numLam = cell(numMaps,1); % cell array keeping the number of different lambda for each map
    
    for mm = 1:numMaps
        % theseLam is a way to select a subste of lambda from a larger list
        % that applies to this data set. Its not perfect, but generally if
        % the set has 6 measurements then lam goes from 22.5 to 120.
        % Otherwise it is generally from 22.5 to 360.
        theseLam = 3:8;
        if size(respMap{mm},2)>6
            theseLam = 1:8;
        elseif size(respMap{mm},2)==4
            theseLam = 3:6;
        elseif size(respMap{mm},2)==5
            theseLam = 4:8;
        end
        
        lambda{mm} = [360 180 120 90 60 45 30 22.5];
        lambda{mm} = lambda{mm}(theseLam);
        numLam{mm} = length(lambda{mm});
    end

    %% plot lambda vs TF and vs Vel
    interpRes = 1; % number of times to interpolate between data points
    
    % max and minimum values for power maps
    walkMax = 2;
    walkMin = 0;
    turnMax = 200;
    turnMin = -turnMax;
    
    % spacing between contour lines for the power maps
    walkSpacing = 0.1;
    turnSpacing = 20;
    walkContours = walkMin:walkSpacing:walkMax;
    turnContours = turnMin:turnSpacing:turnMax;
    
    tfMap = cell(numMaps,1);
    velMap = cell(numMaps,1);
    
    tfX = cell(numMaps,1);
    tfY = cell(numMaps,1);
    velX = cell(numMaps,1);
    velY = cell(numMaps,1);
    
    TFmat = cell(numMaps,1);
    SFmat = cell(numMaps,1);
    VELmat = cell(numMaps,1);
    
    for mm = 1:numMaps
        MakeFigure;
        
        % set up the STARTING x and y coordinates of the map
        sf = 1./lambda{mm}; % spatial frequencies for this data
        TFmat{mm} = repmat(TF{mm},[1 numLam{mm}]);
        VELmat{mm} = TF{mm}*lambda{mm};
        numVel = numTF{mm}+numLam{mm}-1;
        SFmat{mm} = repmat(sf,[length(TF{mm}) 1]);
        
        % set up the DESIRED x and y coordinates for the power map
        velMin = TF{mm}(1)/sf(end); % minimum and maximum velocity to interpolate between
        velMax = TF{mm}(end)/sf(1);
        
        SFq = exp(linspace(log(sf(1)),log(sf(end)),interpRes*numLam{mm})); % upsampled SF for interpolation (samples exponentially)
        TFq = exp(linspace(log(TF{mm}(1)),log(TF{mm}(end)),interpRes*numTF{mm}))'; % upsampled TF for interpolation (samples exponentially)
        VELq = exp(linspace(log(velMin),log(velMax),interpRes*(numTF{mm}+numLam{mm}-1)))'; % upsampled velocities (samples exponentially)
        
        numPlotLam = numLam{mm};
        numPlotTF = 9;
        numPlotVEL = 8;
        plotLam = round(1./SFq(round(linspace(1,length(SFq),numPlotLam)))*10)/10;
        plotTF = round(TFq(round(linspace(1,length(TFq),numPlotTF)))*100)/100;
        plotVEL = round(VELq(round(linspace(1,length(VELq),numPlotVEL))));
        
        % mesh grid of TF x and y, and Vel x and y
        [tfX{mm},tfY{mm}] = meshgrid(SFq,TFq);
        [velX{mm},velY{mm}] = meshgrid(SFq,VELq);
        
        % annoying rounding erros might cause errors during interpolation.
        % To make sure you're always interpolating to the ends of the data
        % set the ends here
        tfX{mm}(:,1) = SFmat{mm}(1,1);
        tfX{mm}(:,end) = SFmat{mm}(1,end);
        tfY{mm}(1,:) = TFmat{mm}(1,1);
        tfY{mm}(end,:) = TFmat{mm}(end,1);
        
        velX{mm}(:,1) = SFmat{mm}(1,1);
        velX{mm}(:,end) = SFmat{mm}(1,end);
        velY{mm}(1,:) = velMin;
        velY{mm}(end,:) = velMax;
        
        % map the power map data to a plane
        tfMap{mm} = griddata(SFmat{mm},TFmat{mm},respMap{mm},tfX{mm},tfY{mm},'linear');
        velMap{mm} = griddata(SFmat{mm},VELmat{mm},respMap{mm},velX{mm},velY{mm},'linear');
        
        
        if TW(mm) == 1
            theseContours = turnContours;
            theseAxis = [turnMin turnMax];
        else
            theseContours = walkContours;
            theseAxis = [walkMin walkMax];
        end
        
        subplot(1,2,1);
        hold on;
        imagesc(log(SFq),log(TFq),tfMap{mm});
        contour(log(SFq),log(TFq),tfMap{mm},theseContours,'k');
        colorbar;
        hold off;
        
        ConfAxis('tickX',log(1./plotLam),'tickLabelX',plotLam,'tickY',log(plotTF),'tickLabelY',plotTF,'fTitle',figLeg{mm});
        xlabel('lambda (deg)');
        ylabel('TF (Hz)')
        caxis(theseAxis);
        
        subplot(1,2,2);
        hold on;
        imagesc(log(SFq),log(VELq),velMap{mm});
        contour(log(SFq),log(VELq),velMap{mm},theseContours,'k');
        hold off;
        colorbar;
        ConfAxis('tickX',log(1./plotLam),'tickLabelX',plotLam,'tickY',log(plotVEL),'tickLabelY',plotVEL);
        xlabel('lambda (deg)');
        ylabel('velocity (deg/sec)')
        caxis(theseAxis);
        
        colormap(mymap);
    end
    
    for mm = 1:numMaps
        switch TW(mm)
            case 1
                theseAxis = [0 turnMax];
                units = '(deg/s)';
            case 2
                theseAxis = [walkMin 1.5];
                units = '(fold change)';
        end
        
        MakeFigure;
%         subplot(1,2,1);
%         scatter(log(tfY{mm}(:,ii)),tfMap{mm}(:,ii));
%         scatter(log(TF{mm}),respMap{mm}(:,ii));
%         errorbar(log(TFmat{mm}),respMap{mm},respMapSEM{mm},'linestyle','none','marker','o');
        PlotXvsY(log(TFmat{mm}),respMap{mm},'error',respMapSem{mm});
        
        legend(cellfun(@num2str,num2cell(lambda{mm}),'UniformOutput',0));
        ConfAxis('tickX',log(plotTF),'tickLabelX',plotTF,'fTitle',figLeg{mm});
        ylim(theseAxis);
        xlabel('temporal frequency (Hz)');
        ylabel(['fly response ' units]);
        
        MakeFigure;
%         subplot(1,2,2);
%         scatter(log(velY{mm}(:,ii)),velMap{mm}(:,ii));
%         scatter(log(VELmat{mm}(:,ii)),respMap{mm}(:,ii));
%         errorbar(log(VELmat{mm}),respMap{mm},respMapSEM{mm},'linestyle','none','marker','o');
        PlotXvsY(log(VELmat{mm}),respMap{mm},'error',respMapSem{mm});
        
        ConfAxis('tickX',log(plotVEL),'tickLabelX',plotVEL);
        ylim(theseAxis);
        xlabel('velocity (deg/sec)');
        ylabel(['fly response ' units]);
    end
    
    
    isoLines = cell(numMaps,1);
    isoLinesAve = cell(numMaps,1);
    isoLinesSem = cell(numMaps,1);
    velFit = cell(numMaps,1);
    tfFit = cell(numMaps,1);
    alpha = cell(numMaps,1);
    
    fitStepTurn = 20;
    fitMinTurn = fitStepTurn*2;
    fitMaxTurn = turnMax-fitStepTurn*2;
    
    fitStepWalk = 0.1;
    fitMinWalk = fitStepWalk*2;
    fitMaxWalk = 1.5-fitStepWalk*2;
    
    %% calculate relative velocity tuning vs tf tuning
    for mm = 1:numMaps
        % regenerate many of the useful variables from above. this whole
        % thing needs to be reorganized at some point
        
        % spatial frequency
        sf = log(1./lambda{mm})';
        
        % determine which isolines to extract from the data, this should be
        % automated not hardcoded
        if TW(mm) == 1
            valuesToExtract = fitMinTurn:fitStepTurn:fitMaxTurn;
            [~,maxLoc] = max(respMap{mm});
        else
            valuesToExtract = fitMinWalk:fitStepWalk:fitMaxWalk;
            [~,maxLoc] = min(respMap{mm});
        end
        
        % number of isolines to extract
        numToExtract = length(valuesToExtract);
        
        % array of isolines, each column is a different isoline, each row
        % is the lambda at which it is measured, the value is the temporal
        % frequency at which that lambda reached that isoline
        
        isoLines{mm} = cell(numLam{mm},1);
        isoLinesAve{mm} = zeros(numLam{mm},numToExtract);
        isoLinesSem{mm} = zeros(numLam{mm},numToExtract);
        
        % spatial frequency at each isoline, use log sf
        sfIsoMat = repmat(sf,[1 numToExtract]);
        
        % run through each lambda and interpolate to get the isoline
        % measured at one of hte valuesToExtract
        % only take values below the maximum TF (force it to be a function,
        % we're only investigating the tuned part of the curve)
        for lam = 1:numLam{mm}
            for ff = 1:size(respMapInd{mm}{lam},2)
                isoLines{mm}{lam}(:,ff) = interp1(respMapInd{mm}{lam}(1:maxLoc(lam),ff),log(TF{mm}(1:maxLoc(lam))),valuesToExtract);
            end
            
            isoLinesAve{mm}(lam,:) = nanmean(isoLines{mm}{lam},2);
            isoLinesSem{mm}(lam,:) = nanstd(isoLines{mm}{lam},[],2)/sqrt(size(respMapInd{mm}{lam},2));
        end
        
        
        
        %% fit to Vel vs TF individually
        % if the isolines are a function of TF, then TF = A where A is TF
        % of the isoline, in logspace log(TF) = log(A). If the isolines are
        % a function of vel then TF = A*SF where A is the velocity of the
        % isoline. In log space, log(TF) = log(A) + log(SF) % in both cases
        % in logspace these models predict a line and we can fit only the
        % intercept (log(A)) and assume either a slope of 0 (TF) or 1
        % (Vel). We can then determine how much variance these two models
        % predicts.
        
        % calculate best fit of TF. In terms of least squares the best flat
        % line fit is simply the mean weighted by inverse variance
        tfWeighted = isoLinesAve{mm}.*(1./(isoLinesSem{mm}.^2));
        tfFit{mm} = bsxfun(@rdivide,sum(tfWeighted),sum(1./(isoLinesSem{mm}.^2)));
        
        % calculate best fit of Vel. In terms of least squares fit, simply
        % subtract off the log(SF) term and once again the best fit for a
        % single term in least squares is the mean, weighted by inverse variance
        slopeSubtractedIsolines = bsxfun(@minus,isoLinesAve{mm},sf);
        velWeighted = slopeSubtractedIsolines.*(1./isoLinesSem{mm}.^2);
        velFit{mm} = bsxfun(@rdivide,sum(velWeighted),sum(1./(isoLinesSem{mm}.^2)));
        
        % create a model by using the fit terms, once again the vel model
        % is log(A) + log(SF) and the TF model is log(A)
        velModel = bsxfun(@plus,sfIsoMat,velFit{mm});
        tfModel = repmat(tfFit{mm},[numLam{mm} 1]);
        
        % plot? thats a lot of lines but useful
        MakeFigure;
        hold on;
        PlotXvsY(sf,isoLinesAve{mm},'error',isoLinesSem{mm});
        plot(sf,velModel,'b');
        plot(sf,tfModel,'r');
        hold off;
        
        % calculate variance between model and isolines
        varianceVel = (velModel-isoLinesAve{mm}).^2;
        varianceTF = (tfModel-isoLinesAve{mm}).^2;
        
        % divide out the variance of the isolines
        weightedVarianceVel = varianceVel./isoLinesSem{mm}.^2;
        weightedVarianceTF = varianceTF./isoLinesSem{mm}.^2;
        
        % calculate the normalized chi squared of each isoline by averaging
        % over the weighted variance and dividing by the number of points
        chiSquaredVel = nansum(weightedVarianceVel)/(size(isoLinesAve{mm},1));
        chiSquaredTF = nansum(weightedVarianceTF)/(size(isoLinesAve{mm},1));
        
        meanChiSquaredVel = nanmean(chiSquaredVel);
        meanChiSquaredTF = nanmean(chiSquaredTF);
        
        semChiSquaredVel = nanstd(chiSquaredVel)/sqrt(length(chiSquaredVel));
        semChiSquaredTF = nanstd(chiSquaredTF)/sqrt(length(chiSquaredTF));
        
        MakeFigure;
        bar([chiSquaredTF; chiSquaredVel]);
        
        MakeFigure;
        hold on;
        bar([meanChiSquaredTF,meanChiSquaredVel]);
        errorbar([meanChiSquaredTF,meanChiSquaredVel],[semChiSquaredTF,semChiSquaredVel],'k','LineStyle','none','LineWidth',2)
        ConfAxis('tickX',[1 2],'tickLabelX',{'TF tuned','velocity tuned'},'labelY','normalized chi squared');
        hold off;
        
        aveChiSquaredVel = sum(chiSquaredVel);
        aveChiSquaredTF = sum(chiSquaredTF);
        
        %% fit to arbitrary model w=A*k^alpha | log(w)=log(A)+alpha*log(k)
        % this is a possible larger parameter space of models in which
        % temporal frequency tuning is alpha = 0 and velocity tuning is
        % alpha = 1
        
        alpha{mm} = zeros(numToExtract,1);
        
        for iso = 1:numToExtract
            A = [ones(numLam{mm},1),sf];
            B = isoLinesAve{mm}(:,iso);
            w = isoLinesSem{mm}(:,iso);
            p = lscov(A,B,w);
            
%             a = polyval(p(end:-1:1),sf);
%             MakeFigure;
%             hold on;
%             plot(sf,a);
%             plot(sf,B);
            alpha{mm}(iso) = p(2);
        end
    end
    
    MakeFigure;
    for mm = 1:numMaps
        subplot(1,2,mm);
        bar(alpha{mm});
    end
    
    MakeFigure;
    for mm = 1:numMaps
        subplot(1,2,mm);
        hold on;
        bar(mean(alpha{mm}));
        errorbar(mean(alpha{mm}),std(alpha{mm})/sqrt(size(alpha{mm},1)),'k','LineStyle','none','LineWidth',2);
        ConfAxis('tickX',[1 2],'tickLabelX',{'turn','walk'},'labelY','best fit line slope');
        hold off;
    end
end