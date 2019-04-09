function DistrHistPlot(vHRC,vk2,vk3,strTitle)
% % strInfo contains title/xlabel/ylabel.legend is included.
% CODE_HRC = 1;
% CODE_K2 = 2;
% CODE_K3 = 3;
% this could be discarded, because HRC has no unit itself. could not be
% plot with k2/k3/
makeFigure
h = cell(3,1);
centers = cell(3,1);
p = cell(3,1);
h{1} = histogram(abs(vHRC));
hold on
h{2} = histogram(abs(vk2));
h{3} = histogram(abs(vk3));

binWidthMin  = 1000000000;

for i = 1:1:3
    if h{i}.BinWidth < binWidthMin
    binWidthMin = h{i}.BinWidth;
    end
    h{i}.Normalization = 'probability';
end

for i = 1:1:3
    h{i}.BinWidth = binWidthMin;
end

for i = 1:1:3
    centers{i,1} = h{i}.BinEdges(1:end-1) + 1/2 * h{i}.BinWidth;
    p{i,1} = h{i}.Values;
end
close(gcf);

makeFigure;
subplot(2,1,1);

for i = 1:1:3
    loglog(centers{i,1},p{i,1},'lineWidth',1.5);
    hold on
end

legend('HRC','k2','k3');
title(strTitle);
xlabel('log predicted velocity [degree/second]');
ylabel('log probability');
figurePretty;
% plot only half of them. before using

subplot(2,2,3)
for i = 1:1:3
    semilogx(centers{i,1},p{i,1},'lineWidth',1.5);
    hold on
end

legend('HRC','k2','k3');
xlabel('log predicted velocity [degree/second]');
ylabel('probability(frequency)');
figurePretty;

subplot(2,6,10)
histogram(vHRC);
title('HRC');
xlabel('predicted velocity');
ylabel('counts');

subplot(2,6,11)
histogram(vk2);
title('k2');
xlabel('predicted velocity');
ylabel('counts')

subplot(2,6,12)
histogram(vk3);
title('k3');
xlabel('predicted velocity');
ylabel('counts')


end