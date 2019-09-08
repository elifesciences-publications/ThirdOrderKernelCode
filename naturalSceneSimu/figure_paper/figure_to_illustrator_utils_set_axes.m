function figure_to_illustrator_utils_set_axes(varargin)
    fontSize = 10;
    axesfontSize = 8;
    axesLineWidth = 1;
    lineWidth = 2;
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    ax = gca;
    ax.YLabel.FontSize = fontSize;
    ax.XLabel.FontSize = fontSize;
    ax.LineWidth = axesLineWidth;
    set(gca,'FontSize',axesfontSize,'box','off','FontName','Arial');
    set(gca,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0]);
    set(findall(gca, 'Type', 'Line'),'LineWidth',lineWidth);
    set(findall(gca, 'Type', 'ErrorBar'),'LineWidth',lineWidth);
end