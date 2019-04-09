function PlotBinData(x,y,nameX,nameY,numBins,varargin)
    %can take graphType, edges, and color as optional arguments through
    %varargin

    graphType = 'bar';
    edges = linspace(min(x),max(x),numBins+1);
    color = lines(1);
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    centers = edges(1:end-1) + (edges(end)-edges(1))/(2*numBins);
    
    [~,whichBin] = histc(x,edges);
    binMean = zeros(numBins,1);
    
    for i = 1:numBins
        flagBin = (whichBin == i)';
        binMembers = y(flagBin);
        binMean(i) = mean(binMembers);
    end
    
    plotXvsY(centers,binMean,nameX,nameY,'color',color,'graphType',graphType);
end