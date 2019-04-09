function SAC_utils_plot_several_trials(x, y, color)
% change tick... interesting...
n = size(y, 2);
for ii = 1:1:n
    h = plot(x + (ii - 1) * x(end),y(:,ii), 'color', color);
    if ii > 1
        h.Annotation.LegendInformation.IconDisplayStyle ='off';
    end
    hold on
end
for ii = 1:1:n
    h = plot(ones(2, 1) * ii * x(end), get(gca, 'YLim'), 'k--');
    h.Annotation.LegendInformation.IconDisplayStyle ='off';
end
ConfAxis;

end