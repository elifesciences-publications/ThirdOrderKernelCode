function [r,w] = AnaCombRW(result,semFlag)

if ~semFlag
    nboot = length(result{1});
    
    mean.r.HRC = zeros(ngroup,1);
    mean.r.k2 = zeros(ngroup,1);
    mean.r.k3 = zeros(ngroup,1);
    mean.r.best = zeros(ngroup,1);
    mean.r.k2plusk3 = zeros(ngroup,1);
    mean.w = zeros(ngroup,1);
    
    r.HRC.data = zeros(nboot,1);
    r.k2.data = zeros(nboot,1);
    r.k2.data = zeros(nboot,1);
    r.best.data = zeros(nboot,1);
    r.k2plusk3.data = zeros(nboot,1);
    w.data  = zeros(2,nboot);
    w.ratio = zeros(nboot,1);
    
    for i = 1:1:ngroup
        for  j = 1:1:nboot
            
            r.HRC.data(j) = result{i}(j).r.HRC;
            r.k2.data(j) = result{i}(j).r.k2;
            r.k3.data(j) = result{i}(j).r.k3;
            r.best.data(j) = result{i}(j).r.best;
            r.k2plusk3.data(j) = result{i}(j).r.k2plusk3;
            w.data(:,j) = result{i}(j).weight;
        end
        w.ratio = (w.data(2,:)./w.data(1,:))';
        mean.r.HRC(i) = mean(r.HRC.data);
        mean.r.k2(i) = mean(r.k2.data);
        mean.r.k3(i) = mean(r.k3.data);
        mean.r.best(i) = mean(r.best.data);
        mean.r.k2plusk3(i) = mean(r.k2plusk3.data);
        mean.w(i) = mean(w.ratio);
    end
else
    
    nboot = length(result{1});
    
    r.HRC.mean = zeros(ngroup,1);
    r.HRC.std = zeros(ngroup,1);
    r.HRC.sem = zeros(ngroup,1);
    
    r.k2.mean = zeros(ngroup,1);
    r.k2.std = zeros(ngroup,1);
    r.k2.sem = zeros(ngroup,1);
    
    r.k3.mean = zeros(ngroup,1);
    r.k3.std = zeros(ngroup,1);
    r.k3.sem = zeros(ngroup,1);
    
    r.best.mean = zeros(ngroup,1);
    r.best.std = zeros(ngroup,1);
    r.best.sem = zeros(ngroup,1);
    
    r.k2plusk3.mean = zeros(ngroup,1);
    r.k2plusk3.std = zeros(ngroup,1);
    r.k2plusk3.sem = zeros(ngroup,1);
    
    w.mean = zeros(ngroup,1);
    w.std = zeros(ngroup,1);
    w.sem  = zeros(ngroup,1);
    
    r.HRC.data = zeros(nboot,1);
    r.k2.data = zeros(nboot,1);
    r.k2.data = zeros(nboot,1);
    r.best.data = zeros(nboot,1);
    r.k2plusk3.data = zeros(nboot,1);
    w.data  = zeros(2,nboot);
    w.ratio = zeros(nboot,1);
    
    for i = 1:1:ngroup
        for  j = 1:1:nboot
            
            r.HRC.data(j) = result{i}(j).r.HRC;
            r.k2.data(j) = result{i}(j).r.k2;
            r.k3.data(j) = result{i}(j).r.k3;
            r.best.data(j) = result{i}(j).r.best;
            r.k2plusk3.data(j) = result{i}(j).r.k2plusk3;
            w.data(:,j) = result{i}(j).weight;
        end
        w.ratio = (w.data(2,:)./w.data(1,:))';
        
        r.HRC.mean(i) = mean(r.HRC.data);
        r.HRC.std(i) = std(r.HRC.data);
        r.HRC.sem(i) = r.HRC.std(i)/sqrt(nboot);
        
        r.k2.mean(i) = mean(r.k2.data);
        r.k2.std(i) = std(r.k2.data);
        r.k2.sem(i) = r.k2.std(i)/sqrt(nboot);
        
        r.k3.mean(i) = mean(r.k3.data);
        r.k3.std(i) = std(r.k3.data);
        r.k3.sem(i) = r.k3.std(i)/sqrt(nboot);
        
        r.best.mean(i) = mean(r.best.data);
        r.best.std(i) = std(r.best.data);
        r.best.sem(i) = r.best.std(i)/sqrt(nboot);
        
        r.k2plusk3.mean(i) = mean(r.k2plusk3.data);
        r.k2plusk3.std(i) = std(r.k2plusk3.data);
        r.k2plusk3.sem(i) = r.k2plusk3.std(i)/sqrt(nboot);
        
        
        w.mean(i) = mean(w.ratio);
        w.std(i) = std(w.ratio);
        w.sem(i) = w.std(i)/sqrt(nboot);
    end
    
end
