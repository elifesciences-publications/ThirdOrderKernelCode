function Z = tp_genCheapTestKernelData( varargin )
% Creates test data that emulates the output of mapsToRoiData. Designed to
% make sense with kernel extraction. Based off of a 60 hz kernel extraction
% stimulus that has already been run

%% Generate Test Movie for Two Photon Analysis

params.nMultiBars = 4;

nSamples = 1e4;
inVar = 1;
dist = 2;
maxTau = 60;

for q = 1:params.nMultiBars
    stim(:,q) = randInput(inVar,dist,nSamples);
end

%% Create movie at same sampling frequency as stimulus, then downsample 
%  so that we can test alignment. 
movWd = 200;
movHt = 100;
blobSize = 10;
movie = zeros(movHt,movWd,nSamples);

% Make entire image fluctuation linearly based on stim # 2
[ filters ] = exampleFilters( [ 1 1 1 ], maxTau );
meanFluct = filter(filters{1},sum(filters{1}),stim(:,2));

% Create regions that respond direction-selectively to each bar pair
for q = 1:params.nMultiBars
    in1 = q;
    in2 = mod(q,params.nMultiBars) + 1;
    blobLoc = [ round(rand*(movHt-(blobSize-1))) round(rand*(movWd-(blobSize-1))) ];
    blobTrace = [ zeros(maxTau - 1,1); specialtwodfilt( filters{2},stim(:,in1),stim(:,in2) ) ];
    for q = 1:nSamples
        movie(blobLoc(1):blobLoc(1)+(blobSize-1), blobLoc(2):blobLoc(2)+(blobSize-1),q) = ...
            movie(blobLoc(1):blobLoc(1)+(blobSize-1), blobLoc(2):blobLoc(2)+(blobSize-1),q) + ...
            ones(blobSize)*blobTrace(q);
    end
end

for q = 1:nSamples
        movie(:,:,q) = movie(:,:,q) + meanFluct(q);
end
% 
% figure;
% for q = 1:nSamples
%     imagesc(movie(:,:,q));
%     pause(.0001);
% end

%% Downsample by an ugly number

downsampRatio = 11.47; 
origAxis = repmat([1:1:nSamples],[movHt*movWd 1]);
downsampAxis = repmat([1:downsampRatio:nSamples],[movHt*movWd 1]);


dsMovie = interp1(origX,movie,downsampXq);


end

