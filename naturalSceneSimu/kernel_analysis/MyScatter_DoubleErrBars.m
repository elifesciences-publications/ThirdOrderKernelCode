function  MyScatter_DoubleErrBars(x, y, xerr, yerr, varargin)
% get a easy plot.
color = [0,0,0];
type = 'scatter';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
switch type
    case 'scatter'
        scatter(x, y, 'MarkerEdgeColor',color,'MarkerFaceColor',color,'LineWidth', 1,'Marker','.');
    case 'bar'
        b = bar(x, y);
        b(1).FaceColor = color;
end
hold on
% plot the error bar.
for ii = 1:1:length(x)
    % first, plot x error bar.
    %     if isempty(xerr)
    %         xerr = zeros(size(x));
    %     end
    if size(xerr, 2) == 2 || size(yerr, 2) == 2
        if ~isempty(xerr)
            plot([x(ii)- xerr(ii, 1), x(ii) + xerr(ii, 2)],[y(ii), y(ii)], 'color', color);
        end
        if ~isempty(yerr)
            plot([x(ii), x(ii)],[y(ii) - yerr(ii, 1), y(ii) + yerr(ii, 2)], 'color', color);
        end
    else
        if ~isempty(xerr)
            plot([x(ii)- xerr(ii), x(ii) + xerr(ii)],[y(ii), y(ii)], 'color', color);
        end
        if ~isempty(yerr)
            plot([x(ii), x(ii)],[y(ii) - yerr(ii), y(ii) + yerr(ii)], 'color', color);
        end
        
    end
end
% set(gca, 'XAxisLocation','origin', 'YAxisLocation','origin');
% first, plot the filter line.

end