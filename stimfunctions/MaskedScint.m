function [texStr,stimData] = MaskedScint(Q)

% Flickering two-point correlations with a moving mask

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

fr = Q.timing.framenumber - Q.timing.framelastchange;

%% Input parameters

framesPerUp = p.framesPerUp;
mLum = p.mLum;
var = p.var; % careful - depending on var value, might go outside possible range,
             % which probably won't be noticeable on your bitMap but will
             % make your statistics different than what you expect.             
updateRate = p.updateRate;
binarize = p.binarize; 
maskVel = p.maskVel;
dx = p.dx;
dt = p.dt;
pixX = p.pixX;
scintWd = p.scintWd; % pixels
uncorrWd = p.uncorrWd; % pixels

if isfield(p,'pol') % so that this script still works with older paramfiles
    pol = p.pol;
else
    pol = 1;
end

%% Secondary parameters

btmpWd = floor(360/pixX);                        
cycleWd = scintWd + uncorrWd;
% numFullCycles = floor(btmpWd/cycleWd);
ceilCycles = ceil(btmpWd/cycleWd);
fullWd = ceilCycles*cycleWd;
% pixelsOverflow = mod(btmpWd,cycleWd);
frameLife = 60 * framesPerUp/updateRate;
%     assert((pixelsOverflow + numFullCycles * cycleWd) == btmpWd);

if maskVel == 0
    upsPerCycle = 1;
    tMap = zeros(1,upsPerCycle);
else
    upsPerCycle = abs(round(cycleWd*pixX/maskVel*updateRate));
    tMap = linspace(0,cycleWd-cycleWd/upsPerCycle,upsPerCycle);
end

lifespan = 60 * framesPerUp/updateRate;

%% Rotation matrix for eta' - constant throughout epoch (based on dx)

if dx > 0   
    rotEta = [ zeros(fullWd-dx,dx) eye(fullWd-dx); eye(dx) zeros(dx,fullWd-dx) ];   
else 
    dx = abs(dx);
    rotEta = [ zeros(fullWd-dx,dx) eye(fullWd-dx); eye(dx) zeros(dx,fullWd-dx) ]'; 
end


%% setup for first flip of epoch

if fr == 0
    stimData.t = floor(rand*upsPerCycle); % determine where to start in cycle randomly
    for r = 1:dt
        stimData.etaPrime(dt,:) = randn(1,fullWd)*sqrt(var); 
    end
    stimData.age = 0;
end

%% Draw the bitmap

bitMap = zeros(1,btmpWd,framesPerUp);

for q = 1:framesPerUp        
    if stimData.age == 0
        startMask = floor(tMap(stimData.t+1));
        eta = randn(1,fullWd)*sqrt(var); 
        uncorr = randn(1,fullWd)*sqrt(var);
        core = [ones(1,scintWd) zeros(1,uncorrWd)];
        
        if maskVel > 0
            rotCore = [ zeros(fullWd-startMask,startMask) eye(fullWd-startMask);...
                eye(startMask) zeros(startMask,fullWd-startMask) ];
        else
            rotCore = [ zeros(fullWd-startMask,startMask) eye(fullWd-startMask);...
                eye(startMask) zeros(startMask,fullWd-startMask) ]';
        end 

        % put together scint and random parts and print bitmap
        coreMap = [ repmat(core,1,(ceilCycles)) ];
        coreMap = coreMap * rotCore;
        preMap = eta + ( stimData.etaPrime(dt,:)*rotEta*pol) .* coreMap + uncorr .* (1 - coreMap); 
%         preMap =  ( stimData.etaPrime(dt,:)*rotEta*pol) .* coreMap; 
        if binarize
            preMap = sign(preMap);
        end
        preMap = preMap(1,1:btmpWd);
        bitMap(:,:,q:q+frameLife-1) = mLum + repmat(preMap,[1,1,frameLife]) * mLum;
        % THIS ONLY WORKS IF FRAMELIFE DIVIDES FRAMESPERUP!

        % step forward in time
        stimData.t = mod(stimData.t+1,upsPerCycle);

        % roll back etaPrime
        if dt > 1
            stimData.etaPrime(2:end,:) = stimData.etaPrime(1:end-1,:);
            stimData.etaPrime(1,:) = eta;
        else
            stimData.etaPrime = eta;
        end    
    end
    stimData.age = mod(stimData.age+1,lifespan);
    % distinction between age and t - t only changes when the bitmap
    % changes and tells you how the mask moves along, while age keeps track
    % of where you are in the lifespan of this bitmap (related to
    % updateRate)
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
end