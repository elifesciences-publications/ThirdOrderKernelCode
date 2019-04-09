% testing script to check whether my ols is correct.
n = 10000;
vk2 = rand(n,1);
vk3 = rand(n,1);
vreal = vk2 + vk3 +  rand(n,1);

XX = [vk2,vk3];
weight = (vreal'/XX')';
vbest = (weight' * XX')';
r.best = corr(vbest,vreal)

vk2plusk3 = vk2 + vk3;
r = corr(vk2plusk3,vreal)