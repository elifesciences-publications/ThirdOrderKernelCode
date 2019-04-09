function PlotErrorBar_Juyue(x, y, err, varargin)
% error would be error. up y and below y.
for ii = 1:1:length(x)
    hold on
    plot([x(ii),x(ii)], [y(ii) + err(ii), y(ii) - err(ii)],'k-');
end
hold off
end