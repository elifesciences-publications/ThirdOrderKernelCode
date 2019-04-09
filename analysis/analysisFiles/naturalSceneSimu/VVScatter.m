function [vestnew,ind] = VVScatter(v,vest,p)
% 
% plot the vest versus v, but in order to show the main data, 
% show the result within the range
% and return the data within the range.
if p < 1
    p = p * 100;
end
percLow = prctile(vest,p);
percHigh = prctile(vest,100 - p);

ind = vest > percLow & vest < percHigh;
vestnew = vest(ind);

makeFigure;
subplot(2,2,1)
scatter(v,vest,'r.');
xlabel('velocity of the image');
ylabel('estimated velocity');
figurePretty;
title('original');

subplot(2,2,2)
hist(vest,100)
xlabel('estimated velocity');
ylabel('count');
title([num2str(p), 'th percentile :',num2str(percLow),', ', num2str(100 - p), 'th percentile :',num2str(percHigh)])
figurePretty;


subplot(2,2,3)
scatter(v(ind),vest(ind),'r.');
xlabel('velocity of the image');
ylabel('estimated velocity');
figurePretty;
title(['from ',num2str(p),'th percentile to ', num2str(100-p),'th percentile']);

subplot(2,2,4);
hist(vest(ind),100);
xlabel('estimated velocity');
ylabel('count');
figurePretty;
end