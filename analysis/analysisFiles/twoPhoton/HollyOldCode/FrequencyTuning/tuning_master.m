% close all
clear all
clc

%% TUNING CURVES MASTER SCRIPT
% Runs the script tp_kernelTuning on sample kernels generated below.

%% Simulating 1 ROI, 10 multiBars, so input kernels should be M x 10 x 1 
% (maxTau x nMultiBars x nRoi).

%% Example linear filter - 2o low pass filters with different time constants
% and overall signs
nRoi = 1;
nMultiBars = 10; % example filters pretend 10-bar stimulus: replace with 20 
                 % for 20 bar data, etc.
maxTaus = [ 60 30 ]; % M of first, then second order filter
fs = 60; % stimulus update rate
lpFun = @(x,tau) x.^2 .* exp(-x/tau) / tau^2;
lpSigns = [ 0 0 1 1 -1 -1 0 0 0 0 ];
lpTaus = [ 1 1 40 80 20 40 1 1 1 1 ];
lpAxis = [1:maxTaus(1)]' * 1000/fs; % 1000 because we are in ms
linearKernels = [];
for q = 1:nMultiBars
    linearKernels = cat(2,linearKernels,lpSigns(q) * lpFun(lpAxis,lpTaus(q)));
end
figure; imagesc(linearKernels)

%% Example second-order filter
lpAxis = [1:maxTaus(2)]' * 1000/fs;
lp1 = lpFun(lpAxis,20);
lp2 = lpFun(lpAxis,10);
pre2o = lp1*lp2' - lp2*lp1';
figure; imagesc(pre2o);
kernelStrength = [ 0 0 0 .5 .5 0 0 0 0 0 0 ];
% format the second order kernels the way would be in data- an array of 10
% kernels, 3 of which (bars 3,4,5) are the real kernel and the rest of
% which are 0.
quadKernels = [];
for q = 1:nMultiBars
%         thisPre = pre2o(:) .* (pre2o(:) * (-1)^q > 0);
    thisPre = pre2o(:);
    quadKernels = cat(2,quadKernels,thisPre*kernelStrength(q));
end

%% Compute tuning curves, analytically and with simulations
tp_kernelTuning( linearKernels, meanKernel(:,1), [3:6],'lambda',[ 30 ])
