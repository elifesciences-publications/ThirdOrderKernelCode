function bar_handle = barplot_juyue_color(x, y, sem, varargin)
%% different bar have different colors,
color_bank = zeros(length(x), 3);

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
bar_handle  = cell(length(x), 1);
hold on
for ii = 1:1:length(x)
    bar_handle{ii} = bar(x(ii), y(ii));
    if ~isempty(sem)
        plot([x(ii), x(ii)], [y(ii) + sem(ii), y(ii) - sem(ii)],'k');
    end
    bar_handle{ii}.FaceColor= color_bank(ii, :);
    bar_handle{ii}.BarWidth = 0.5;
end
end