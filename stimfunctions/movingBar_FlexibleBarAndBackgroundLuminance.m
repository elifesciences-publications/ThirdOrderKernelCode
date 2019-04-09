function [texStr,stimData] = movingBar_FlexibleBarAndBackgroundLuminance(Q)
% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework.

% NOTE: when you create a new stimulus function, you must update the
% stimlookup table in the folder paramfiles. paramfiles will also hold the
% text file giving lists of parameters that comprise an experiment

%when choosing noise values for the sine wave make sure that:
%noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
%this insures that 3 std of the noise keeps you below a luminence of 1

p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
stimData.flash = false;

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

sizeX = round(360/p.numDeg);
sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));

dir = p.direction;
updown = p.updown;
norm_direction = mod(dir, 360);

mlum = p.lum;

vel = p.vel*pi/180; %velocity in rad/s
width = p.width*pi/180; %width in rad

lambda = p.lambda*pi/180;

framesPerUp = p.framesPerUp;

if f == 1
    % in the first frame of this epoch see whether the sin wave subfields
    % exist. if they don't initialize them. If they already exist they will
    % be used in the normal loop below to be continuous between epochs
    if ~isfield(stimData,'sinPVL')
        stimData.sinPVL = zeros(2,1);
    end
    
    % if ~isfield(stimData,'sinPVR')
    %     stimData.sinPVR = zeros(2,1);
    % end
    %
    % if ~isfield(stimData,'sinWNL');
    %     stimData.sinWNL = randn(sizeY,sizeX);
    % end
    %
    % if ~isfield(stimData,'sinWNR');
    %      stimData.sinWNR = randn(sizeY,sizeX);
    % end
end

theta = (0:sizeY-1)/sizeX*2*pi; %theta in radians
bar = logical(ones(size(theta))); %full field white, will become a bar next!
%     bitMap = -ones(1,sizeX,framesPerUp);
%     for cc = 1:framesPerUp
%         stimData.sinPVL(2) = vel;
%
%         stimData.sinPVL(1) = stimData.sinPVL(1) + stimData.sinPVL(2)/(60*framesPerUp);
%         if stimData.sinPVL(1) > 2*pi
%             stimData.sinPVL(1) = mod(stimData.sinPVL(1), 2*pi);
%             stimData.flash = true;
%         elseif stimData.sinPVL(1) < 0
%             stimData.sinPVL(1) = 2*pi+stimData.sinPVL(1);
%             stimData.flash = true;
%         end
%
%         bar(theta<stimData.sinPVL(1) | theta>stimData.sinPVL(1)+width) = false;
%
%
%         bitMap(1,bar,cc) = 1;
%
%         stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
%     end
%     bitMap = repmat(bitMap,[sizeY,1]);
barPolarity=p.barPolarity;
background=p.background;

if updown == 1
    
    bitMap = background*ones(sizeY,1,framesPerUp);
    
    for cc = 1:framesPerUp
        stimData.sinPVL(2) = vel;
        
        stimData.sinPVL(1) = stimData.sinPVL(1) + stimData.sinPVL(2)/(60*framesPerUp);
        if stimData.sinPVL(1) > 2*pi
            stimData.sinPVL(1) = mod(stimData.sinPVL(1), 2*pi);
            stimData.flash = true;
        elseif stimData.sinPVL(1) < 0
            stimData.sinPVL(1) = 2*pi+stimData.sinPVL(1);
            stimData.flash = true;
        end
        
        bar(theta<stimData.sinPVL(1) | theta>stimData.sinPVL(1)+width) = false;
        
        
        bitMap(bar,1,cc) = barPolarity;
        
        stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
        
    end
    bitMap = repmat(bitMap,[1,sizeX]);    
    
else
    theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians
    bar = logical(ones(size(theta))); %full field white, will become a bar next!
    bitMap = background*ones(1,sizeX,framesPerUp);
    for cc = 1:framesPerUp
        stimData.sinPVL(2) = vel;
        
        stimData.sinPVL(1) = stimData.sinPVL(1) + stimData.sinPVL(2)/(60*framesPerUp);
        if stimData.sinPVL(1) > 2*pi
            stimData.sinPVL(1) = mod(stimData.sinPVL(1), 2*pi);
            stimData.flash = true;
        elseif stimData.sinPVL(1) < 0
            stimData.sinPVL(1) = 2*pi+stimData.sinPVL(1);
            stimData.flash = true;
        end
        
        bar(theta<stimData.sinPVL(1) | theta>stimData.sinPVL(1)+width) = false;
        
        
        bitMap(1,bar,cc) = barPolarity;
        
        stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;

    end
    bitMap = repmat(bitMap,[sizeY,1]);
end
[~,edgeLoc] = min(abs(abs(stimData.sinPVL(1))-theta));
edgeLoc = ((vel>0)*2-1)*(edgeLoc-2);
stimData.mat(7) = edgeLoc;


bitMap = mlum*(1 + bitMap);

%always include this line in a stim function to make the texture from the
%bitmap

texStr.tex = CreateTexture(bitMap,Q);
end