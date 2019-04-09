function [texStr,stimData] = multiBarFlicker(Q)

% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework.

% NOTE: when you create a new stimulus function, you must update the
% stimlookup table in the folder paramfiles. paramfiles will also hold the
% text file giving lists of parameters that comprise an experiment

%when choosing noise values for the sine wave make sure that:
%noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
%this insures that 3 std of the noise keeps you below a luminence of 1

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% Input parameters

framesPerFlip = p.framesPerUp;
barWd = 2*p.barWd; % degrees - doubled because unit is 1/2 degree
mLum = p.mLum;
var = p.var; % careful - depending on var value, might go outside possible range,
             % which probably won't be noticeable on your bitMap but will
             % make your statistics different than what you expect.
distribution = p.distribution;
flickerFreq = p.flickerFreq;
reseed = p.reseed;
N = p.numBars;

if isfield(p,'randPhase')
    randPhase = p.randPhase;
else
    randPhase = 0;
end

if isfield(p, 'repeatLength')
    repeatLength = p.repeatLength*60;
    blockLength = p.blockLength*60;
else
    repeatLength = 900;
    blockLength = 3600;
end

if ~isfield(stimData, 'firstPresentation')
    stimData.firstPresentation = Q.timing.framenumber;
    frameInFlicker = 0;
else
    frameInFlicker = Q.timing.framenumber - stimData.firstPresentation;
end

if isfield(p, 'repeatBlock')
    repeatBlock = p.repeatBlock;
else
    warning('No repeat chunk will be included in this presentation!');
    repeatBlock = 0;
end

if isfield(p, 'rotation')
    rotation = p.rotation;
else
    rotation = 0;
end

if mod(rotation, 90)
    error('Your rotation value must be evenly divisible by 90');
end


%% Secondary parameters
if cosd(rotation)==0
    fullCylinderVisDeg = 2*atand((0.5*Q.cylinder.cylinderHeight)/Q.cylinder.cylinderRadius);
    fullCylinderVisDeg = fullCylinderVisDeg; % Double because it's 0.5 degree units/pixel
    mmPerBarHalf = diff(tand(0:barWd/2:fullCylinderVisDeg/2)*Q.cylinder.cylinderRadius);
    mmPerBar = [mmPerBarHalf(end:-1:1) mmPerBarHalf];
    rowsPerBar = round(10*mmPerBar);
    btmpWd = sum(rowsPerBar);
else
    visDeg = 360;
    btmpWd = floor(visDeg/.5); % leads to larger-than-necessary bitMap, but I think worth it
end
% so that you can just enter the barWd and spaceWd
% in degrees.
cycleWd = N*barWd;
numFullCycles = floor(btmpWd/cycleWd);
pixelsOverflow = mod(btmpWd,cycleWd);

lifespan = 60 * framesPerFlip/flickerFreq;
assert((pixelsOverflow + numFullCycles * cycleWd) == btmpWd);

%% determine phase; reseed rng to be consistent between trials

if  f == 0
    if randPhase
        stimData.phase = floor(rand*cycleWd);
    else
        stimData.phase = 0;
    end
    stimData.age = 0;
    stimData.writeColIndex = 0;
end

if repeatBlock
    if mod(frameInFlicker, blockLength)==0
        stimData.prevSeedState = rng(0);
    elseif mod(frameInFlicker, blockLength) == repeatLength
        rng(stimData.prevSeedState);
    end
elseif f==0
    if reseed
        rng(Q.timing.framenumber);
    else
        rng shuffle
    end

end

phase = stimData.phase;
rot = [ zeros(phase,btmpWd-phase) eye(phase,phase);  eye(btmpWd-phase,btmpWd-phase) zeros(btmpWd-phase,phase) ];

%% Draw the bitmap
if cosd(rotation)==0
    bitMap = zeros(btmpWd, 1, framesPerFlip);
else
    bitMap = zeros(1,btmpWd,framesPerFlip);
end
stimData.writeColIndex = 0;

% note that I don't think this will work if your update ratio is not an
% integer ratio with your framesPerUp.
for q = 1:framesPerFlip
    if stimData.age == 0
        stimData.writeColIndex = mod(stimData.writeColIndex + 1,ceil(framesPerFlip/lifespan));
        % Carries between frames. Moves you over every time a new random
        % pairing is generated, but in the case in which you are updating less
        % frequently than flipping, mods with 1 so you're always in the first
        % column. This has the nice effect of "automatically interpolating"
        % your stimulus.
        switch distribution
            case 1 % Gaussian
                vals = randn(1, r)*sqrt(var); % in contrast
                vals(vals>1) = 1;
                vals(vals<-1) = -1;
            case 2 % Binary
                vals = 2*sqrt(var)*(randi(2, 1, N)-1.5);
            case 3 % Flat
                vals = 2*sqrt(3*var)*(rand(1, N) - .5);
            case 4 % ternary
                vals = sqrt(3/2*var)*(randi(3, 1, N)-2);
        end
        
        % save stim to text file.
        % Interestingly, this writes for every flip, but only CHANGES when
        % you manually change it. Hence if you update less frequently than
        % you flip, you'll "interpolate" automatically - but again, integer
        % ratios!
        for r = 1:N
            stimData.mat(r+(stimData.writeColIndex)*2) = vals(r);
        end
    end
    
    
    % impose random phase shift
    if cosd(rotation) == 0
        if randPhase ~= 0
            error('randPhase not implemented for rotated multibar');
        end
        rowStartEndsPerBar = [1 cumsum(rowsPerBar)];
        halfWayBar = ceil(length(rowsPerBar)/2);
        for rowInd = 1:halfWayBar
            valInd = mod(rowInd, length(vals));
            if valInd==0
                valInd = length(vals);
            end
            preMap(rowStartEndsPerBar(halfWayBar+rowInd):rowStartEndsPerBar(halfWayBar+rowInd+1), 1) = vals(valInd);
            preMap(rowStartEndsPerBar(halfWayBar-rowInd+1):rowStartEndsPerBar(halfWayBar-rowInd+2), 1) = vals(end-(valInd-1));
        end
    else
        core = [];
        for r = 1:N
            core = [ core ones(1,barWd)*stimData.mat(r+(stimData.writeColIndex)*2) ];
        end
        
        preMap = [ repmat(core,1,(numFullCycles)) core(1,1:pixelsOverflow)];
        preMap = preMap(1,1:btmpWd) * rot;
    end
    bitMap(:,:,q) =  mLum * ( 1 + preMap );
    stimData.age = mod(stimData.age+1,lifespan);
end


texStr.tex = CreateTexture(bitMap,Q);
end