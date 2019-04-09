function HistNP(v)
% there are three kinds of velocity;
% in the future, there might be more.
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
    indp = v.real > 0;
    indn = ~indp;
    pv = vPlot{i}(indp);
    nv = vPlot{i}(indn);
    
    subplot(2,2,i)
    [centers,f] = ComputePDF(pv);
    plot(centers,f);
    hold on
    [centers,f] = ComputePDF(nv);
    plot(centers,f);
    title(titleStr{i});
    xlabel('predicted velocity');
    ylabel('frequency');
    legend('positive','negative');
    figurePretty;
    
end