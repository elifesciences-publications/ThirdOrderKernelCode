close all
clear all

tic
%% Test impact of mixing inputs to a fly responding to a kernel

%% Run Trial
%% Parameters

% ommatidia
g = .2; deltaPhi = 5; sig = 5.7 / 2.3548; numAlpha = 10;
alphas = linspace(0,4*deltaPhi,numAlpha);
% response
dur = 1e4; whichOrder = [0 1 1]; maxTau = 50;

%% Generate filters

filters = exampleFilters(whichOrder,maxTau);

%% generate random inputs

inVar = 1.3; noiseVar = 0;
stimTraces = [ randInput(inVar,2,dur)' randInput(inVar,2,dur)' ];

%% mix inputs

for q = 1:numAlpha
    mixedStimTraces(:,:,q) = mixStim( stimTraces,sig,alphas(q),g,deltaPhi,deltaPhi );
end

%% generate response

for q = 1:numAlpha
    resp(:,q) = flyResp(whichOrder,filters,maxTau,mixedStimTraces(:,1,q),mixedStimTraces(:,2,q),0 );
%     resp(:,q) = flyResp(whichOrder,filters,maxTau,stimTraces(:,1),stimTraces(:,2),noiseVar );
end
respAvg = mean(resp,2);
respAvg = respAvg + sqrt(noiseVar)*randn(size(respAvg));
% Decision to put noise here rather than in resp so that it doesn't get
% averaged out. Probably more realistic. 

%% Extract Filter
%% Mean subtract evertthing

respAvg = respAvg - mean(respAvg);
% mixStim = mean(mixedStimTraces,3);
% mixStim = mixStim - repmat(mean(mixStim,1),[dur 1 1]);

%% Generate Polynomial Matrix

startDiag = 1; endDiag = 15; wingSpan = 10;
[ locs,margin,seqInd ] = pickPol ( whichOrder,startDiag,endDiag,wingSpan );

cutResp = respAvg(margin:end);
respLen = dur-(margin-1);

polMat = zeros(respLen,sum(seqInd),size(mixedStimTraces,3));
polMatIndex = 0;
for rr = 1:seqInd(1)
    polMatIndex = polMatIndex + 1;
    polMat(:,polMatIndex,:) = mixedStimTraces(locs{1}.x(rr):locs{1}.x(rr)+respLen-1,1,:);
end
for rr = 1:seqInd(2)
    polMatIndex = polMatIndex + 1;
    polMat(:,polMatIndex,:) = mixedStimTraces(locs{2}.x1(rr):locs{2}.x1(rr)+respLen-1,1,:) .* ...
         mixedStimTraces(locs{2}.x2(rr):locs{2}.x2(rr)+respLen-1,2,:);
end
for rr = 1:seqInd(3)
    polMatIndex = polMatIndex + 1;
    polMat(:,polMatIndex,:) = mixedStimTraces(locs{3}.x1(rr):locs{3}.x1(rr)+respLen-1,1,:) .* ...
         mixedStimTraces(locs{3}.x2(rr):locs{3}.x2(rr)+respLen-1,1,:) .* ...
         mixedStimTraces(locs{3}.y(rr):locs{3}.y(rr)+respLen-1,2,:);
end

%% Average (after taking polynomial combinations)
polMat = mean(polMat,3);

%% XCorr

if whichOrder(1)
    stimRoll = rollup(stimTraces(:,1),maxTau);
    xCorr_kernel{1} = stimRoll*respAvg(maxTau:end);
    xCorr_kernel{1} = xCorr_kernel{1} / inVar / (dur - (maxTau-1));
end

if whichOrder(2) 
    xCorr_kernel{2} = twod_fast(maxTau,inVar,stimTraces(:,1),stimTraces(:,2),respAvg);
    figure; imagesc(reshape(xCorr_kernel{2},[maxTau maxTau]));
end

if whichOrder(3) 
    xCorr_kernel{3} = threed_fast(maxTau,inVar,stimTraces(:,1),stimTraces(:,1),stimTraces(:,2),respAvg);
    threeDvisualize_slices(maxTau,9,reshape(xCorr_kernel{3},[maxTau maxTau maxTau]));
end

%% OLS 

OLS_pols = (polMat'*polMat)\polMat'*cutResp;

OLS_2o = zeros(margin,margin);
OLS_3o = zeros(margin,margin,margin);

if whichOrder(2)
    for rr = 1:seqInd(2)
        thisX = locs{2}.tau1(rr) + 1;
        thisY = locs{2}.tau2(rr) + 1;
        OLS_2o(thisX,thisY) = OLS_pols(rr);
    end
end
        
if whichOrder(3)
    for rr = 1:seqInd(3)
        thisX1 = locs{3}.tau1(rr) + 1;
        thisX2 = locs{3}.tau2(rr) + 1;
        thisY = locs{3}.tau3(rr) + 1;
        OLS_3o(thisX1,thisX2,thisY) = OLS_pols(rr);
    end
end

%% Visualize

figure; imagesc(reshape(OLS_2o,[margin margin]));
threeDvisualize_slices(margin,9,OLS_3o);

toc