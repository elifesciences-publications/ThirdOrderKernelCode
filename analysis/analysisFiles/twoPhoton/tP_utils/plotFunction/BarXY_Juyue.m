function BarXY_Juyue(x,y,varargin)
errorBarFlag = false;
sem = [];
xTickStr = [];
limPreSetFlag = false;
limPreSetNeg = true;
maxValue = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end


bar(x,y);
if errorBarFlag
    hold on
    errorbar(x,y,sem,'k.');
    hold off
end
if limPreSetFlag
    if limPreSetNeg
    set(gca,'yLim',[-maxValue,maxValue]);
    else
          set(gca,'yLim',[0,maxValue]);
    end
    
end

hold on
plot([1,2],[0,0],'k--');
hold off

numTick = length(x);
set(gca,'XTick',1:1:numTick,'XTickLabel',xTickStr);
end
