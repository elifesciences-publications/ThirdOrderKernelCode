close all
clear all

%% Validate mixStim
%  Compare output to predicted analytical values

%% test input - "basis vectors"

e = eye(2);
sigma = 4.5;
g = .5;
deltaPhi = 5.1;
omShift = 5;
alphas = linspace(0,12*deltaPhi,500);
for q = 1:500;
    o1(q,:) = mixStim( e(1,:),sigma,alphas(q),0,deltaPhi,omShift );
    o2(q,:) = mixStim( e(2,:),sigma,alphas(q),0,deltaPhi,omShift );
    g1(q,:) = mixStim( e(1,:),sigma,alphas(q),g,deltaPhi,omShift );
    g2(q,:) = mixStim( e(2,:),sigma,alphas(q),g,deltaPhi,omShift );
end

mean(o1,1)
mean(o2,1)
mean(g1,1)
mean(g2,1)

figure; imagesc(o1);
figure; imagesc(o2);
figure; imagesc(g1);
figure; imagesc(g2);