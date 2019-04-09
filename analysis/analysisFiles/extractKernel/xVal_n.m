function [ R ] = xVal_n( order,N,varargin )
% Tests how well the input kernel explains the variance of the given data.

whichBehav = 'turn';
maxTau = 50;
interp = 'linear';
which1 = 1; % defaults to using x filter if you're looking at 1D
compareMean = 1;
noDiag = 0;
noiseThresh = 0;
which = [2 3 5];
isOLS =  0;
removeOutliers = 1;

HPathIn = fopen('dataPath.csv');
C = textscan(HPathIn,'%s');
dataFolder = C{1}{1};
kernelFolder = C{1}{3};

for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
    
%% Get input kernel

if ~exist('inKernel')
    Z = masterKernels(order,'which',which,'isOLS',isOLS);
    switch order
        case 1
            inKernel = Z.kernels.meanKernels.k1_x;
            maxTau = length(inKernel);
        case 2
            inKernel = Z.kernels.meanKernels.k2_sym;
            maxTau = round(length(inKernel.^(1/2)));
        case 3
            inKernel = Z.kernels.meanKernels.k3_sym;
            maxTau = round(length(inKernel.^(1/3)));
            if noDiag == 1
                inKernel = removeDiag(inKernel);
            elseif noDiag == 2
                inKernel = removeDiag3(inKernel);
            end
    end
else 
    maxTau = round(length(inKernel.^(1./order)));
end
inKernel = inKernel .* (abs(inKernel) >= noiseThresh);

%% Get data to validate

if exist('testData','var')   
    D = testData;      
    OD = organizeData(D,'removeOutliers',removeOutliers,'meanSubtract',0,'rollSize',1,'normMouseRead',0); % note that mean subtraction is done later!
elseif exist('inPaths','var')
    D = grabData(inPaths);
    OD = organizeData(D,'removeOutliers',removeOutliers,'meanSubtract',0); % rollsize not 1 - not 1 when extracted
else
    D = grabData();
    OD = organizeData(D,'removeOutliers',removeOutliers,'meanSubtract',0);
end
    
D.analysis.analysisParams.whichBehav = whichBehav;
D.analysis.analysisParams.maxTau = maxTau;
D.analysis.analysisParams.interp = interp;     
D.kernelData.whichFile =  diff(OD.rig) < 1;
D.kernelData.whichFile = [0 cumsum(D.kernelData.whichFile)] + 1;

for q = 1:OD.numFiles
    kernelData(q) = getKernelDataN( D,OD,q,N );
end

%% Execute r2 calculation. 
%  A different script than I had earlier. It's nice to do this on the
%  output of kernelData (rather than D) because this takes into account
%  interpolation/downsampling.

%% generate predicted response from kernel

out = zeros(size(kernelData(1).stimTraces(:,1),1)-(maxTau-1),N);
for rr = 1:N  
    inx1 = kernelData(1).stimTraces(:,rr); 
    % Grabs first trial because this whole thing operates under the
    % assumption that you have the same stimulus for all trials
    if rr == N
        inx2 = kernelData(1).stimTraces(:,1); 
    else 
        inx2 = kernelData(1).stimTraces(:,rr + 1); 
    end
    whichOrder = ( [1:1:3] == order ); 
    filters{order} = inKernel;
    preResp = flyResp(whichOrder,filters,maxTau,inx1,inx2,0,[1 0]) - ...
        flyResp(whichOrder,filters,maxTau,inx2,inx1,0,[1 0]);
    out(:,rr) = preResp(maxTau:end);
end
out = mean(out,2);
out = out - mean(out);

%% calculate mean value from responses

catAll = kernelData(1).turnTraces;
if OD.numFiles > 1
    for q = 2:OD.numFiles
        catAll = cat(2,catAll,kernelData(q).turnTraces);
    end
end
meanval = mean(catAll,2);
meanval = meanval(maxTau:end);
R.saveData.resp = catAll;

%% Calculate R2

flyID = 0;
for z = 1:OD.numFiles
    for a = 1:size(kernelData(z).turnTraces,2)
        flyID = flyID + 1;
       
        %% Pull response for this fly

        evalc(['resp = kernelData(z).' sprintf('%s',whichBehav) 'Traces(maxTau:end,a);']);
        resp = resp - mean(resp); % De-meaning, since that's what we did during
                                  % filter extraction     
        %% Calculate r and save
%         keyboard
        kernel_r(flyID) = out' * resp / sqrt(out'*out * resp'*resp);
        mean_r(flyID) = meanval' * resp / sqrt(meanval'*meanval * resp'*resp);
    
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

