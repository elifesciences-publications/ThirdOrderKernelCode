function [ R ] = xVal( order,varargin )
% Tests how well the input kernel explains the variance of the given data.

whichBehav = 'turn';
maxTau = 50;
interp = 'linear';
which1 = 1; % defaults to using x filter if you're looking at 1D
compareMean = 1;
noDiag = 0;
noiseThresh = 0;
which = [2 4 5 6];

HPathIn = fopen('dataPath.csv');
C = textscan(HPathIn,'%s');
dataFolder = C{1}{1};
kernelFolder = C{1}{3};

for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
    
%% Get input kernel

if ~exist('inKernel')
    Z = masterKernels(order,'which',which);
    switch order
        case 1
            inKernel = Z.kernels.meanKernels.k1_x;
            maxLen = length(inKernel);
        case 2
            inKernel = Z.kernels.meanKernels.k2_sym;
            maxLen = round(length(inKernel.^(1/2)));
        case 3
            inKernel = Z.kernels.meanKernels.k3_sym;
            maxLen = round(length(inKernel.^(1/3)));
            if noDiag == 1
                inKernel = removeDiag(inKernel);
            elseif noDiag == 2
                inKernel = removeDiag3(inKernel);
            end
    end
else 
    maxLen = round(length(inKernel.^(1./order)));
end

inKernel = inKernel .* (abs(inKernel) >= noiseThresh);

%% Get data to validate

if exist('testData','var')   
    D = testData;      
    OD = organizeData(D,'removeOutliers',0,'meanSubtract',1,'rollSize',1,'normMouseReads',0);
elseif exist('inPaths','var')
    D = grabData(inPaths);
    OD = organizeData(D,'removeOutliers',0,'meanSubtract',1,'rollSize',1);
else
    D = grabData();
    OD = organizeData(D,'removeOutliers',0,'meanSubtract',1,'rollSize',1);
end
    
D.analysis.analysisParams.whichBehav = whichBehav;
D.analysis.analysisParams.maxTau = maxTau;
D.analysis.analysisParams.interp = interp;     
D.kernelData.whichFile =  diff(OD.rig) < 1;
D.kernelData.whichFile = [0 cumsum(D.kernelData.whichFile)] + 1;

for q = 1:OD.numFiles
    kernelData(q) = getKernelData(D,OD,q);
end

%% Execute r2 calculation. 
%  A different script than I had earlier. It's nice to do this on the
%  output of kernelData (rather than D) because this takes into account
%  interpolation/downsampling.

%% generate predicted response from kernel

inx1 = kernelData(1).stimTraces(:,1); 
% Written under assumption that the input stimulus is consistent for all.
% You could go through and pull out individual input stimulus within the
% loop below, but should be comparing consistent trials anyway, so this
% saves time. 
inx2 = kernelData(1).stimTraces(:,2);

switch order
    case 1
        if which1 == 1
            out = filter(inKernel,1,inx1);
        elseif which1 == 2
            out = filter(inKernel,1,inx2);
        end
        out = out(maxLen:end);
    case 2
        out = specialtwodfilt(inKernel,inx1,inx2);
    case 3
        out = specialthreedfilt(maxLen,inx1,inx1,inx2,inKernel(:))';
end

%% calculate mean value from responses

catAll = kernelData(1).turnTraces;
if OD.numFiles > 1
    for q = 2:OD.numFiles
        catAll = cat(2,catAll,kernelData(q).turnTraces);
    end
end
meanval = mean(catAll,2);
meanval = meanval(maxLen:end);
R.saveData.resp = catAll;

%% Calculate R2

flyID = 0;

for z = 1:OD.numFiles
    for a = 1:size(kernelData(z).turnTraces,2)
        flyID = flyID + 1;
       
        %% Pull response for this fly

        evalc(['resp = kernelData(z).' sprintf('%s',whichBehav) 'Traces(maxLen:end,a);']);
        %resp = resp - mean(resp); % De-meaning, since that's what we did during
                                  % filter extraction
                                  % interesting - de-meaning here decreases
                                  % r2!! think more about this.        
        
        %% Calculate r and save
        kernel_r(flyID) = out' * resp / sqrt(out'*out * resp'*resp);
        mean_r(flyID) = meanval'*resp / sqrt(meanval'*meanval * resp'*resp);
    
    end
end
 
R.kernel_r = kernel_r;
R.mean_r = mean_r;
R.kernel_rsq_avg = mean(kernel_r.*kernel_r);
R.mean_rsq_avg = mean(mean_r.*mean_r);
R.kernelUsed = inKernel;
R.saveData.meanval = meanval;
R.saveData.out = out;

end

