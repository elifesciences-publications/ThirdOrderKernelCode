function PlotVScatterTheo(Extv,NoExtv,p)
nv = length(Extv);

%%
% plot the k2 and k3
makeFigure;
subplot(2,3,1);
for vv = 1:1:nv
    % first, draw the k2.
    v = Extv{vv};   
    scatter(v.real,v.HRC,'r.');
    hold on
end
title('all data points : HRC');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,3,2);
for vv = 1:1:nv
    % first, draw the k2.
    v = Extv{vv};   
    scatter(v.real,v.ConvK3(:,1) - v.ConvK3(:,2),'r.');
    
    hold on
end
title('Converging K3 left - right');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,3,3);
for vv = 1:1:nv
    % first, draw the k2.
    v = Extv{vv};   
    scatter(v.real,v.PSK3(:,1) - v.PSK3(:,2),'r.');
    hold on
end
title('Past Skew left - right');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;


subplot(2,3,4);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.HRC,'r.');
    hold on
end
title(['within ',num2str(100 - 2* p), '% data points : HRC']);
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,3,5);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.ConvK3(:,1) - v.ConvK3(:,2),'r.');
    
    hold on
end
title('Converging K3 left - right');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;

subplot(2,3,6);
for vv = 1:1:nv
    % first, draw the k2.
    v = NoExtv{vv};   
    scatter(v.real,v.PSK3(:,1) - v.PSK3(:,2),'r.');
    hold on
end
title('Past Skew left - right');
xlabel('velocity [degree/second]');
ylabel('predicted velocity');
figurePretty;
end
