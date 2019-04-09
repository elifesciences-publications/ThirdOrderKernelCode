close all
clear all

%% Testing twod_filt filtering function and twod_fast filter extraction 
%  function.

%% Create 2D kernel

maxLen = 50;
dur = 720000;
var = 1;
dist = 3;

% example 2D filter
filtx = linspace(1,maxLen,maxLen);
lpfun = @(x,tau) x.*exp(-x/tau);
lpslow = lpfun(filtx,10);
lpfast = lpfun(filtx,5);
% infilt = lpslow'*lpfast - lpfast'*lpslow;
infilt = rand(maxLen);

% generate input stims
x = randInput(var,dist,dur)';
y = randInput(var,dist,dur)';

%% Try response prediction

resp = specialtwodfilt(infilt,x,y);

%% Now try kernel extraction

exfilt = twod_fast(maxLen,var,x(maxLen:dur),y(maxLen:dur),resp);
exfilt = reshape(exfilt,maxLen,maxLen);

% infilt = twod_fast(maxLen,var,x(maxLen:dur),y(maxLen:dur),resp);
% exfilt = hugDiagonal2(maxLen,var,x(maxLen:dur),y(maxLen:dur),resp);
% infilt = reshape(infilt,maxLen,maxLen);
% exfilt = reshape(exfilt,maxLen,maxLen);

%% Moment of truth

figure; subplot(1,2,1); imagesc(infilt); title('Expectation'); axis xy;
subplot(1,2,2); imagesc(exfilt); title('Reality'); axis xy;

figure; imagesc(exfilt-infilt); title('Difference (Ex - In)'); axis xy;

%% Rsq should be 1

pred_resp = specialtwodfilt(exfilt,x,y);

xy = resp'*pred_resp;
x_sq = resp(maxLen:end)'*resp(maxLen:end);
y_sq = pred_resp(maxLen:end)'*resp(maxLen:end);

Rsq = xy^2 / x_sq / y_sq; % seems pretty good 
