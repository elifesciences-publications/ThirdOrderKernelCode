function lineHandle = PlotConstLine(value,constDim,referenceLineColor)
        if nargin < 2 || isempty(constDim)
            constDim = 1;
        end
        
        if nargin < 3 || isempty(constDim)
            referenceLineColor = [0 0 0];
        end
        
        limitsX = xlim';
        limitsY = ylim';
        
        switch constDim
            case 1 % y value doesn't change
                % if the value is outside of the range, don't plot just
                % move the limits
%                 if (limitsY(1)>=value || limitsY(2)<=value)
%                     sortedLimits = sort([limitsY; value]);
%                     ylim([sortedLimits(1) sortedLimits(end)]);
%                 else
                    lineHandle = plot(limitsX,[value; value],'--','Color',referenceLineColor);
%                 end
            case 2 % x value doesn't change
%                 if (limitsX(1)>=value || limitsX(2)<=value)
%                     sortedLimits = sort([limitsX; value]);
%                     xlim([sortedLimits(1) sortedLimits(end)]);
%                 else
                    lineHandle = plot([value; value],limitsY,'--','Color',referenceLineColor);
%                 end
        end
end