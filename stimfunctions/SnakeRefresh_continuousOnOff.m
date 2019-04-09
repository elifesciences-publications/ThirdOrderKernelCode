function [texStr,stimData] = SnakeRefresh_continuousOnOff(Q)

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



updateRate=180;

rowHt=p.rowHt;
spaceHt=p.spaceHt;
whichWay=p.whichWay;
bgVal=p.bgVal*255;
patType=p.patType;
refreshHz=p.refreshHz;
off=p.off;

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
end

  
switch whichWay
    case 2
        pat=fliplr(pat);
end

reps=round(wd/length(pat));
a=repmat(pat,1,reps);
len=length(a);
              
ind=zeros(2,(rowHt+spaceHt)*2);
ind(1,spaceHt+1:rowHt+spaceHt)=1;
ind(2,rowHt+2*spaceHt+1:(rowHt+spaceHt)*2)=1;
ind=repmat(ind,1,rows);

ind2=1-ind(1,:)-ind(2,:);
val=0;


y=[off*ones(1,updateRate/(2*refreshHz)) ones(1,updateRate/(2*refreshHz))];


a2=zeros(size(a));
c=zeros(1,len);

for k=[1 2 3]
    where=mod(stimData(7).*3+k,size(y,2))+1;
    val=(255/2)*y(1,where);
    a2(:,:,k)=a*val+255/2;
    c(:,:,k)=ones(1,len)*bgVal;
    bitMap(:,:,k)=(ind'*a2(:,:,k))+(ind2'*c(:,:,k));
    
end



    stimData(7)=stimData(7)+1;

if stimData(9)==0
    stimData(7)=0;
end

stimData(9)=Hi;

%stimData(11) = min(bitMap(:));
%stimData(12) = max(bitMap(:));
%stimData(13) = mean(bitMap(:));
%stimData(14) = std(bitMap(:));
%stimData(15:20) = bitMap(1,1:6,1);

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
end

