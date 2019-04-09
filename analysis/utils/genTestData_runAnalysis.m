close all
clear all

%% Generate test data for run_analysis suite
%% Respdata

frameAxis = [1:1:72001]'; % 2nd col
timeAxis = linspace(.271,1200.886,72001)'; % 1st col

% 3-7 turning, 8-12 walking, 18 mouse reads
mouseReads = [ 6 repmat([7 6],[1 72000/2]) ]';
respSkeleton = [ 1; 1*ones(72000/4,1); -1*ones(72000/4,1); 3*ones(72000/4,1); ...
    -3*ones(72000/4,1) ];
respSkeleton = repmat(respSkeleton,[1 5]);
respSkeleton = respSkeleton + .1*randn(size(respSkeleton));
respDataMat = zeros(72001,18);
respDataMat(:,1) = timeAxis;
respDataMat(:,2) = frameAxis;
respDataMat(:,3:7) = respSkeleton;
respDataMat(:,18) = mouseReads;


%% Stimdata
% Same first two cols as respdata, epoch number in col 3, the rest are
% specific to the stimulus.

whichEpoch = [ 1; 1*ones(72000/4,1); 2*ones(72000/4,1); 3*ones(72000/4,1); ...
    4*ones(72000/4,1) ];
stimDataMat = zeros(72001,18);
stimDataMat(:,1) = timeAxis;
stimDataMat(:,2) = frameAxis;
stimDataMat(:,3) = whichEpoch;


%% Chosenparams
% "params" is a 1xnEpochs struct array with fields corresponding to each
% epoch, including at minimum stimtype, duration, fpu

nEpochs = 4;
for q = 1:nEpochs
    params(q).stimtype = 1;
    params(q).duration = 30;
    params(q).fpu = 6;
end

%% Save it

HPathIn = fopen('dataPath.csv');
C = textscan(HPathIn,'%s');
dataFolder = C{1}{1};
manualName = 'standard';
fullFilePath = sprintf('%s/testData/%s',dataFolder,manualName);

if ~isdir(fullFilePath)
    mkdir(fullFilePath);              
end 
            
fullRespName = sprintf('%s/respdata.csv',fullFilePath);
fullStimName = sprintf('%s/stimdata.csv',fullFilePath);
fullParamsName = sprintf('%s/chosenparams.mat',fullFilePath);

xlswrite(fullRespName,respDataMat);
xlswrite(fullStimName,stimDataMat);
save(fullParamsName,'params');
