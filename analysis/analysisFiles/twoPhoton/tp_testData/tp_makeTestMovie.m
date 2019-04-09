function [ mov, roiMasks, stim, filts ] = tp_makeTestMovie( varargin )

    
    %% Default Params
    nMultiBars = 4;
    btmpWd = 270;
    nRoi = 10;
    omSpacing = 5;
    cardinalEpDur = 1e2;
    cardinalEpReps = 2;
    flickerDur = 1e4;
    flickerVar = 1;
    dist = 2;
    maxTau = 60;
    
    %% Vararararar
    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    %% Make bitmap simulating stimulus
    %% Alignment stim
    % Right then left, ommitting up and down
    t = [1:cardinalEpDur] * 1/60; % in s
    t = [ t, repmat(t(end),[1 1e2]), fliplr(t) repmat(t(1),[1 1e2])]; % R, static, L, static
    t = repmat(t,[1 cardinalEpReps]);
    x = [1:omSpacing:btmpWd] * 2*pi/360; % radians
    [T X] = ndgrid(t,x);
    omega = 1; % hz
    lambda = pi/3; % wavelength in radians 
    sqWave = square(X * 2*pi/lambda - T * 2*pi * omega);
    
    %% random flicker epoch
    for q = 1:nMultiBars
        stim(:,q) = randInput(flickerVar,dist,flickerDur);
    end
    stim = repmat(stim,[1 ceil((btmpWd/omSpacing)/nMultiBars)]);
    nFullOms = length(x);
    stim = stim(:,1:nFullOms);
    stim = cat(1,sqWave, stim);
    
    %% Randomly sample stimulus with nRois which look at adjacent spots
    movWd = btmpWd;
    movHt = 100;
    blobSize = 10;
    mov = zeros(movHt,movWd,flickerDur);

    [ filters ] = exampleFilters( [ 1 1 1 ], maxTau );
    meanFluct = filter(filters{1},sum(filters{1}),stim(:,2));
    roiMasks = zeros(movHt,movWd,nMultiBars);
    
    % Randomly assign each ROI to a location within the bitmap
    % making movie locations correspond to stimulus location so can see any
    % effect of spatial organization
    randLocs = [ round(rand(nRoi,1)*(movHt-(blobSize-1))),...
        round(rand(nRoi,1)*(movWd-(blobSize-1))) ];
    
    
    for q = 1:nRoi
%         in1 = round((randLocs(2,1)-omSpacing)/omSpacing);
%         if randLocs(q,1) + omSpacing > 
        in1 = q;
        in2 = mod(q,nMultiBars) + 1;
        parity = (-1)^q;
        thisFilt = ((filters{2}*parity) > 0) .* abs(filters{2});
%         thisFilt = filters{2};
        
        roiMasks(blobLoc(1):blobLoc(1)+(blobSize-1), blobLoc(2):blobLoc(2)+(blobSize-1),q) = 1;
        blobTrace = [ zeros(maxTau - 1,1); specialtwodfilt( thisFilt,stim(:,in1),stim(:,in2) ) ];
%         blobTrace = blobTrace + filter(filters{1},1,stim(:,in1));
        for r = 1:flickerDur
            mov(:,:,r) = mov(:,:,r) + roiMasks(:,:,q)*blobTrace(r);
        end
    end

    bgMask = ones(movHt,movWd) - sum(roiMasks,3);
    roiMasks = cat(3,roiMasks,bgMask);
    
    for q = 1:flickerDur
        mov(:,:,q) = mov(:,:,q) + meanFluct(q);
    end

end

