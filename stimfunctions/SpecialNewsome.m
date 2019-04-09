function [texStr,stimData] = SpecialNewsome(Q)

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
framesPerUp = p.framesPerUp;
polL = p.polL;
polR = p.polR;
distYL = p.distYL;
distXL = p.distXL;
distYR = p.distYR;
distXR = p.distXR;
dispUpL = p.dispUpL;
dispUpR = p.dispUpR;
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

if f == 1
    stimData.gridMemL = [round(distYL*rand) round(distXL*rand)]';
    stimData.gridMemR = [round(distYR*rand) round(distXR*rand)]';
end

blankMat = zeros(sizeY,sizeX);

% left eye

finalDotsL = zeros(sizeY,sizeX,2);

dotsL = zeros(distYL+1,distXL+1);
dotsL(1,1) = p.cL*polL;
dotMatL = repmat(dotsL,[ceil(sizeY/size(dotsL,1)) ceil(sizeX/size(dotsL,2))]);
dotMatL = dotMatL(1:sizeY,1:sizeX);

finalDotsL(:,:,1) = circshift(dotMatL,stimData.gridMemL);
finalDotsL(:,:,2) = phiL*circshift(finalDotsL(:,:,1),[dirYL,dirXL]);

bitMap = zeros(sizeY,sizeX,framesPerUp);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
dispDotL = mod(hzFrame-1,dispUpL*updateL) < updateL;
dispShiftL = mod(hzFrame-1-delayL*updateL,dispUpL*updateL) < updateL;

for cc = 1:framesPerUp
    
    
    if dispDotL(cc)
        bitMap(:,:,cc) = finalDotsL(:,:,1);
    elseif dispShiftL(cc)
        bitMap(:,:,cc) = finalDotsL(:,:,2);
    else
        bitMap(:,:,cc) = blankMat;
    end
end

bitMap = 0.5*(bitMap+1);

if p.twoEyes
    % right eye

    finalDotsR = zeros(sizeY,sizeX,2);

    dotsR = zeros(distYR+1,distXR+1);
    dotsR(1,1) = p.cR*polR;
    dotMatR = repmat(dotsR,[ceil(sizeY/size(dotsR,1)) ceil(sizeX/size(dotsR,2))]);
    dotMatR = dotMatR(1:sizeY,1:sizeX);

    finalDotsR(:,:,1) = circshift(dotMatR,stimData.gridMemR);
    finalDotsR(:,:,2) = phiR*circshift(finalDotsR(:,:,1),[dirYR,dirXR]);

    rightEye = zeros(sizeY,sizeX,framesPerUp);
    dispDotR = mod(hzFrame-1,dispUpR) < updateL;
    dispShiftR = mod(hzFrame-1-delayR,dispUpR) < updateR;

    for cc = 1:framesPerUp
        if dispDotR(cc)
            rightEye(:,:,cc) = finalDotsR(:,:,1);
        elseif dispShiftR(cc)
            rightEye(:,:,cc) = finalDotsR(:,:,2);
        else
            rightEye(:,:,cc) = blankMat;
        end
    end
    
    rightEye = 0.5*(rightEye+1);
    
    bitMap = CombEyes(bitMap,rightEye,p,f);
end
 

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
