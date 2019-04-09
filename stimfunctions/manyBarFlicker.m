function [texStr,stimData] = manyBarFlicker(Q)

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
    randPhase = 1;
end

%% Secondary parameters

btmpWd = floor(360/.5); % leads to larger-than-necessary bitMap, but I think worth it
                        % so that you can just enter the barWd and spaceWd
                        % in degrees.                   
cycleWd = N*barWd;
numFullCycles = floor(btmpWd/cycleWd);
pixelsOverflow = mod(btmpWd,cycleWd);

lifespan = 60 * framesPerFlip/flickerFreq;
    assert((pixelsOverflow + numFullCycles * cycleWd) == btmpWd);

%% determine phase; reseed rng to be consistent between trials

if f == 0
    if reseed
        rng(Q.timing.framenumber);
    end
    if randPhase
        stimData.phase = floor(rand*cycleWd);
    else
        stimData.phase = 0;
    end
    stimData.age = 0;
    stimData.writeColIndex = 0;
end

phase = stimData.phase;
rot = [ zeros(phase,btmpWd-phase) eye(phase,phase);  eye(btmpWd-phase,btmpWd-phase) zeros(btmpWd-phase,phase) ];
    
%% Draw the bitmap

bitMap = zeros(1,btmpWd,framesPerFlip);
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
                for r = 1:N
                    vals(r) = randn*sqrt(var); % in contrast
                    if vals(r)>1
                        vals(r) = 1;
                    elseif vals(r)<-1
                        vals(r) = -1;
                    end
                end
            case 2 % Binary
                for r = 1:N
                    vals(r) = 2*sqrt(var)*(randi(2)-1.5);
                end
            case 3 % Flat
                for r = 1:N
                    vals(r) = 2*sqrt(3*var)*(rand - .5);
                end
        end
        
        % save stim to text file. 
        % Interestingly, this writes for every flip, but only CHANGES when
        % you manually change it. Hence if you update less frequently than
        % you flip, you'll "interpolate" automatically - but again, integer
        % ratios!
        numBlocks = ceil(N/10);
        blockStarts = [1:10:N];
        blockStarts = [ blockStarts N ];
        for s = 1:numBlocks
            blockNum = vals(blockStarts(s):blockStarts(s+1));
            blockBin = (blockNun > 0);
            blockBin = blockBin(find(~isspace(num2str(blockBin))));
            stimData.mat(s+(stimData.writeColIndex)*2) = blockBin;
        end
%         for r = 1:N
%             stimData.mat(r+(stimData.writeColIndex)*2) = vals(r); 
%         end
    end

    core = [];
    for r = 1:N
        core = [ core ones(1,barWd)*stimData.mat(r+(stimData.writeColIndex)*2) ];
    end
    
    preMap = [ repmat(core,1,(numFullCycles)) core(1,1:pixelsOverflow)];
    
    % impose random phase shift
    preMap = preMap(1,1:btmpWd) * rot;
    bitMap(:,:,q) =  mLum * ( 1 + preMap );
    stimData.age = mod(stimData.age+1,lifespan);
end

texStr.tex = CreateTexture(bitMap,Q);
end