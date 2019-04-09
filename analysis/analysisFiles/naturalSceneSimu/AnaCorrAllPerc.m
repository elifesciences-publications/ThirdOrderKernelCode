% try to plot the correlation varied with real data.
function AnaCorrAllPerc(v,plotFlag)
p = 0:0.5:20;
withinP = 100 - 2 * p;
np = length(p);

r.HRC = zeros(1,np);
r.k2 = zeros(1,np);
r.k3 = zeros(1,np);
r.k2k3 = zeros(1,np);
r.k2plusk3 = zeros(1,np);
r.k2minusk3 = zeros(1,np);
r.best = zeros(1,np);

weight = zeros(2,np);
sizeData = zeros(1,np);
sizeDataBest = zeros(1,np);

for i = 1:1:np
    
    [~,indHRC] = PerV(p(i),v.HRC);
    [~,indk2] = PerV(p(i),v.k2);
    [~,indk3] = PerV(p(i),v.k3);
    ind = indHRC & indk2 & indk3;
    
    sizeData(i) = sum(ind);
    sizeDataBest(i) = sum(indHRC);
    vHRC = v.HRC(ind);
    vk2 = v.k2(ind);
    vk3 = v.k3(ind);
    vreal = v.real(ind);
    vk2plusk3 = vk2 + vk3;
    vk2minusk3 = vk2 - vk3;
    % HRC
    r.HRC(i) = corr(vHRC,vreal);
    % k2
    r.k2(i) = corr(vk2,vreal);
    % k3
    r.k3(i) = corr(vk3,vreal);
    % k2 + k3
    r.k2plusk3(i) = corr(vk2plusk3,vreal);
    % k2 - k3
    r.k2minusk3(i) = corr(vk2minusk3,vreal);
    % k2 and k3;
    r.k2k3(i) = corr(vk2,vk3);
    
    % calculate the best weigthing of k2 and k3.
    XX = [vk2,vk3];
    weight(:,i) = (vreal'/XX')';
    vbest = (weight(:,i)' * XX')';
    r.best(i) = corr(vbest,vreal);
    
end
if plotFlag
    strInfo.title = 'within X percentile of data';
    strInfo.xlabel = 'percentile';
    PlotXRW(r,weight,withinP,strInfo);
end
end
