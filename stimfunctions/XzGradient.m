function [texStr,stimData] = XzGradient(Q)

% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

% NOTE: when you create a new stimulus function, you must update the
% stimlookup table in the folder paramfiles. paramfiles will also hold the
% text file giving lists of parameters that comprise an experiment

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well
framet = [1/180 2/180 0]; %order is RGB but frames are thrown up in order BRG
%checked this order in DLPU006a.pdf document, each frame happens 1/180th of a second after the next

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

mlum = p.lum;
c = p.contrast;
vel = p.rot.mean*pi/180; % degree/s into rad/s
lambda = p.spacing*pi/180; %wavelength in radians

stimData.mat(1) = stimData.mat(1)+vel/60;

theta = (0:255)/256*2*pi; %theta in radians

for ii=1:3
    s(:,1,ii) = floor((0:255)/30)*30;
end

bitMap = repmat(s,...
    [1,256,1]); % make a checkerboard here

% check bitdepth
% row 1 = 7 bit
% row 2 = 4 bit
% row 3 = 2 bit
% row 4 = 1 bit
bitMap = zeros(4,4,3);


bitMap(:,:,1) = [40 15 3 16; 41 240 12 32; 40 15 48 64; 41 240 192 128;]./255;
bitMap(:,:,2) = bitMap(:,:,1);
bitMap(:,:,3) = bitMap(:,:,1);


%always include this line in a stim function to make the texture from the
%bitmap
Q.stims.currParam.framesPerUp = 3;
texStr.tex = CreateTexture(bitMap,Q);
