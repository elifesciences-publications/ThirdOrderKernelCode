function [texStr,stimData] = FullFieldLuminance(Q)
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
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

if p.numDeg == 0
    sizeX = 1;
    sizeY = 1;
else
    sizeX = round(360/p.numDeg);
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));
end

mlum = p.lum;

framesPerUp = p.framesPerUp;

bitMap(1,sizeX,framesPerUp) = mlum;

bitMap = repmat(bitMap,[sizeY,1]);


texStr.tex = CreateTexture(bitMap,Q);

end