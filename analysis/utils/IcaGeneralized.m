function [ica_sig, ica_filters, ica_A, icSkew, numiter] = IcaGeneralized(signalIn, downsample, framesAnalyze)

if nargin<2
    downsample = true;
    framesAnalyze = 1:size(signalIn, 3);
elseif nargin<3
    framesAnalyze = 1:size(signalIn, 3);
end

%% PCA to reduce problem dimensionality

if downsample
    downsampled = (signalIn(1:2:end-1,1:2:end,:) + ...
        signalIn(2:2:end  ,1:2:end,:) + ...
        signalIn(1:2:end-1,2:2:end,:) + ...
        signalIn(2:2:end,2:2:end,:))/4;
else
    downsampled = signalIn;
end

if size(signalIn, 3)>45
    nPCs = 45;
else
    nPCs = size(signalIn, 3);
end

[mixedsig, mixedfilters, CovEvals] = OmerPCA(downsampled(:,:,framesAnalyze),nPCs);

%% Choose PCs

if length(CovEvals)<nPCs
    PCuse = 1:length(CovEvals);
else
    PCuse = 1:nPCs;
end

%% ICA
nIC = length(PCuse);
mu = 1;

[ica_sig, ica_filters, ica_A, icSkew, numiter] = CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC,[],[],1000);