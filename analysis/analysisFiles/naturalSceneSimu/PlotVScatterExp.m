function PlotVScatterExp(Extv,NoExtv,p)
nv = length(Extv);

% plot the k2 and k3
makeFigure;
subplot(2,3,1);
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

subplot(2,3,2);
for vv = 1:1:nv
    % first, draw the k2.
    v = Extv{vv};   
    scatter(v.real,v.k3,'r.');
    hold on
end
title('all data points : K3');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,3,3)
for vv = 1:1:nv
    % first, draw the k2.
    v = Extv{vv};   
    scatter(v.real,v.k3+v.k2,'r.');
    hold on
end
title('all data points : K3+K2');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;


subplot(2,3,4);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.k2,'r.');
    hold on
end
title(['within ',num2str(100 - 2* p), '% data points : K2']);
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,3,5);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.k3,'r.');
    hold on
end
title(['K3']);
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,3,6);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.k3+v.k2,'r.');
    hold on
end
title(['K3 + K2']);
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

end