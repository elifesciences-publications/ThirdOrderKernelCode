function [texStr,stimData] = MotionFlicker_3(Q)

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
flickerFreq = p.flickerFreq;
reseed = p.reseed;

%% Secondary parameters

btmpWd = floor(360/.5); % leads to larger-than-necessary bitMap, but I think worth it
                        % so that you can just enter the barWd and spaceWd
                        % in degrees.                        
cycleWd = 3*barWd + spaceWd;
numFullCycles = floor(btmpWd/cycleWd);
pixelsOverflow = mod(btmpWd,cycleWd);
lifespan = 60 * framesPerFlip/flickerFreq;
    assert((pixelsOverflow + numFullCycles * cycleWd) == btmpWd);

%% determine phase; reseed rng to be consistent between trials

if f == 0
    if reseed
        rng(Q.timing.framenumber);
    end
    stimData.phase = floor(rand*cycleWd);
    stimData.age = 0;
    stimData.writeColIndex = 0;
    stimData.mNow = 2*(randi(2)-1.5);
    stimData.rNow = 0;
    stimData.lNow = 0;
    stimData.crNow = 0;
    stimData.clNow = 0;
%     stimData.qq = 1;
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
        % roll back everything from last frame       
        stimData.crLast = stimData.crNow;
        stimData.clLast = stimData.clNow;
        stimData.mLast = stimData.mNow;
        stimData.rLast = stimData.rNow;
        stimData.lLast = stimData.lNow;
        % new correlations and output values
        stimData.crNow = 2*(randi(2)-1.5); 
        stimData.clNow = 2*(randi(2)-1.5);
        stimData.mNow = 2*(randi(2)-1.5);
        stimData.rNow = stimData.crNow * stimData.mLast;
        stimData.lNow = stimData.clNow * stimData.mLast;   
        % write to stimData the ACTUAL HRC output - a sum!
        % In theory, the contribution of the symmetric term should go to
        % zero, but this adds noise. 
        stimData.mat(1+(stimData.writeColIndex)*5) = stimData.crNow - stimData.rLast*stimData.mNow;
        stimData.mat(2+(stimData.writeColIndex)*5) = stimData.clNow - stimData.lLast*stimData.mNow;
        stimData.mat(3+(stimData.writeColIndex)*5) = stimData.rNow;
        stimData.mat(4+(stimData.writeColIndex)*5) = stimData.mNow;
        stimData.mat(5+(stimData.writeColIndex)*5) = stimData.lNow; % save the actual bitmap for easiest validation.
        
%         % for debugging purposes 
%         if stimData.qq < 100            
%             stimData.recentCorrs(:,stimData.qq) = ...
%             [stimData.mat(1+(stimData.writeColIndex)*2) ...
%                  stimData.mat(2+(stimData.writeColIndex)*2)];
%             stimData.recentOut(:,stimData.qq) = [stimData.mLast*stimData.mat(1+(stimData.writeColIndex)*2) ... 
%                  stimData.mNow stimData.mLast*stimData.mat(2+(stimData.writeColIndex)*2)];
%             stimData.qq = stimData.qq+1;
%         else
%             keyboard
%         end
    end
    
    % update side columns (A and B) as product of mLast and correlation
    A = stimData.rNow;
    B = stimData.mNow; % notice this is mNow - will correlated with upcoming values
    C = stimData.lNow;
    
    % shape these raw values into image - repeated columns
    core = [ A*ones(1,barWd) B*ones(1,barWd) C*ones(1,barWd) zeros(1,spaceWd) ];
    preMap = [ repmat(core,1,(numFullCycles)) core(1,1:pixelsOverflow)];

    % impose random phase shift on entire image
    preMap = preMap(1,1:btmpWd) * rot;
    bitMap(:,:,q) =  mLum * ( 1 + preMap );
    stimData.age = mod(stimData.age+1,lifespan);
end

texStr.tex = CreateTexture(bitMap,Q);
end