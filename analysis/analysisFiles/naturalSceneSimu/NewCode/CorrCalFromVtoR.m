function [r,weight,mutR] = CorrCalFromVtoR(v)
% first colum is real, second is vk2, third is vk3
r.k2 = corr(v(:,1),v(:,2));
r.k3 = corr(v(:,1),v(:,3));
r.k2plusk3 = corr(v(:,1),v(:,3)+v(:,2));

weight = v(:,2:3)\v(:,1);
vbest = (v(:,2:3)* weight);
r.best= corr(vbest,v(:,1));

mutR = corr(v(:,2),v(:,3));

% draw picture to understand what is going on....

% MakeFigure;
% subplot(2,2,1)
% scatter(v(:,1),v(:,2));
% title(['r_k2: ', num2str(r.k2)])
% subplot(2,2,2)
% scatter(v(:,1),v(:,3));
% title(['r_k3: ', num2str(r.k3)])
end

