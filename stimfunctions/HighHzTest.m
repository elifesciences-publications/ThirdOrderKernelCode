function [texStr,stimData] = HighHzTest(Q)

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


maxDelayL = 0;
maxDelayR = 0;
checkForTwoEyes = 0;

%%%%% note this stimulus is designed so that the first correlation occurs
%%%%% on the first timepoint of a new epoch, but this does NOT work if
%%%%% there is an updateL difference between the two epochs
if f == 1
    if ~isfield(stimData,'hzCheckL')
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
        
        stimData.hzCheckL = zeros(sizeY,sizeX,maxDelayL);
        stimData.hzCheckL(logical(circshift(eye(size(stimData.hzCheckL)),[1,30]))) = 1;
        stimData.hzCheckL(logical(circshift(eye(size(stimData.hzCheckL)),[1,35]))) = -0.5;
        stimData.hzCheckL(logical(circshift(eye(size(stimData.hzCheckL)),[1,40]))) = 0.2;
        stimData.hzCheckR = zeros(sizeY,sizeX,maxDelayR);
    end
end

bitMap = zeros(sizeY,sizeX,framesPerUp);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
updateFrameL = mod(hzFrame-1,updateL) == 0;

for cc = 1:framesPerUp
    if updateFrameL(cc)
        if delayL == 0
            stimData.hzCheckL = cat(3,2*(round(rand(sizeY,sizeX,1)))-1,stimData.hzCheckL(:,:,1:end-1));
        else
            stimData.hzCheckL = cat(3,phiL*circshift(stimData.hzCheckL(:,:,delayL),[dirYL,dirXL]),stimData.hzCheckL(:,:,1:end-1));

            % generate new ends on the cylinder so that its always random
            %stimData.hzCheckL(:,[1:(dirXL*(dirXL>0)) (end+dirXL+1):(end*(dirXL<0))],1) = 2*(round(rand(sizeY,abs(dirXL),1)))-1;
            %stimData.hzCheckL([1:(dirYL*(dirYL>0)) (end+dirYL+1):(end*(dirYL<0))],:,1) = 2*(round(rand(abs(dirYL),sizeX,1)))-1;
        end
    end
    
    bitMap(:,:,cc) = cL*stimData.hzCheckL(:,:,1);
end

bitMap = (bitMap+1)/2;

if p.twoEyes
    rightEye = zeros(sizeY,sizeX,framesPerUp);
    updateFrameR = mod(hzFrame-1,updateR) == 0;
    
    for cc = 1:framesPerUp
        if updateFrameR(cc)
            if delayR == 0
                stimData.hzCheckR = cat(3,2*(round(rand(sizeY,sizeX,1)))-1,stimData.hzCheckR(:,:,1:end-1));
            else
                stimData.hzCheckR = cat(3,phiR*circshift(stimData.hzCheckR(:,:,delayR),[dirYR,dirXR]),stimData.hzCheckR(:,:,1:end-1));

                % generate new ends on the cylinder so that its always random
                %stimData.hzCheckR(:,[1:(dirXR*(dirXR>0)) (end+dirXR+1):(end*(dirXR<0))],1) = 2*(round(rand(sizeY,abs(dirXR),1)))-1;
                %stimData.hzCheckR([1:(dirYR*(dirYR>0)) (end+dirYR+1):(end*(dirYR<0))],:,1) = 2*(round(rand(abs(dirYR),sizeX,1)))-1;
            end
        end

        rightEye(:,:,cc) = cR*stimData.hzCheckR(:,:,1);
    end
    
    rightEye = (rightEye+1)/2;
    
    bitMap = CombEyes(bitMap,rightEye,p,f);
end
 

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
