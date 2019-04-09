% % first, bin the data according to vreal
vin = res.v;
% separte data of uniformly sampled value into different velocity range.
% 
nbin = 50;
vBinned = linspace(min(vin.real),max(vin.real),nbin+1);
vBinned = [vBinned(1:end - 1);vBinned(2:end)];
vout = cell(nbin,1);

[count,ind] = histc(vin.real,vBinned(2,:));

for i = 1:1:nbin
    % find all those values related to a certain range in vreal;
    % get the indices of v is sorted into the ith bin.
    indi = ind == i;
    vout{i}.real = vin.real(indi);
    vout{i}.k2 = vin.k2(indi);
    vout{i}.k3 = vin.k3(indi);
    vout{i}.HRC = vin.HRC(indi);
  %  ScatterVBinned(vout{i});
end
% %
% %% plot the vscatter for these 100 situation;
%% rank order...

%%
Temp = cell(nbin,1);
r.k2 =zeros(nbin,1);
r.k3 =zeros(nbin,1);
r.k2plusk3 = zeros(nbin,1);
r.best = zeros(nbin,1);
weight = zeros(2,nbin);
mut.k2k3 = zeros(nbin,1);
for i = 1:1:nbin
    Temp{i} = AnalysizeCorr(vout{i}.HRC,vout{i}.k2,vout{i}.k3,vout{i}.real);
    r.k2(i) = Temp{i}.r.k2;
    r.k3(i) = Temp{i}.r.k3;
    r.k2plusk3(i) = Temp{i}.r.k2plusk3;
    r.best(i) = Temp{i}.r.best;
    weight(:,i) = Temp{i}.weight;
    mut.k2k3(i) = Temp{i}.mut.k2k3;
end
% 
%%
strInfo = {};
xData = vBinned(2,:);
strInfo.xlabel = 'velocity [degree/second]';
strInfo.title = {};
PlotXRW(r,weight,mut,xData,strInfo)
% 
% % it is uniformly distributed, and the 