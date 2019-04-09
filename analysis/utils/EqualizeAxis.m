function EqualizeAxis(equalizeX,centerZero)
    % this function will sort through all currently open figures and find
    % their max axis. Then it will set all axis to these max axis range
    
    if nargin<1
        equalizeX = true;
        centerZero = false;
    end
    
    if nargin<2
        centerZero = false;
    end
    
    hFigs = get(0, 'children'); %Get list of figures
    numFigs = length(hFigs);
    
    yLimTop = zeros(numFigs,1);
    yLimBottom = zeros(numFigs,1);
    xLimTop = zeros(numFigs,1);
    xLimBottom = zeros(numFigs,1);
    
    axisHandles = cell(numFigs,1);
    
    for hh = 1:numFigs;
        axisHandles{hh} = findall(hFigs(hh),'type','axes');
        
        yLimBottom(hh) = axisHandles{hh}.YLim(1);
        yLimTop(hh) = axisHandles{hh}.YLim(2);
        
        xLimBottom(hh) = axisHandles{hh}.XLim(1);
        xLimTop(hh) = axisHandles{hh}.XLim(2);
    end
    
    yLimBottomMin = min(yLimBottom);
    yLimTopMax = max(yLimTop);
    
    xLimBottomMin = min(xLimBottom);
    xLimTopMax = max(xLimTop);
    
    if centerZero
        farthestAxisFromZero = max(abs([yLimBottomMin yLimTopMax]));
        yAxisLimits = [-farthestAxisFromZero farthestAxisFromZero];
    else
        yAxisLimits = [yLimBottomMin yLimTopMax];
    end
    
    if equalizeX
        xAxisLimits = [xLimBottomMin xLimTopMax];
    end
    
    for hh = 1:numFigs;
        ylim(axisHandles{hh},yAxisLimits);
        xlim(axisHandles{hh},xAxisLimits);
    end
end