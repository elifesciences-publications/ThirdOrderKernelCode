p = 1;
r.HRC = zeros(ngroup,1);
r.k2 = zeros(ngroup,1);
r.k3 = zeros(ngroup,1);
r.best = zeros(ngroup,1);
r.k2plusk3 = zeros(ngroup,1);

weight = zeros(2,ngroup);

for i = 1:1:ngroup
    v = D{i}.v;
    a = AnaIndividual(v,p,0);
    weight(:,i) = a.weight;
    r.HRC(i) = a.r.HRC;
    r.k2(i) = a.r.k2;
    r.k3(i) = a.r.k3;
    r.best(i) = a.r.best;
    r.k2plusk3(i) = a.r.k2plusk3;
    
end

%%
 strInfo.title = ['real velocity are drawn from different distribution'];
 strInfo.xlabel = ['std of velocity']; 
 PlotXRW(r,weight,stdVBank,strInfo);
 
 %%
 strInfo.xlabel = ['log std of velocity'];
 SemilogXRW(r,weight,stdVBank,strInfo);