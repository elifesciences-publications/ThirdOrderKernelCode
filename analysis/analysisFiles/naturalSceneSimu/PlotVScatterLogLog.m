function PlotVScatter(Extv,NoExtv,vValue)
nv = length(Extv);

% plot the k2 and k3
makeFigure;
subplot(2,2,1);
for vv = 1:1:nv
    % first, draw the k2.
    v = Extv{vv};   
    scatter(v.real,v.k2,'r.');
    hold on
end
title('all data points : K2');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,2,2);
for vv = 1:1:nv
    % first, draw the k2.
    v = Extv{vv};   
    scatter(v.real,v.k3,'r.');
    hold on
end
title('all data points : K2');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,2,3);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.k2,'r.');
    hold on
end
title('all data points : K2');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,2,4);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.k3,'r.');
    hold on
end
title('all data points : K2');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

end