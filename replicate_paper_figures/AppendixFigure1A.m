function AppendixFigure1A()
x = [-10:0.1:-0.1, 0.1:0.1:10];
y = coth(x) - 1./x;
MakeFigure;
subplot(2,2,1);
plot(y, x, 'r');
ConfAxis('fontSize', 15);
hold on; plot(y, 3 * y, 'b--');
legend('f^{-1}(x), f(x) = coth(x) - 1/x', '3x');
set(gca, 'XAxisLocation','Origin', 'YAxisLocation','Origin');
set(gca, 'XLim', [-1.1,1.1]);
set(gca, 'XTick', [-1,-0.5, 0.5, 1], 'XTickLabel',{'-1', '-0.5','0.5','1'});
% set(gca, 'YTick', [-3,-1.5, 1.5, 3], 'XTickLabel',{'-1', '-0.5','0.5','1'});
end

