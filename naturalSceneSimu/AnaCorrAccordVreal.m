function [r,weight,sampleV] = AnaCorrAccordVreal(v,p)
plotFlag = 1;
% the range of v is compuated outside the funtion?
stdV = std(v.real);
if stdV * 3 > 1024
    stdV = 1024/3;
end

sampleRStart = (0:0.3:3)';
sampleREnd = sampleRStart + 0.1;
sampleR = [sampleRStart,sampleREnd];
nV = size(sampleR,1);
sampleV = zeros(nV,1);

r.HRC = zeros(1,nV);
r.k2 = zeros(1,nV);
r.k3 = zeros(1,nV);
r.k2k3 = zeros(1,nV);
r.k2plusk3 = zeros(1,nV);
r.best = zeros(1,nV);

weight = zeros(2,nV);
sizeData = zeros(1,nV);
sizeDataBest = zeros(1,nV);

[~,indHRC] = PerV(p,v.HRC);
[~,indk2] = PerV(p,v.k2);
[~,indk3] = PerV(p,v.k3);

for i = 1:1:nV
    startN = - sampleR(i,2) *  stdV;
    endN = - sampleR(i,1) *  stdV;
    startP = sampleR(i,1) * stdV;
    endP = sampleR(i,2) * stdV;
    sampleV(i) = mean([startP,endP]);
    
    indv = (startN < v.real & v.real < endN) | (startP < v.real & v.real < endP);
    ind = indv & indHRC & indk2 & indk3;
    vHRC = v.HRC(ind);
    vk2 = v.k2(ind);
    vk3 = v.k3(ind);
    vreal = v.real(ind);
    vk2plusk3 = vk2 + vk3;
    
    sizeData(i) = sum(ind);
    sizeDataBest(i) = sum(indv);
    
    % HRC
    r.HRC(i) = corr(vHRC,vreal);
    % k2
    r.k2(i) = corr(vk2,vreal);
    % k3
    r.k3(i) = corr(vk3,vreal);
    % k2 + k3
    r.k2plusk3(i) = corr(vk2plusk3,vreal);
    % k2 and k3;
    r.k2k3(i) = corr(vk2,vk3);
    
    
    XX = [vk2,vk3];
    weight(:,i) = (vreal'/XX')';
    vbest = (weight(:,i)' * XX')';
    r.best(i) = corr(vbest,vreal);
    
    if i == 1 || i == 4 || i == 7
        if plotFlag == 1
            strTitle = ['histogram of Vestimation when V is ranging from ', num2str(startN),' to ',num2str(endN),' and from ',num2str(startP), ' to ',num2str(endP)];
            DistrHistPlot(vHRC,vk2,vk3,strTitle);
        end
    end
end

