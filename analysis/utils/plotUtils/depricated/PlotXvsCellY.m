function plotTitle = plotXvsCellY(x,cellY,nameX,nameY,varargin)
    %calls plotXvsY for every member of cellY and plots it against x
    plotLeg = 0;
    figLeg = {''};
    cellError = [];
    cellColor = lines(length(cellY));
    
    disp('plotXvsCellY is depricated, should use plotXvsY for all the things');
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    hold on;
    if isempty(cellError)
        for ii = 1:length(cellY)
            plotTitle = plotXvsY(x,cellY{ii},nameX,nameY,varargin{:},'color',cellColor(ii,:),'plotLeg',plotLeg);
        end
    else
        for ii = 1:length(cellY)
            plotTitle = plotXvsY(x,cellY{ii},nameX,nameY,'error',cellError{ii},'color',cellColor(ii,:),'plotLeg',plotLeg);
        end
    end
    legend(figLeg);
    hold off;
end