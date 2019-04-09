% close all
% clear all

%% Custom colormap for two d filter visualization

%% 

grad_up(51:100,1) = linspace(0,1,50)';
grad_down = flipud(grad_up);

mymap = ones(100,3);
mymap(:,1) =  mymap(:,1) - grad_down;
mymap(:,2) =  mymap(:,2) - grad_up;
mymap(:,3) = mymap(:,3) - grad_up;
mymap(:,2) = mymap(:,2) - grad_down;

%%

% maxLen = 50;
% filtx = linspace(1,maxLen,maxLen);
% lpfun = @(x,tau) x.*exp(-x/tau);
% lpslow = lpfun(filtx,10);
% lpfast = lpfun(filtx,5);
% infilt = lpslow'*lpfast - lpfast'*lpslow;

%%

% figure; 
% imagesc(infilt); 
% colormap(mymap);
