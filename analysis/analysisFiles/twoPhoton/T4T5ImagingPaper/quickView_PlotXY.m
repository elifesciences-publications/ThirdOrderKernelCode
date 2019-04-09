function quickView_PlotXY(x,y,varargin)
% quickView_XY(x,y,'subplotHt',4,'subplotWd',5,'errorBarFlag',true,'sem',sem);
subplotHt = 3;
subplotWd = 4;
errorBarFlag = false;
sem = [];
limPreSetFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii}, '= varargin{', num2str(ii + 1),'};'])
end
% there should be a limit on how many rois you are presenting, let us see.
% 5*5.

nMaxRoiOne = subplotHt * subplotWd;
nCases = size(y,2);
nMaxCases = min(nMaxRoiOne,nCases);

% makeSure that everyone in this plot has the same scale...

yLimMax = max(abs(y(:)))+ max(abs(sem(:)));
yLim = [-yLimMax,yLimMax];
%%
if nMaxCases == nMaxRoiOne;
    
    nRound = ceil(nCases/nMaxCases);
    count = 1;
    for ii = 1:1:nRound
        MakeFigure;
        for cc = 1:1:nMaxRoiOne
            subplot(subplotHt,subplotWd,cc);
            % plot gliderrespon...
            PlotXY_Juyue(x(:,count),y(:,count),'errorBarFlag',errorBarFlag,'sem',sem(:,count),'limPreSetFlag',limPreSetFlag,'maxValue',yLimMax);            
            count = count+1;
            if(count > nCases)
                return
            end
        end
    end
else
    subplotHt = floor(sqrt(nCases));
    subplotWd = ceil(nCases/subplotHt);
    MakeFigure;
    for count = 1:1:nCases
        subplot(subplotHt,subplotWd,count);
        PlotXY_Juyue(x(:,count),y(:,count),'errorBarFlag',errorBarFlag,'sem',sem(:,count),'limPreSetFlag',limPreSetFlag,'maxValue',yLimMax);
        set(gca,'yLim',yLim);
    end
end
