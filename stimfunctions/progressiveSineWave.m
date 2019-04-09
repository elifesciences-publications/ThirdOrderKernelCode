function [texStr,stimData] = progressiveSineWave(Q)
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
f = Q.timing.framenumber + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

sizeX = round(360/p.numDeg);
sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));


framesPerUp = p.framesPerUp;
velocityL = p.velocityL;

position = f/velocityL;
for cc = 1:framesPerUp
    if ~mod(round(f/960), 2)
        disp('reg')
        bitMap(1, 1:round(sizeX/2)) = 128*(sin((1:round(sizeX/2))-position)+0.5);
        bitMap(1, round(sizeX/2)+1:sizeX) = 128*(sin((round(sizeX/2)+1:sizeX)+position)+0.5);
    else
        disp('prog')
        bitMap(1, 1:round(sizeX/2)) = 128*(sin(-(1:round(sizeX/2))-position)+0.5);
        bitMap(1, round(sizeX/2)+1:sizeX) = 128*(sin(-(round(sizeX/2)+1:sizeX)+position)+0.5);
    end
end

bitMap = cat(3, bitMap, bitMap, bitMap);

% for cc = 1:framesPerUp
%     if ~mod(round(f/120), 2)
%         bitMap(1, 1:round(sizeX/2), 1:3) = 255*ones(1, round(sizeX/2), 3);
%         bitMap(1, round(sizeX/2)+1:sizeX, 1:3) = 255*zeros(1, sizeX-round(sizeX/2), 3);
%     else
%         bitMap(1, 1:round(sizeX/2), 1:3) = 255*zeros(1, round(sizeX/2), 3);
%         bitMap(1, round(sizeX/2)+1:sizeX, 1:3) = 255*ones(1, sizeX-round(sizeX/2), 3);
%     end
% end

bitMap = repmat(bitMap,[sizeY,1]);



%always include this line in a stim function to make the texture from the
%bitmap

texStr.tex = CreateTexture(bitMap,Q);
end