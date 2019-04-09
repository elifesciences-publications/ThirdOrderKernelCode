function quickViewOneKernel_Smooth(kernel,order, varargin)
% quickViewOneKernel(kernel,1,'labelFlag',true,'posUnit',5,'timeUnit',1/60,'cutFilterFlag','true','barRange',[5:15],'timeRange',1:45,'limPreSetFlag',false);
% quickViewOenKernel_Smooth(kernel,2);
% show center...
% you need to transfer it to its prefered direction...
posLabelStr = 'bar position [degree]';
timeLabelStr = 'time [s]';

posUnit =5;
timeUnit = 1/60; % 60Hz,16.6 ms.

labelFlag = true;
cutFilterFlag = false;

nMultiBars = 20;
barRange = 1:nMultiBars ;
timeRange = size(kernel,2);

colorbarFlag = true;
limPreSetFlag = false;
maxValue = 0;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

colormap_gen;
colormap(mymap);

%
switch order
    case 1
        kernel = kernel(2:end,:); % do not show the full 1 second.
        kernel_smooth = MySmooth_1DKernel(kernel);
        if cutFilterFlag
            kernel_smooth = kernel_smooth(timeRange,barRange);
        end
        imagesc(kernel_smooth);
        thisMaxVal = max(abs(kernel_smooth(:)));
        if thisMaxVal == 0;
            thisMaxVal = 1;
        end
        if limPreSetFlag
            set(gca,'Clim',[-maxValue maxValue]);
        else
            set(gca,'Clim',[-thisMaxVal thisMaxVal]);
        end
        % you have to change the XTickLabel
        
        if labelFlag
            xlabel(posLabelStr);
            ylabel(timeLabelStr);
            
            ax = gca;
            ax.XTick = 2:2:size(kernel_smooth,2);
            ax.YTick = 15:15:size(kernel_smooth,1);
            posTickLabel = strsplit(num2str(ax.XTick * posUnit));
            timeTickLabel = strsplit(num2str(ax.YTick * timeUnit,2));
            ax.XTickLabel = posTickLabel;
            ax.YTickLabel = timeTickLabel;
        end
        if colorbarFlag
            colorbar
        end
    case 2
        maxTauShow = 60;
        maxTau = sqrt(length(kernel));
        kernel_smooth = MySmooth_2DKernel_tilted(kernel);
        K2 = reshape(kernel_smooth,[maxTau,maxTau]);
        % only show the first 30....
        K2 = K2(1:maxTauShow,1:maxTauShow);
        imagesc(K2);
        thisMaxVal = max(abs(K2(:)));
        if thisMaxVal == 0;
            thisMaxVal = 1;
        end
        if maxValue == 0
            maxValue = 1;
        end
        if limPreSetFlag
            set(gca,'Clim',[-maxValue maxValue]);
        else
            set(gca,'Clim',[-thisMaxVal thisMaxVal]);
        end
        axis equal
        axis tight
        set(gca,'XAxisLocation','top');
        if labelFlag
            xlabel(timeLabelStr);
            ylabel(timeLabelStr);
            
            ax = gca;
            ax.XTick = 15:15:maxTauShow;
            ax.YTick = 15:15:maxTauShow;
            timeTickLabel = strsplit(num2str(ax.YTick * timeUnit,2));
            ax.XTickLabel = timeTickLabel;
            ax.YTickLabel = timeTickLabel;
        end
        
        hold on;
        plot([1:maxTauShow],[1:maxTauShow],'k');
        hold off
        if colorbarFlag
            colorbar
        end
end
end