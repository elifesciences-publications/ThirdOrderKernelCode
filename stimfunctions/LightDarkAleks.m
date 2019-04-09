function [texStr,stimData] = LightDarkAleks(Q)
% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework.

% NOTE: when you create a new stimulus function, you must update the
% stimlookup table in the folder paramfiles. paramfiles will also hold the
% text file giving lists of parameters that comprise an experiment

%when choosing noise values for the sine wave make sure that:
%noiseContrast <= (1-mlum*(contrast+1))/(3*mlum)
%this insures that 3 std of the noise keeps you below a luminence of 1

%    sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

if p.numDeg == 0
    sizeX = 1;
    sizeY = 1;
else
    sizeX = round(360/p.numDeg);
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
end

mlumL = p.lumL;

cL = p.contrastL;

polL = p.polL;

velL = p.velocityL; % degree/s into rad/s

wnCL = p.wnCL;

numBars= p.numBars;
disBars= p.lambdaL;%%360/numBars;

framesPerUp = p.framesPerUp;

if f == 1
    stimData.sinPVL = zeros(2,1);
    
    if ~isfield(stimData,'sinWNL');
        stimData.sinWNL = randn(sizeY,sizeX);
    end
end

sinWNL = zeros(sizeY,sizeX,framesPerUp);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;

theta = (0:sizeX-1)/sizeX*2*pi; %theta in radians

bitMap = zeros(1,sizeX,framesPerUp)-1;
for cc = 1:framesPerUp
    for pp = 1:disBars:sizeX
        if velL > 0
            b=(ceil((hzFrame(cc)-1)*(velL/(60*framesPerUp))));
            if pp<sizeX
                if b>disBars
                    b=mod(b,disBars);
                end
                bitMap(1,pp:pp+b-1,cc) = 1; 
            end
        else
            b=-ceil((hzFrame(cc)-1)*(velL/(60*framesPerUp)));
            if pp<sizeX
                if b>disBars
                    b=mod(b,disBars);
                end
                bitMap(1,pp+disBars-b:pp-1+disBars,cc) = 1; %%added -1
            end
        end
    end
    
    sinWNL(:,:,cc) = stimData.sinWNL;
    
    stimData.mat(2*cc-1:2*cc) = stimData.sinPVL;
end

bitMap = repmat(bitMap,[sizeY,1])*cL;
bitMap = mlumL*(1 + polL*cL*bitMap + wnCL*sinWNL);

%always include this line in a stim function to make the texture from the
%bitmap

texStr.tex = CreateTexture(bitMap,Q);
end