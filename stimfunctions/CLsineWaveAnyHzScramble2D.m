function [texStr,stimData] = CLsineWaveAnyHzScramble2D(Q)
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

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

sizeX = round(360/p.numDeg);
sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));

mlumL = p.lumL;
mlumR = p.lumR;

cL = p.contrastL;
cR = p.contrastR;

velL = p.velocityL*pi/180; % degree/s into rad/s
velR = p.velocityR*pi/180; % degree/s into rad/s

lambdaL = p.lambdaL*pi/180; %wavelength in radians
lambdaR = p.lambdaR*pi/180; %wavelength in radians

velSTDL = p.velSTDL*pi/180;
velSTDR = p.velSTDR*pi/180;

stimUpRateL = p.stimUpRateL;
stimUpRateR = p.stimUpRateR;

velUpRateL = p.velUpRateL;
velUpRateR = p.velUpRateR;

wnUpRateL = p.wnUpRateL;
wnUpRateR = p.wnUpRateR;

wnCL = p.wnCL;
wnCR = p.wnCR;

framesPerUp = p.framesPerUp;

if velUpRateL == 0
    velUpRateL = 1;
end

if velUpRateR == 0
    velUpRateR = 1;
end

if isstruct(stimData.mat)
    stimData.mat = zeros(20,1);
end

% close ALL the loops
closeTheLoop;

%% left eye
%stimData.mat(1) is used as the wave phase. stimData.mat(2) is the velocity which
%is constant unless noise is added

if f == 1
    % in the first frame of this epoch see whether the sin wave subfields
    % exist. if they don't initialize them. If they already exist they will
    % be used in the normal loop below to be continuous between epochs
    if ~isfield(stimData,'sinPVL')
        stimData.sinPVL = zeros(2,1);
    end
    
    if ~isfield(stimData,'sinPVR')
        stimData.sinPVR = zeros(2,1);
    end
    
    if ~isfield(stimData,'sinScramWNL');
        stimData.sinScramWNL = randn(sizeY,sizeX);
    end
    
    if ~isfield(stimData,'sinScramWNR');
        stimData.sinScramWNR = randn(sizeY,sizeX);
    end
    
    if ~isfield(stimData,'sinScramOrderL') || ~p.sameStructL
        sinScramTemp = randperm(sizeX*sizeY);
        sinScramTemp = repmat(reshape(sinScramTemp,[sizeY sizeX]),[1 1 framesPerUp]);
        sumMat = zeros(1,1,framesPerUp);
        sumMat(:,:,:) = (0:framesPerUp-1)*sizeY*sizeX;
        sumMat = repmat(sumMat,[sizeY sizeX 1]);
        stimData.sinScramOrderL = sinScramTemp+sumMat;
    end
    

    
    if ~isfield(stimData,'sinScramOrderR') || ~p.sameStructR
        sinScramTemp = randperm(sizeX*sizeY);
        sinScramTemp = repmat(reshape(sinScramTemp,[sizeY sizeX]),[1 1 framesPerUp]);
        sumMat = zeros(1,1,framesPerUp);
        sumMat(:,:,:) = (0:framesPerUp-1)*sizeY*sizeX;
        sumMat = repmat(sumMat,[sizeY sizeX 1]);
        stimData.sinScramOrderR = sinScramTemp+sumMat;
    end
end

if ~p.scrambleL
    sinScramOrderL = reshape(1:framesPerUp*sizeX*sizeY,[sizeY sizeX framesPerUp]);
else
    sinScramOrderL = stimData.sinScramOrderL;
end

sinPVL = stimData.sinPVL;
sinScramWNL = zeros(sizeY,sizeX,framesPerUp);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
upPosL = mod(hzFrame-1,stimUpRateL) == 0;
upVelL = mod(hzFrame-1,stimUpRateL*velUpRateL) == 0;
upWNL = mod(hzFrame-1,wnUpRateL) == 0;

theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

bitMap = zeros(1,sizeX,framesPerUp);

for cc = 1:framesPerUp
    if upVelL(cc) == 1
        sinPVL(2) = randn*velSTDL+velL;
    end

    if upPosL(cc) == 1
        sinPVL(1) = sinPVL(1) + stimUpRateL*sinPVL(2)/(60*framesPerUp);
    end

    bitMap(1,:,cc) = cL*sin(2*pi*(theta-sinPVL(1))/lambdaL);

    if upWNL(cc) == 1
        stimData.sinWNL = randn(sizeY,sizeX);
    end

    sinScramWNL(:,:,cc) = stimData.sinWNL;

    stimData.mat(2*cc-1:2*cc) = sinPVL;
end

stimData.sinPVL = sinPVL;

bitMap = repmat(bitMap,[sizeY,1]);
bitMap = bitMap(sinScramOrderL);

bitMap = mlumL*(1 + bitMap + wnCL*sinScramWNL);

%% right eye
if p.twoEyes
    if ~p.scrambleR
        sinScramOrderR = reshape(1:framesPerUp*sizeX*sizeY,[sizeY sizeX framesPerUp]);
    else
        sinScramOrderR = stimData.sinScramOrderR;
    end

    sinPVR = stimData.sinPVR;
    sinScramWNR = zeros(sizeY,sizeX,framesPerUp);
    upPosR = mod(hzFrame-1,stimUpRateR) == 0;
    upVelR = mod(hzFrame-1,stimUpRateR*velUpRateR) == 0;
    upWNR = mod(hzFrame-1,wnUpRateR) == 0;
    
    rightEye = zeros(1,sizeX,framesPerUp);

    for cc = 1:framesPerUp
        % update sitmulus by changing the 
        if upVelR(cc) == 1
            sinPVR(2) = randn*velSTDR+velR;
        end

        if upPosR(cc) == 1
            sinPVR(1) = sinPVR(1) + stimUpRateR*sinPVR(2)/(60*framesPerUp);
        end

        rightEye(1,:,cc) = cR*sin(2*pi*(theta-sinPVR(1))/lambdaR);
        
        if upWNR(cc) == 1
            stimData.sinWNR = randn(sizeY,sizeX);
        end

        sinScramWNR(:,:,cc) = stimData.sinWNR;

        stimData.mat(2*cc-1+framesPerUp*2:2*cc+framesPerUp*2) = sinPVR;
    end

    stimData.sinPVR = sinPVR;
    
    rightEye = repmat(rightEye,[sizeY,1]);
    rightEye = rightEye(sinScramOrderR);
    
    rightEye = mlumR*(1 + rightEye + wnCR*sinScramWNR);
    
    bitMap = CombEyes(bitMap,rightEye,p,f);
end

%always include this line in a stim function to make the texture from the
%bitmap

texStr.tex = CreateTexture(bitMap,Q);
end