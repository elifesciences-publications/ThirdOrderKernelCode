close all
clear all

%% Validate masterKernels
%% Generate test kernels in TWO FILES (to test concatenation) and of all orders
%  With adjustable noise properties

HPathIn = fopen('dataPath.csv');
C = textscan(HPathIn,'%s');
kernelFolder = C{1}{3};
subFolders = {'testFolder1','testFolder2'};
validateFolder = sprintf('%s/validate',kernelFolder);

whichOrder = [1 1 1]; maxTau = 20;
[ filters ] = exampleFilters( whichOrder, maxTau );
whichBehav = 'turn';

%% Noise parameters - corrVar should not be seen in symmetrized result!
corrVar = 0;
uncorrVar = 10^2;

%% Loop through orders, files
for p = 1:3
    filters{p} = filters{p}/max(abs(filters{p}(:)));
    for q = 1:size(subFolders,2)
        destination = sprintf('%s/%s',validateFolder,subFolders{q});
        if ~isdir(destination)
            mkdir(destination);              
        end
        numFlies = ceil(30*rand);
%         numFlies = 1e3;
        corrNoise = sqrt(corrVar) * randn(maxTau^p,numFlies);
        if p == 1
            kernels.k1_x_all = repmat(filters{p}(:),[1 numFlies]) + ...
                sqrt(uncorrVar) * randn(maxTau^p,numFlies) + corrNoise;   
            kernels.k1_y_all = -repmat(filters{p}(:),[1 numFlies])+ ...
                sqrt(uncorrVar) * randn(maxTau^p,numFlies) + corrNoise;
        elseif p == 2
            for r = 1:numFlies
                thisCorrNoise = reshape(corrNoise(:,r),[maxTau maxTau]);
                thisCorrNoise = (thisCorrNoise + thisCorrNoise')/sqrt(2);
                corrNoise(:,r) = thisCorrNoise(:);
            end
            kernels.k2_xy_all = repmat(filters{p}(:),[1 numFlies]) + ...
                sqrt(uncorrVar) * randn(maxTau^p,numFlies) + corrNoise;   
        elseif p == 3
            kernels.k3_xxy_all = repmat(filters{p}(:),[1 numFlies]) + ...
                sqrt(uncorrVar) * randn(maxTau^p,numFlies) + corrNoise;
            kernels.k3_yyx_all = -repmat(filters{p}(:),[1 numFlies]) + ...
                sqrt(uncorrVar) * randn(maxTau^p,numFlies) + corrNoise;
        end
        thisName = sprintf('%s/%s_%io_test',destination,whichBehav,p);
        save(thisName,'kernels');
        clear kernels
    end
end



    

