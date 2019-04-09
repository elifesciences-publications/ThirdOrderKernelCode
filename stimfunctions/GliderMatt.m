function [texStr,stimData] = GliderMatt(Q)

% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
updateL = p.updateL;
updateR = p.updateR;
delayL = p.delayL;
delayR = p.delayR;
dirXL = p.dirXL; %direction and amplitude of the motion
dirYL = p.dirYL;
dirXR = p.dirXR;
dirYR = p.dirYR;
cL = p.cL;
cR = p.cR;
framesPerUp = p.framesPerUp;

phiL = p.phiL;
phiR = p.phiR;

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


maxDelayL = 0;
maxDelayR = 0;
checkForTwoEyes = 0;

%%%%% note this stimulus is designed so that the first correlation occurs
%%%%% on the first timepoint of a new epoch, but this does NOT work if
%%%%% there is an updateL difference between the two epochs
if f == 1
    if ~isfield(stimData,'glidMemL')
        for ii = 1:size(Q.stims.params,2)
            if Q.stims.params(ii).delayL > maxDelayL
                maxDelayL = Q.stims.params(ii).delayL;
            end

            if Q.stims.params(ii).delayR > maxDelayR
                maxDelayR = Q.stims.params(ii).delayR;
            end

            checkForTwoEyes = checkForTwoEyes + p.twoEyes;
        end

        if checkForTwoEyes == 0
            maxDelayR = 0;
        end
        
        stimData.glidMemL = 2*(rand(sizeY,sizeX,maxDelayL) > thresholdL)-1;
        stimData.glidMemR = 2*(rand(sizeY,sizeX,maxDelayR) > thresholdR)-1;
    end
end

bitMap = zeros(sizeY,sizeX,framesPerUp);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
updateFrameL = mod(hzFrame-1,updateL) == 0;

for cc = 1:framesPerUp
    if updateFrameL(cc)
        if delayL == 0
            stimData.glidMemL = cat(3,2*(rand(sizeY,sizeX,1) > thresholdL)-1,stimData.glidMemL(:,:,1:end-1));
        else
            stimData.glidMemL = cat(3,phiL*circshift(stimData.glidMemL(:,:,delayL),[dirYL,dirXL]),stimData.glidMemL(:,:,1:end-1));

            % generate new ends on the cylinder so that its always random
            stimData.glidMemL(:,[1:(dirXL*(dirXL>0)) (end+dirXL+1):(end*(dirXL<0))],1) = 2*(rand(sizeY,abs(dirXL),1) > thresholdL)-1;
            stimData.glidMemL([1:(dirYL*(dirYL>0)) (end+dirYL+1):(end*(dirYL<0))],:,1) = 2*(rand(abs(dirYL),sizeX,1) > thresholdL)-1;
        end
    end
    
    bitMap(:,:,cc) = cL*stimData.glidMemL(:,:,1);
end

bitMap = (bitMap+1)/2;

if p.twoEyes
    rightEye = zeros(sizeY,sizeX,framesPerUp);
    updateFrameR = mod(hzFrame-1,updateR) == 0;
    
    for cc = 1:framesPerUp
        if updateFrameR(cc)
            if delayR == 0
                stimData.glidMemR = cat(3,2*(rand(sizeY,sizeX,1) > thresholdR)-1,stimData.glidMemR(:,:,1:end-1));
            else
                stimData.glidMemR = cat(3,phiR*circshift(stimData.glidMemR(:,:,delayR),[dirYR,dirXR]),stimData.glidMemR(:,:,1:end-1));

                % generate new ends on the cylinder so that its always random
                stimData.glidMemR(:,[1:(dirXR*(dirXR>0)) (end+dirXR+1):(end*(dirXR<0))],1) = 2*(rand(sizeY,abs(dirXR),1) > thresholdR)-1;
                stimData.glidMemR([1:(dirYR*(dirYR>0)) (end+dirYR+1):(end*(dirYR<0))],:,1) = 2*(rand(abs(dirYR),sizeX,1) > thresholdR)-1;
            end
        end

        rightEye(:,:,cc) = cR*stimData.glidMemR(:,:,1);
    end
    
    rightEye = (rightEye+1)/2;
    
    bitMap = CombEyes(bitMap,rightEye,p,f);
end
 

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
