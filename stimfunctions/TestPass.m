function [texStr,stimData] = TestPass(Q)

% Newsome Dot stimulus. A dot born in frame A appears in frame A and frame
% A+ deltaT, translated by deltaX and with a new contrast value determined
% by Hi, Lo, and increment.

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% parameters
stimData
dots = rand(10,10,3);
bitMap = zeros(10,10,3);
bitMap(:,:,:) =  rand(10,10,3);
stimData(10,10,3,2) = dots;
stimData(1) = stimData(1) + 100;

% keyboard
texStr.tex = CreateTexture(bitMap,Q);
end