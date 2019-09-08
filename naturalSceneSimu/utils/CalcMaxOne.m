function plotFits = CalcMaxOne(RT,varargin)
    colormap_gen;
    figLeg = cell(nargin-1,1);

    for ii = 1:nargin-1
        figLeg{ii} = inputname(ii+1);
    end
    TF = [0.25 0.375 0.5 0.75 1 1.5 2 3 4 6 8 12 16 24 32 48 64];
    
    if length(RT) < length(varargin)
        sizeDiff = length(varargin)-length(RT);
        RT = [RT ones(sizeDiff,1)*2];
    end
    
    numMaps = length(varargin);
    lineColors = lines(numMaps);
    
    respMap = cell(numMaps,1);
    respMapSEM = cell(numMaps,1);
    respMax = cell(numMaps,1);
    respMaxSEM = cell(numMaps,1);
    respScale = cell(numMaps,1);
    respScaleSEM = cell(numMaps,1);

    for mm = 1:numMaps
        for jj = 1:length(varargin{mm});
            respMap{mm} = [respMap{mm} varargin{mm}{jj}.pTraces(:,:,RT(mm))];
            respMapSEM{mm} = [respMapSEM{mm} varargin{mm}{jj}.pSEMTraces(:,:,RT(mm))];
            
            if RT(mm) == 1
                respMax{mm} = [respMax{mm}; varargin{mm}{jj}.polyFit.turnMax];
                respMaxSEM{mm} = [respMaxSEM{mm}; varargin{mm}{jj}.polyFit.turnMaxSEM];

                respScale{mm} = [respScale{mm}; varargin{mm}{jj}.polyFit.turnScale];
                respScaleSEM{mm} = [respScaleSEM{mm}; varargin{mm}{jj}.polyFit.turnScaleSEM];
            else
                respMax{mm} = [respMax{mm}; varargin{mm}{jj}.polyFit.walkMin];
                respMaxSEM{mm} = [respMaxSEM{mm}; varargin{mm}{jj}.polyFit.walkMinSEM];

                respScale{mm} = [respScale{mm}; varargin{mm}{jj}.polyFit.walkScale];
                respScaleSEM{mm} = [respScaleSEM{mm}; varargin{mm}{jj}.polyFit.walkScaleSEM];
            end
        end
    end


    fitMin = 0;
    fitMax = 3000;

    respX = cell(numMaps,1);
    [respX{:}] = deal(0:0.01:30);
    
    respFit = cell(numMaps,1);

    %% set up walk data
    
    cfRespMax = cell(numMaps,1);
    velRespMax = cell(numMaps,1);
    cfRespMaxSEM = cell(numMaps,1);
    velRespMaxSEM = cell(numMaps,1);
    lambda = cell(numMaps,1);
    
    respCoefM(numMaps) = 0;
    respCoefB(numMaps) = 0;
    
    for mm = 1:numMaps
        theseLam = 3:8;
        if size(respMap{mm},2)>6
            theseLam = 1:8;
        elseif size(respMap{mm},2) == 5
            theseLam = 4:8;
        end
        lambda{mm} = [360 180 120 90 60 45 30 22.5]';
        lambda{mm} = lambda{mm}(theseLam);
        
        cfRespMax{mm} = respMax{mm};
        cfRespMaxSEM{mm} = respMaxSEM{mm};

        velRespMax{mm} = cfRespMax{mm}.*lambda{mm};
        velRespMaxSEM{mm} = cfRespMaxSEM{mm}.*lambda{mm};

        [respCoefB(mm),respCoefM(mm)] = york_fit(cfRespMax{mm}',velRespMax{mm}',cfRespMaxSEM{mm}',velRespMaxSEM{mm}',1);

        respFit{mm} = respX{mm}*respCoefM(mm)+respCoefB(mm);

        respX{mm}(respFit{mm}<fitMin) = [];
        respFit{mm}(respFit{mm}<fitMin) = [];
        respX{mm}(respFit{mm}>fitMax) = [];
        respFit{mm}(respFit{mm}>fitMax) = [];
    end


    %% plot lambda{mm} vs temporal frequency maximum
    x = 1:max(lambda{mm});
    makeFigure;
    hold on;
    
    figHand = zeros(numMaps,1);
    
    for mm = 1:numMaps
        h=plotErrBars(lambda{mm},cfRespMax{mm},zeros(size(cfRespMax{mm})),cfRespMaxSEM{mm},'o');
        set(h,'color',lineColors(mm,:));
        figHand(mm) = h(1);
        p = zeros(1,2);

        [p(1),p(2)] = york_fit(lambda{mm}',cfRespMax{mm}',1,cfRespMaxSEM{mm}',0);
        y = p(2)*x+p(1);
        plot(x,y,'color',lineColors(mm,:),'linestyle','- -');
    end
    
    xlabel('lambda')
    ylabel('temporal frequency maximum');
    legend(figHand,figLeg);
    grid off;
    hold off;

    %% plot lambda{mm} vs velocity maximum

    makeFigure;
    hold on;
    
    plotFits = cell(numMaps,1);
    
    for mm = 1:numMaps
        h=plotErrBars(lambda{mm},velRespMax{mm},zeros(size(cfRespMax{mm})),velRespMaxSEM{mm},'o');
        set(h,'color',lineColors(mm,:));
        figHand(mm) = h(1);
        set(h,'LineWidth',2)

        plotFits{mm}.bestLine = zeros(2,1);
        [plotFits{mm}.bestLine(1),plotFits{mm}.bestLine(2)] = york_fit(lambda{mm}',velRespMax{mm}',1,velRespMaxSEM{mm}',0);
        y = plotFits{mm}.bestLine(2)*x+plotFits{mm}.bestLine(1);
        plot(x,y,'linestyle','- -','color',lineColors(mm,:),'LineWidth',2);
        
        plotFits{mm}.velocity = mean(velRespMax{mm});
        plotFits{mm}.TF = mean(velRespMax{mm}.*lambda{mm})/mean(lambda{mm}.^2);
        plot(x,x*0+plotFits{mm}.velocity,'linestyle',':','color',lineColors(mm,:),'LineWidth',2);
        plot(x,x*plotFits{mm}.TF,'linestyle','-.','color',lineColors(mm,:),'LineWidth',2);
    end

    xlabel('lambda');
    ylabel('velocity maximum');
    legend(figHand,figLeg);
    grid off;
    hold off;

    %% plot lambda{mm} vs maximum value
    
    for mm = 1:numMaps
        makeFigure;
        h=plotErrBars(lambda{mm},respScale{mm},zeros(size(cfRespMax{mm})),respScaleSEM{mm},'o');
        set(h,'color',lineColors(mm,:));
        xlabel('lambda');
        ylabel('maximum response');
        legend(h(1),figLeg{mm});
    end
    

    %% plot power maps
    interpRes = 1;
    transMax = 2;
    transMin = 0;
    turnMax = 120;
    turnMin = -120;
    contTrans = linspace(transMin,transMax,20);
    contTurn = linspace(turnMin,turnMax,20);
    for mm = 1:numMaps
        makeFigure;
        [x,y] = meshgrid(1:length(lambda{mm}),1:length(TF));
        [xInt,yInt] = meshgrid(1:interpRes:length(lambda{mm}),1:interpRes:length(TF));
        intMap = interp2(x,y,respMap{mm},xInt,yInt);
        
        imagesc(log(1./lambda{mm}),log(TF(end:-1:1)),intMap);
        hold on;
        if RT(mm) == 2
            contour(log(1./lambda{mm}),log(TF(end:-1:1)),intMap,contTrans,'k');
        else
            contour(log(1./lambda{mm}),log(TF(end:-1:1)),intMap,contTurn,'k');
        end
        hold off;
        
        colormap(mymap);
        if RT(mm) == 2
            caxis([0 2]);
        else
            caxis([-120 120]);
        end
        
        confAxis('tickX',log(1./lambda{mm}),'tickLabelX',lambda{mm},'tickY',log(TF(1:2:end)),'tickLabelY',TF(end:-2:1))
        title(figLeg{mm});
        xlabel('log lambda (degrees)','interpreter','none');
        ylabel('log temporal frequency (Hz)','interpreter','none')
    end
    
    makeFigure;
    for mm = 1:numMaps
        subplot(ceil(numMaps/4),4,mm);
        
        [x,y] = meshgrid(1:length(lambda{mm}),1:length(TF));
        [xInt,yInt] = meshgrid(1:interpRes:length(lambda{mm}),1:interpRes:length(TF));
        intMap = interp2(x,y,respMap{mm},xInt,yInt);
        
        imagesc(log(1./lambda{mm}),log(TF(end:-1:1)),intMap);
        hold on;
        if RT(mm) == 2
            contour(log(1./lambda{mm}),log(TF(end:-1:1)),intMap,contTrans,'k');
        else
            contour(log(1./lambda{mm}),log(TF(end:-1:1)),intMap,contTurn,'k');
        end
        hold off;
        
        colormap(mymap);
        if RT(mm) == 2
            caxis([0 2]);
        else
            caxis([-120 120]);
        end
        
        confAxis('tickX',log(1./lambda{mm}),'tickLabelX',lambda{mm},'tickY',log(TF(1:2:end)),'tickLabelY',TF(end:-2:1))
        title(figLeg{mm});
        xlabel('log lambda (degrees)','interpreter','none');
        ylabel('log temporal frequency (Hz)','interpreter','none')
    end

    %% plot temporal frequency vs velocity maximum
    makeFigure;
    hold on;

    for mm = 1:numMaps
        h = plotErrBars(cfRespMax{mm},velRespMax{mm},cfRespMaxSEM{mm},velRespMaxSEM{mm},'o');
        figHand(mm) = h(1);
        set(h,'color',lineColors(mm,:));
        plot(respX{mm},respFit{mm},'linestyle','- -','color',lineColors(mm,:));
    end

    xlabel('temporal frequency maximum','interpreter','none');
    ylabel('velocity maximum','interpreter','none');
    legend(figHand,figLeg);
    
    hold off;
end