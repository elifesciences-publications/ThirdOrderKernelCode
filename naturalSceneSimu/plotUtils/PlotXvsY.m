function PlotXvsY(x,y,varargin)
%set up default values. all default values can be changed by varargin
%by putting them in the command line like so
%plotXvsY(...,'color','[0,0,1]');
color = lines(size(y,2));
if(size(x,1) > 1)
    graphType = 'line';
else
    graphType = 'scatter';
end

error = [];
significance = [];
lineStyle = '-';
hStat = ishold;
connect = false;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

switch graphType
    case 'line'
        if isempty(error)
            %                 set(gca, 'ColorOrder', color, 'NextPlot', 'add');
            plottedLines = plot(x,y,'lineStyle',lineStyle);
            colorCell = mat2cell(color, ones(size(color, 1),1), 3);
            [plottedLines.Color] = deal(colorCell{:});
            caxis([0 size(color,1)]);
        else
            PlotErrorPatch(x,y,error,color);
        end
    case 'scatter'
        if isempty(error)
            scatter(x,y,50,color);
        else
            if ~hStat, hold on; end
            for c = 1:size(x,2)
                scatter(x(:,c),y(:,c),50,color(c,:));
                errorbar(x(:,c),y(:,c),error(:,c),'color',color(c,:),'LineStyle','none');
            end
            if ~hStat, hold off; end
        end
    case 'bar'
%         colormap(color);
        barPlot = bar(x,y ,'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
        
        if ~isempty(error)
            set(gca, 'ColorOrder', color, 'NextPlot', 'replace');
            hold on;
            numbars = length(x);
            groupwidth = min(0.8, numbars/(numbars+1.5));
            relBarPos = 1:size(y, 2);
            groupShift = -groupwidth/(2*numbars) + (2*(relBarPos)-1) * groupwidth / (2*numbars);
            x = repmat(x,[1 ceil(size(y,2)/size(x,2))]);
            x = x(:,1:size(y,2));
            groupShift = repmat(groupShift, [size(x, 1), 1]);
            x = x + groupShift;
            if size(error, 3) == 1
                errorbar(x,y,error,'LineStyle','none', 'Color', 'k');
            else
                errorbar(x,y,error(:, :, 1), error(:, :, 2),'LineStyle','none');
            end
            
        end
        if ~isempty(significance) % Draw asterisks for significance--** for <0.01 and * for <0.05
            pThresh = 0.05;
            pThreshStrict = 0.01;
            maxY = max(y(:)) * 1.5;
            maxPlot = barPlot.Parent.YLim(end);
            astHeight = mean([maxY maxPlot]);
            text(x(significance<pThresh & significance>pThreshStrict), astHeight*ones(sum(significance<pThresh & significance>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
            text(x(significance<pThreshStrict), astHeight*ones(sum(significance<pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
        end
        
        
        if ~hStat, hold off; end
    case 'spread'
        if ~hStat, hold on; end
        if connect
            color = repmat(color,[ceil(size(x,1)/size(color,1)) 1]);
            color = color(1:size(x,1),:);
            for r = 1:size(x, 1)
                plot(x(r, :), y(r, :), 'Color', color(r, :), 'Marker', 'o');
            end
            errPlot = errorbar(x(1, :),mean(y, 1),error,'Color', [0 0 0], 'LineStyle','none');
        else
            color = repmat(color,[ceil(size(x,2)/size(color,1)) 1]);
            color = color(1:size(x,2),:);
            for c = 1:size(x,2)
                scatter(x(:,c),y(:,c),50,color(c,:));
                errPlot = errorbar(x(1, c)+0.2*mean(diff(x(1, :))),mean(y(:, c)),error(c),'Color', color(c, :), 'LineStyle','none');
            end
        end
        if ~isempty(significance) % Draw asterisks for significance--** for <0.01 and * for <0.05
            pThresh = 0.05;
            pThreshStrict = 0.01;
            colorSigPca = pca(color);
            [~, bestPca] = min(sum(color*colorSigPca'));
            colorSig = colorSigPca(bestPca, :); % Honestly just an attempt to have a color that's different...
            maxY = max(y(:));
            maxPlot = errPlot.Parent.YLim(end);
            astHeight = mean([maxY maxPlot]);
            text(x(1, significance<pThresh & significance>pThreshStrict), astHeight*ones(sum(significance<pThresh & significance>pThreshStrict), 1), '*', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', colorSig);
            text(x(1, significance<pThreshStrict), astHeight*ones(sum(significance<pThreshStrict), 1), '**', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', colorSig);
        end
        
        if ~hStat, hold off; end
        
end

%     ConfAxis();
end