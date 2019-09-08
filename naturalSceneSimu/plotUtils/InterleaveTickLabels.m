function th=InterleaveTickLabels(h)

%get current tick labels
a=get(h,'XTickLabel');
%erase current tick labels from figure
set(h,'XTickLabel',[]);
%get tick label positions
b=get(h,'XTick');
c=get(h,'YTick');
%make new tick labels
xPositions = b;
yPositions = repmat(c(1)-.1*(c(2)-c(1)),length(b),1);
yPositions(2:2:end) = yPositions(2:2:end) - .3*(c(2)-c(1));
th=text(xPositions,yPositions,a,'HorizontalAlignment','center',...
        'VerticalAlignment','top','FontSize',20);

