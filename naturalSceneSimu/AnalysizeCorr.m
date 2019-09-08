function [result]  = AnalysizeCorr(vk2,vk3,vreal)

% HRC
% r.HRC = corr(vHRC,vreal);
% k2
r.k2 = corr(vk2,vreal);
% k3
r.k3 = corr(vk3,vreal);
% k2 + k3
vk2plusk3 = vk2 + vk3;
r.k2plusk3 = corr(vk2plusk3,vreal);
% k2 and k3;
% calculate the best weigthing of k2 and k3.

% you have to check whether the algorithm is correct or not.

XX = [vk2,vk3];
weight = (vreal'/XX')';
vbest = (weight' * XX')';
r.best = corr(vbest,vreal);

% correlation between hrc, k2, and k3.
% first element is the correlation between HRC and k2
% second element is the correlation between HRC and k3
% second element is the correlation btween k2 and k3
% is that good to arrange them in a array? not good at all! confusing and
% easy to forget.
% use some smart code to solve this problem, instead of ...

% mut.HRCk2 = corr(vHRC,vk2);
% mut.HRCk3 = corr(vHRC,vk3);
mut.k2k3 = corr(vk2,vk3);

result.r = r;
result.weight = weight;
% result.mut = mut;
end