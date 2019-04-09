function [texStr,stimData] = ShowPan(Q)
% Displays panoramic images moving horizontally at different velocities.
% These are pre-loaded during preliminary setup - requires that your
% paramfile have an entry panorama = 1

%% Setup

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% What do we know about our set of panoramas?

keyboard

%%

if Q.stims.xtPlot
    write_xtPlot(bitMap(1,:,:),Q);
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q.active);
end
