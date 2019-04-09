function [texStr,stimData] = Stimulus_form_example(Q)

% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

% NOTE: when you create a new stimulus function, you must update teh
% stimlookup table in the folder paramfiles. paramfiles will also hold the
% text file giving lists of parameters that comprise an experiment

sii = Q.stim.currStimNumber;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 1; % or 2

% here, you can make a 1 or 2D stimulus, preferably with RGB frames (3rd
% index); try to use 128x128 textures, in general
% might also want to have an f==0 condition for the first time it's called.
% or not.
bitMap = zeros(128);

% must also set up the scaling factors here for use in the texture
% rendering
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
