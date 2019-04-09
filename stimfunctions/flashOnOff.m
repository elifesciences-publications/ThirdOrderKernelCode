function [texStr,stimData] = flashOnOff(Q)
% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

% NOTE: when you create a new stimulus function, you must update the
% stimlookup table in the folder paramfiles. paramfiles will also hold the
% text file giving lists of parameters that comprise an experiment

%when choosing noise values for the sine wave make sure that:
%noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
%this insures that 3 std of the noise keeps you below a luminence of 1

parameters = {'period', 'framesPerUp', 'dutyCycle'};
    
period = 60;
framesPerUp = 3;
dutyCycle = .5;

p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus

for input_param = fieldnames(p)'
    expected_parameter = strcmp(parameters, input_param);
    if any(expected_parameter)
        eval([parameters{expected_parameter} '= p.' input_param{1} ';']);
    end
end

sii = Q.stims.currStimNum;
f = Q.timing.framenumber + 1; % relative frame number
stimData = Q.stims.stimData;

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

sizeX = round(360/p.numDeg);
sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));

stimData.flash = false;

if ~isfield(stimData,'periodPosition')
    periodPosition = 1;
else
    periodPosition = stimData.periodPosition;
end

if period && periodPosition == 1
    stimData.flash = true;
end

for cc = 1:framesPerUp
    if period == 0
        bitMap = 0.5*ones(1,sizeX, 3);
        stimData.mat(6) = 0.5;
    else
        if periodPosition < period*dutyCycle
            bitMap = ones(1, sizeX, 3);
            stimData.mat(6) = 1;
        else
            bitMap = zeros(1,sizeX, 3);
            stimData.mat(6) = 0;
        end
    end
end

if periodPosition < period
    stimData.periodPosition = periodPosition+1;
else
    stimData.periodPosition = 1;
end

bitMap = repmat(bitMap,[sizeY,1]);



%always include this line in a stim function to make the texture from the
%bitmap

texStr.tex = CreateTexture(bitMap,Q);
end