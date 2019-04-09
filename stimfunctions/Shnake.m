function [texStr,stimData] = Shnake(Q)

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
framet = [1/180 2/180 0]; %GBR. checked this order in DLPU006a.pdf document, each frame happens 1/180th of a second after the next

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

Lo=p.lo;
Hi=p.hi;

pixSizeY=p.pixSizeY;
pixSizeX=p.pixSizeX;

stimData.mat = 0;
rowHt=p.rowHt;
spaceHt=p.spaceHt;
whichWay=p.whichWay;
bgVal=p.bgVal*255;
shakeHz=p.shakeHz;
%make sure to choose shakeHz st 60/shakeHz is an even number
%this is the Hz of a full cycle, not the update rate
random=p.random;
patType=p.patType;

wd=round(360/pixSizeX);
ht=1/(tand(pixSizeY));

rows=round(ht/(rowHt+spaceHt));

switch patType
    case 1
        pat=[Hi Lo -Hi -Lo; -Hi -Lo Hi Lo];
    case 2
        pat=[Hi Lo Lo -Hi -Lo -Lo; -Hi -Lo -Lo Hi Lo Lo];
    case 3
        pat=[Hi Lo Lo Lo -Hi -Lo -Lo -Lo; -Hi -Lo -Lo -Lo Hi Lo Lo Lo];
    case 4
        pat=[Hi Lo -Hi -Lo; Hi Lo -Hi -Lo];
    case 5
        pat=[Hi Lo 0 0; Hi Lo 0 0];
    case 6
        pat=-1*[Hi Lo 0 0; Hi Lo 0 0];
end

  
switch whichWay
    case -1
        pat=fliplr(pat);
end


%% Option to have each pattern instance flipped left and right (to cancel
%  out the effect of the stim - a control).

reps=round(wd/length(pat));
patlen = size(pat,2);
full_len = patlen * reps;

if f == 1
    if random
        assert(patType == 5 | patType ==6);
        stimData.savedpat = zeros(size(pat,1),full_len);
        for j = 0:reps-1
            patf = pat;
            if rand > .5
                patf(:,1:2) = fliplr(patf(:,1:2));
            end
            stimData.savedpat(:,j*patlen+1:(j+1)*patlen) = patf;
        end
    else
        stimData.savedpat=repmat(pat,1,reps);
    end 
    f = f + (rand > .5);
end

rot = [zeros(2,full_len-2) eye(2,2); eye(full_len-2,full_len-2) zeros(full_len-2,2)]; 

stimData.usepat=stimData.savedpat;
if mod(f,60/shakeHz) >= (60/shakeHz)/2
   stimData.usepat=stimData.savedpat*rot;   
end

ind=zeros(2,(rowHt+spaceHt)*2);
ind(1,spaceHt+1:rowHt+spaceHt)=1;
ind(2,rowHt+2*spaceHt+1:(rowHt+spaceHt)*2)=1;
ind=repmat(ind,1,rows);

ind2=1-ind(1,:)-ind(2,:);
a2=zeros(size(stimData.usepat));
c=zeros(1,reps*patlen);

for k=[1 2 3]
    a2(:,:,k)=stimData.usepat*255/2+255/2;
    c(:,:,k)=ones(1,reps*patlen)*bgVal;
    bitMap(:,:,k)=(ind'*a2(:,:,k))+(ind2'*c(:,:,k));
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
end

