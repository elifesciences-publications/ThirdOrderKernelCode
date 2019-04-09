function PlotErrorBar_Juyue(x, y, err, varargin)
% error would be error. up y and below y.
for ii = 1:1:length(x)
    hold on
    h = plot([x(ii),x(ii)], [y(ii) + err(ii), y(ii) - err(ii)],'k-');
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
hold off
end