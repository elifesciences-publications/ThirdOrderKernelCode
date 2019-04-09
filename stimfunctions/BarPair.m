function [texStr,stimData] = BarPair(Q)

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
if isfield(p, 'backgroundContrast')
    bkgdContrast = p.backgroundContrast;
else
    bkgdContrast = 0;
end

if isfield(p, 'firstBarDelay')
    firstBarDelay = p.firstBarDelay*60; %multiply by 60 to go from seconds to frames
else
    firstBarDelay = 0;
end

if isfield(p, 'firstBarOff')
    firstBarOff = p.firstBarOff*60; %multiply by 60 to go from seconds to frames
else
    firstBarOff = [];
end

if isfield(p, 'secondBarOff')
    secondBarOff = p.secondBarOff*60; %multiply by 60 to go from seconds to frames
else
    secondBarOff = [];
end

if isfield(p, 'flickerFrequency')
    flickerFrequency = p.flickerFrequency;
else
    flickerFrequency = 30; % Binary flicker will default to 30 Hz updating in this stimulus
end

barWd = 2*p.barWd; % degrees - doubled because unit is 1/2 degree
spaceWd = 2*p.spaceWd; % degrees
mLum = p.mLum;
direction = p.direction;
secondBarDelay = p.secondBarDelay*60; %multiply by 60 to go from seconds to frames
firstBarContrast = p.firstBarContrast;
secondBarContrast = p.secondBarContrast;
phase = p.phase;

availablePhases = (spaceWd+2*barWd)/(barWd);
if mod(availablePhases, 1)
    error('Your space width has to be evenly divisible by your bar width!');
else
    if isfield(p, 'phaseShift');
        phaseShift =  2*phase*p.phaseShift; %units are in 1/2 degree
    else
        phase = mod(phase, availablePhases);
        % This is how much of an index circshift this phase entails
        phaseShift = phase*barWd;
    end
end

%% Secondary parameters

btmpWd = floor(360/.5); % leads to larger-than-necessary bitMap, but I think worth it
                        % so that you can just enter the barWd and spaceWd
                        % in degrees. 
                        
cycleWd = 2*barWd + spaceWd;
numFullCycles = floor(btmpWd/cycleWd);
pixelsOverflow = mod(btmpWd,cycleWd);

flipFrequency = 60*framesPerFlip; % Baseline 60Hz, multiplied by the number of frames in each of these 60Hz
flickerFramesPerChange = flipFrequency/flickerFrequency;

if mod(flickerFramesPerChange, 1)
    error('The update rate of %d needs to be evenly divisible by the flicker frequency of %d', flipFrequency, updateFrequency);
end
    
%% Draw the bitmap

bitMap = zeros(1,btmpWd,framesPerFlip);
stimData.writeColIndex = 0;
% if f == 1
%     toc;
% end


for q = 1:framesPerFlip
    % These polarities are in contrast
    if f >= firstBarDelay && (isempty(firstBarOff) || f < firstBarOff)
        barOne = firstBarContrast;
    else
%         if isequal(bkgdContrast, pi) % flickering background
%             barOne =  2*round(rand)-1;
%         else
            barOne = bkgdContrast;
%         end
    end
    if f >= secondBarDelay && (isempty(secondBarOff) || f < secondBarOff)
        barTwo = secondBarContrast;
    else
%         if isequal(bkgdContrast, pi) % flickering background
%             barTwo =  2*round(rand)-1;
%         else
            barTwo = bkgdContrast;
%         end
    end
    
    numPhase = (spaceWd+2*barWd)/barWd;
    barContrasts = bkgdContrast*ones(numPhase, 1);
    
    if ~mod(q+f*framesPerFlip-1, flickerFramesPerChange)
        if isequal(barOne, pi)
            barOne = 2*round(rand)-1;
        end
        if isequal(barTwo, pi)
            barTwo = 2*round(rand)-1;
        end
        if isequal(bkgdContrast, pi)
            barContrasts =  2*round(rand(numPhase, 1))-1;
        end
    else
        if isequal(barOne, pi)
            barOne = stimData.mat(1);
        end
        if isequal(barTwo, pi)
            barTwo = stimData.mat(2);
        end
        if isequal(bkgdContrast, pi)
            barContrasts =  stimData.mat(3:((numPhase-1)+3));
        end
    end
    
    % The behavior of stimData changed 1/9/2017 so that the first column is
    % the value of barOne (the first bar that appears) and the second
    % column is the value of barTwo (the second bar that appears), instead
    % of the direction/distance of the values reflecting the
    % direction/distance of the two bars
    stimData.mat(1) = barOne;
    stimData.mat(2) = barTwo;
    stimData.mat(3:((numPhase-1)+3)) = barContrasts;
%     if direction > 0
%         stimData.mat(1+(stimData.writeColIndex)*2) = barOne; 
%         stimData.mat(1+direction+(stimData.writeColIndex)*2) = barTwo;
%     else
%         stimData.mat(1+(stimData.writeColIndex)*2) = barTwo; 
%         stimData.mat(1-direction+(stimData.writeColIndex)*2) = barOne;
%     end

    % Still gotta deal with directionality issues
    if direction > 0
        barContrasts(1) = barOne;
        barContrasts(1+direction) = barTwo;
    else
        barContrasts(1) = barTwo;
        barContrasts(1-direction) = barOne;
    end
    
    core = bkgdContrast * ones(1, spaceWd+2*barWd);
    for i = 0:numPhase-1
        core((i*barWd+1):((i+1)*barWd)) = barContrasts(i+1);
    end
%     core = [stimData.mat(1+(stimData.writeColIndex)*2)*ones(1,barWd) stimData.mat(2+(stimData.writeColIndex)*2) *ones(1,barWd) zeros(1,spaceWd)];
    preMap = [ repmat(core,1,(numFullCycles)) core(1,1:pixelsOverflow)];

    % impose random phase shift
    preMap = circshift(preMap(1,1:btmpWd), phaseShift, 2);
    bitMap(:,:,q) =  mLum * ( 1 + preMap );
end

texStr.tex = CreateTexture(bitMap,Q);
end
