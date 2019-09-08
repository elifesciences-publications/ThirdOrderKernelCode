function [result]  = AnalysizeCorrSpearman(vHRC,vk2,vk3,vreal)

% HRC
r.HRC = corr(vHRC,vreal,'type','Spearman');
% k2
r.k2 = corr(vk2,vreal,'type','Spearman');
% k3
r.k3 = corr(vk3,vreal,'type','Spearman');
% k2 + k3
vk2plusk3 = vk2 + vk3;
r.k2plusk3 = corr(vk2plusk3,vreal,'type','Spearman');
% k2 and k3;
% calculate the best weigthing of k2 and k3.

% you have to check whether the algorithm is correct or not.

% no best anymore.... too bad...
XX = [vk2,vk3];
weight = (vreal'/XX')';
weight(:,1) = 0;
vbest = (weight' * XX')';
r.best = corr(vbest,vreal);
r.best = 0;

% correlation between hrc, k2, and k3.
% first element is the correlation between HRC and k2
% second element is the correlation between HRC and k3
% second element is the correlation btween k2 and k3
% is that good to arrange them in a array? not good at all! confusing and
% easy to forget.
% use some smart code to solve this problem, instead of ...
mut.r = zeros(1,3);
mut.r(1) = corr(vHRC,vk2,'type','Spearman');
mut.r(2) = corr(vHRC,vk3,'type','Spearman');
mut.r(3) = corr(vk2,vk3,'type','Spearman');

result.r = r;
result.weight = weight;
result.mut = mut;
end