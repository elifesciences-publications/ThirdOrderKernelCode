function ScatterV(v)
n = 3;
vPlot = cell(n,1);
vPlot{1} = v.HRC;
vPlot{2} = v.k2;
vPlot{3} = v.k3;

titleStr = cell(n,1);
titleStr{1} = 'HRC';
titleStr{2} = 'k2';
titleStr{3} = 'k3';

makeFigure;
for i = 1:1:n
    subplot(2,2,i)
    scatter(v.real,vPlot{i},'r.');
     title(titleStr{i});
        xlabel('velocity');
        ylabel('predicted velocity');
        figurePretty;
end
end