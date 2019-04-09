function g=PlotErrorPatch(x,y,e,color)
    %x=x(:)';
    %y=y(:)';
    %e=e(:)';
    if nargin<4
        color = [];
    end
    
    if size(e, 3)==1
        yErrorTop=y+e;
        yErrorBottom=y-e;
    else
        yErrorBottom=y-e(:, :, 1);
        yErrorTop=y+e(:, :, 2);
    end
    
    numPointsToPlotErrorBars = 10;
    
    %Make the bottom run the opposite direction to plot around the eventual
    %shape of the error patch clockwise
    yErrorBottom=yErrorBottom(end:-1:1,:);
    ye=[yErrorTop;yErrorBottom];
    
    %Similarily run the x back
    xe=[x;x(end:-1:1,:)];
    xe = repmat(xe,[1 size(ye,2)/size(xe,2)]);
    x = repmat(x,[1 size(y,2)/size(x,2)]);

    % if the number of colors provided is less than the number of lines,
    % then repeat colors
    color = repmat(color,[ceil(size(x,2)/size(color,1)) 1]);
    color = color(1:size(x,2),:);
    
    hStat = ishold;
    
    hold on;
    if ~all(e(:)==0)
%         colormap(color);
        h=fill(xe,ye,repmat(0:size(xe,2)-1,[size(xe,1) 1]),'linestyle','none','FaceAlpha',0.25);

        hAnnotation = get(h,'Annotation');

        if ~iscell(hAnnotation)
            hAnnotation = {hAnnotation};
        end

        for ii = 1:length(h)
            hLegendEntry = get(hAnnotation{ii},'LegendInformation');
            set(hLegendEntry,'IconDisplayStyle','off');
            % You have to go backwards because for some reason their
            % handles are saved in the inverted order of plotting? Thanks,
            % Matlab <.<
            h(end-ii+1).EdgeColor=color(mod(length(h)-ii, size(color, 1))+1, :);
%             h(end-ii+1).LineStyle='--';
            h(end-ii+1).FaceColor=color( mod(length(h)-ii, size(color, 1))+1, :);
        end
    
    end
    
    set(gca, 'ColorOrder', color, 'NextPlot', 'add');
    if size(x,1) < numPointsToPlotErrorBars
        if size(e, 3) == 1
            g=errorbar(x,y,e,'marker','o');
        else
            g=errorbar(x,y,e(:, :, 1), e(:, :, 2),'marker','o');
        end
    else
        g=plot(x,y);
    end
    if ~iscell(color)
        colorCell = mat2cell(color, ones(1, size(color, 1)), size(color, 2));
        [g.Color] = deal(colorCell{:});
    end
    
    if hStat, hold on; end
    if ~hStat, hold off; end
end
