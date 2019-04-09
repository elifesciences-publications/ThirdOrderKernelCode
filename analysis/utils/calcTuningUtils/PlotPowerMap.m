function PlotPowerMap(powerMap,mapLimits,numContours,x,y,useLabels)
    if nargin<3
        numContours = 20;
    end
    
    if nargin<4
        x = 1:size(powerMap,2);
        y = 1:size(powerMap,1);
        useLabels = 0;
    elseif nargin<6
        useLabels = 1;
    end

    % determine the contours to overlay on the powermaps
    contours = linspace(mapLimits(1),mapLimits(2),numContours);

    % defines a set z axis for each powermap
    axisLimits = [mapLimits(1) mapLimits(2)];

    hold on;
    h=imagesc(x,y,powerMap);
    set(h,'alphadata',~isnan(powerMap))
    set(gca,'Color',[0.8 0.8 0.8]);
%     h=pcolor(peaks(42));
%     set(h,'edgecolor','none')
    contour(x,y,powerMap,contours,'k');
    hold off;

    caxis(axisLimits);
    
    if useLabels
        colorbar;
    end
    
    colormap(flipud(cbrewer('div','RdBu',100)));
    
    numTicksY = 10;
    
    % assumes log sf and log tf coordinates
    xPlot = round(1./exp(linspace(x(1),x(end),size(powerMap,2)))*10)/10;
    yPlot = round(exp(linspace(y(1),y(end),numTicksY))*10)/10;
    
    if useLabels
        ConfAxis('tickX',log(1./xPlot),'tickLabelX',xPlot,'tickY',log(yPlot),'tickLabelY',yPlot);
        xlabel('SF ($\frac{1}{^\circ}$)','interpreter','latex');
        ylabel('TF (Hz)');
    else
        ConfAxis;
    end
    
end