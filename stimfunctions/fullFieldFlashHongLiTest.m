function [texStr,stimData] = fullFieldHongLiTest(Q)

% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

% NOTE: when you create a new stimulus function, you must update teh
% stimlookup table in the folder paramfiles. paramfiles will also hold the
% text file giving lists of parameters that comprise an experiment

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number; frames change at 60Hz
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2

frequency = p.frequency;
framesPerCycle = 60/frequency;

if mod(framesPerCycle, 1)
    error('The frequency needs to evenly divide 60');
end

frameInCycle = mod(f, framesPerCycle);

if frameInCycle == 1
    bitMap = sin(ones(1, 5, 3));
else
    bitMap = zeros(1, 1, 3);
end

% must also set up the scaling factors here for use in the texture
% rendering
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
