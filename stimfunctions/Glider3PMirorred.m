function [texStr,stimData] = Glider3PMirrored(Q)
% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

%sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
update = p.update;
c = p.contrast;
mlum = p.lum;
% updateR = p.updateR;
% delayL = p.delayL;
% delayR = p.delayR;
% dirXL = p.dirXL; %direction and amplitude of the motion
% dirYL = p.dirYL;
% dirXR = p.dirXR;
% dirYR = p.dirYR;
% cL = p.cL;
% cR = p.cR;
framesPerUp = p.framesPerUp;

% phiL = p.phiL;
% phiR = p.phiR;
%% Parameters to be added
% listOfDxs = p.listOfDxs; %<- get from parameter file
% listOfDts = p.listOfDts; %<- get from parameter file
%numDegX = p.numDegX;
%sizeX = 360/numDegX;
%sizeX = 30;

% or should I do
dx1 = p.delayDx1;
dx2 = p.delayDx2;
dt1 = p.delayDt1;
dt2 = p.delayDt2;
pol = p.pol;% 
listOfDxs = [dx1 dx2];
listOfDts = [dt1 dt2];
    %%
texStr.opts = 'full'; % see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

if p.numDegX == 0
    sizeX = 1;
else
    sizeX = round(360/p.numDegX);
end

if p.numDegY == 0
    sizeY = 1;
else
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
end

if isfield(p,'averageValueL')
    thresholdL = 0.5 - p.averageValueL/2;
else
    thresholdL = 0.5;
end
if isfield(p,'averageValueR')
    thresholdR = 0.5 - p.averageValueR/2;
else
    thresholdR = 0.5;
end
maxTDelay = 0;
if f == 1
    if ~isfield(stimData,'glid3PtMemory')
        for ii = 1:size(Q.stims.params,2)
            if max(Q.stims.params(ii).delayDt1,Q.stims.params(ii).delayDt2) > maxTDelay
                maxTDelay = max(Q.stims.params(ii).delayDt1,Q.stims.params(ii).delayDt2);

            end
        end
        stimData.glid3PtMemory(:, :,1:maxTDelay) = 2*round(rand(sizeY,sizeX, maxTDelay))-1;
    end
end

%%
bitMap = zeros(sizeY, sizeX, 1);
bitLine = zeros(sizeY,sizeX,1);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
updateFrame = mod(hzFrame-1,update) == 0;

for cc = 1:framesPerUp
    if updateFrame(cc)
        if pol == 0
            stimData.glid3PtMemory = cat(3,2*(rand(sizeY,sizeX,1) > thresholdL)-1,stimData.glid3PtMemory(:,:,1:end-1));
            bitLine =   stimData.glid3PtMemory(:,:,1);
        else
            bitLine = zeros(sizeY,sizeX,1);
            leftSeed = abs(min(listOfDxs)*(min(listOfDxs)<0));
            rightSeed = max(listOfDxs)*(max(listOfDxs)>0);
            bitLine(1:sizeY,1:leftSeed) = 2*round(rand(sizeY,leftSeed,1))-1;
            bitLine(1:sizeY,end-rightSeed+1:end) = 2*round(rand(sizeY,rightSeed,1))-1;
            stimData.glid3PtMemory = cat(3, bitLine,  stimData.glid3PtMemory);
            for yy = 1:sizeY
                for xx = leftSeed+1:sizeX-rightSeed;
                    bitLine(yy,xx) = pol/(stimData.glid3PtMemory(yy,xx+dx1,1+dt1)*stimData.glid3PtMemory(yy,xx+dx2, 1+dt2));
                    stimData.glid3PtMemory(yy,xx,1) = pol/(stimData.glid3PtMemory(yy,xx+dx1,1+dt1)*stimData.glid3PtMemory(yy,xx+dx2, 1+dt2));
                end
            end
            stimData.glid3PtMemory = stimData.glid3PtMemory(:,:,1:end-1);
        end
        bitMap = cat(3,bitLine, bitMap);
    else
        bitMap = cat(3,stimData.glid3PtMemory(:,:,1), bitMap);
        stimData.glid3PtMemory = cat(3, stimData.glid3PtMemory(:,:,1),  stimData.glid3PtMemory(:,:,1:end-1));
    
    end
end
bitMap = bitMap(:,:,1:end-1);
bitMap = mlum*(c*bitMap+1); 


%% right eye

if p.twoEyes
    rightEye = fliplr(bitMap);

    bitMap = CombEyers(bitMap,rightEye,p,f);
end
 

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
