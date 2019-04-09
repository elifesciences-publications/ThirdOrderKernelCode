function [texStr,stimData] = TwoBarFlicker_contrast(Q)

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
spaceWd = 2*p.spaceWd; % degrees
mLum = p.mLum;
var = p.var; % careful - depending on var value, might go outside possible range,
             % which probably won't be noticeable on your bitMap but will
             % make your statistics different than what you expect.
distribution = p.distribution;
flickerFreq = p.flickerFreq;
reseed = p.reseed;

%% Secondary parameters

btmpWd = floor(360/.5); % leads to larger-than-necessary bitMap, but I think worth it
                        % so that you can just enter the barWd and spaceWd
                        % in degrees. 
                        
cycleWd = 2*barWd + spaceWd;
numFullCycles = floor(btmpWd/cycleWd);
pixelsOverflow = mod(btmpWd,cycleWd);

lifespan = 60 * framesPerFlip/flickerFreq;
    assert((pixelsOverflow + numFullCycles * cycleWd) == btmpWd);

%% determine phase; reseed rng to be consistent between trials

if f == 0
    if reseed
        rng(Q.timing.framenumber);
    end
    if isfield(p,'randPhase')
        if p.randPhase
            stimData.phase = floor(rand*cycleWd);
        else
            stimData.phase = 0;
        end
    else
        stimData.phase = floor(rand*cycleWd);
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
                L = randn*sqrt(var); % in contrast
                if L>1
                    L = 1;
                elseif L<-1
                    L = -1;
                end
                R = randn*sqrt(var);
                if R >1
                    R = 1;
                elseif R <-1
                    R = -1;
                end
            case 2 % Binary
                L = 2*sqrt(var)*(randi(2)-1.5);
                R = 2*sqrt(var)*(randi(2)-1.5);
            case 3 % Flat
                L = 2*sqrt(3*var)*(rand - .5);
                R = 2*sqrt(3*var)*(rand - .5); 
        end
        
        % save stim to text file. 
        % Interestingly, this writes for every flip, but only CHANGES when
        % you manually change it. Hence if you update less frequently than
        % you flip, you'll "interpolate" automatically - but again, integer
        % ratios!
        stimData.mat(1+(stimData.writeColIndex)*2) = L; 
        stimData.mat(2+(stimData.writeColIndex)*2) = R;
    end

    core = [stimData.mat(1+(stimData.writeColIndex)*2)*ones(1,barWd) stimData.mat(2+(stimData.writeColIndex)*2) *ones(1,barWd) zeros(1,spaceWd)];
    preMap = [ repmat(core,1,(numFullCycles)) core(1,1:pixelsOverflow)];

    % impose random phase shift
    preMap = preMap(1,1:btmpWd) * rot;
    bitMap(:,:,q) =  mLum * ( 1 + preMap );
    stimData.age = mod(stimData.age+1,lifespan);
end

texStr.tex = CreateTexture(bitMap,Q);
end