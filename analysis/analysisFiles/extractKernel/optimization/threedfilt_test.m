close all
clear all

%% Testing 3D convolution and filter extraction scripts

%% Create 3D kernel

maxLen = 50;
dur = 1e5;
var = 1;
dist = 1;

% example 3D filter
[X Y Z] = meshgrid(linspace(1,maxLen,maxLen),linspace(1,maxLen,maxLen),...
    linspace(1,maxLen,maxLen));
omx = .02; omy = .01; omz = .1;
infilt = cos(omx*X.^2 + omy*Y.^2 + omz*Z.^2);
% infilt = zeros(maxLen,maxLen,maxLen);
% infilt(1,1,1) = 1;

% threeDvisualize_slices(maxLen,9,infilt); % cool

% generate input stims
x = randInput(var,dist,dur)';
y = randInput(var,dist,dur)';

%% Try response prediction

tic
resp = specialthreedfilt(maxLen,x,x,y,infilt(:));
toc

%% Now try kernel extraction

tic
exfiltfull = threed_fast(maxLen,var,x(maxLen:dur),x(maxLen:dur),y(maxLen:dur),resp);
exfiltfull = reshape(exfiltfull,maxLen,maxLen,maxLen);
exfiltdiag = hugDiagonal3(maxLen,var,x(maxLen:dur),x(maxLen:dur),y(maxLen:dur),resp);
exfiltdiag = reshape(exfiltdiag,maxLen,maxLen,maxLen);

% killDiag = ones(maxLen,maxLen,maxLen);
% for q = 1:maxLen
%     killDiag(:,:,q) = killDiag(:,:,q) - eye(maxLen,maxLen);
% end
% exfilt = exfilt.*killDiag;

% threeDvisualize_slices(maxLen,9,infilt);
threeDvisualize_slices(maxLen,9,exfiltfull);
threeDvisualize_slices(maxLen,9,exfiltdiag);
threeDvisualize_slices(maxLen,9,exfiltfull - exfiltdiag);
toc


%% Rsq should be 1

% D.data.resp = zeros(dur,5,1);
% D.data.stim(:,14,1) = x;
% D.data.stim(:,15,1) = y;
% D.data.resp(maxLen:dur,3:7,1) = repmat(resp',1,5);
% D.data.params.var = var;
% 
% clearvars -except D infilt;

% currdir = cd;
% cd('/Users/hollymandel/Documents/Lab/logbook/summer14/r2');
% Rsq = kernel_r2(infilt,D)
% cd(currdir);