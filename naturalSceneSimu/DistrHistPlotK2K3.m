function DistrHistPlotK2K3(v,strTitle)
% % strInfo contains title/xlabel/ylabel.legend is included.
% CODE_HRC = 1;
% CODE_K2 = 2;
% CODE_KnumV = numV;
numV = 2;
makeFigure
h = cell(numV,1);
centers = cell(numV,1);
p = cell(numV,1);
h{1} = histogram(abs(v.k2));
hold on
h{2} = histogram(abs(v.k3));

binWidthMin  = 1000000000;

for i = 1:1:numV
    if h{i}.BinWidth < binWidthMin
    binWidthMin = h{i}.BinWidth;
    end
    h{i}.Normalization = 'probability';
end

for i = 1:1:numV
    h{i}.BinWidth = binWidthMin;
end

for i = 1:1:numV
    centers{i,1} = h{i}.BinEdges(1:end-1) + 1/2 * h{i}.BinWidth;
    p{i,1} = h{i}.Values;
end
close(gcf);

makeFigure;
subplot(2,1,1);

for i = 1:1:numV
    loglog(centers{i,1},p{i,1},'lineWidth',1.5);
    hold on
end

legend('k2','k3');
title(strTitle);
xlabel('log predicted velocity [degree/second]');
ylabel('log probability');
figurePretty;
% plot only half of them. before using

subplot(2,2,3)
for i = 1:1:numV
    semilogx(centers{i,1},p{i,1},'lineWidth',1.5);
    hold on
end

legend('k2','k3');
xlabel('log predicted velocity [degree/second]');
ylabel('probability(frequency)');
figurePretty;


subplot(2,4,7)
histogram(v.k2);
title('k2');
xlabel('predicted velocity');
ylabel('counts')

subplot(2,4,8)
histogram(v.k3);
title('k3');
xlabel('predicted velocity');
ylabel('counts')


end