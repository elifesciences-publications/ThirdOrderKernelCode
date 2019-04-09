function [texStr,stimData] = GliderAnyPointMirrored(Q)

% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
update = p.update;
delay = p.delay;
dirX = p.dirX; %direction and amplitude of the motion
dirY = p.dirY;
c = p.c;
framesPerUp = p.framesPerUp;
corrType = p.corrType;

corrSign = p.corrSign;

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


maxDelay = 0;
maxDelayR = 0;
checkForTwoEyes = 0;

%%%%% note this stimulus is designed so that the first correlation occurs
%%%%% on the first timepoint of a new epoch, but this does NOT work if
%%%%% there is an update difference between the two epochs
lastContrast = Q.stims.params(Q.stims.lastStim).c;

if f == 1
    if ~isfield(stimData,'glidMem') || (sizeY ~= size(stimData.glidMem,1)) || (sizeX ~= size(stimData.glidMem,2)) || (lastContrast==0)
        for ii = 1:size(Q.stims.params,2)
            if Q.stims.params(ii).delay > maxDelay
                maxDelay = Q.stims.params(ii).delay;
            end

            checkForTwoEyes = checkForTwoEyes + p.twoEyes;
        end
        
        stimData.glidMem = 2*(round(rand(sizeY,sizeX,maxDelay)))-1;
    end
end

bitMap = zeros(sizeY,sizeX,framesPerUp);
newMat = zeros(sizeY,sizeX);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
updateFrame = mod(hzFrame-1,update) == 0;

for cc = 1:framesPerUp
    c = p.c;
    if updateFrame(cc)
        
        if (sizeY ~= size(stimData.glidMem,1)) || (sizeX ~= size(stimData.glidMem,2))
            stimData.glidMem = 2*(round(rand(sizeY,sizeX,maxDelay)))-1;
        end
        
        if delay == 0
                stimData.glidMem = cat(3,2*(round(rand(sizeY,sizeX,1)))-1,stimData.glidMem(:,:,1:end-1));
        else
            switch corrType
                case 2
                    newMat = corrSign*circshift(stimData.glidMem(:,:,delay),[dirY,dirX]);
                    
                    % generate new ends on the cylinder so that its always random
                    newMat(:,[1:(dirX*(dirX>0)) (end+dirX+1):(end*(dirX<0))]) = 2*(round(rand(sizeY,abs(dirX),1)))-1;
                    newMat([1:(dirY*(dirY>0)) (end+dirY+1):(end*(dirY<0))],:) = 2*(round(rand(abs(dirY),sizeX,1)))-1;
                
                case 4
                    oldMat = stimData.glidMem(:,:,delay);
                    newMat(:,1) = 2*(round(rand(sizeY,1,1)))-1;
                    
                    for xx = 2:sizeX
                        for yy = 1:sizeY
                            newMat(yy,xx) = corrSign/(oldMat(yy,xx-1)*oldMat(yy,xx)*newMat(yy,xx-1));
                        end
                    end
                    
                case 5
                    oldMat = stimData.glidMem(:,:,delay);
                    newMat(:,1) = 2*(round(rand(sizeY,1,1)))-1;

                    for xx = 2:sizeX
                        for yy = 1:sizeY
                            newMat(yy,xx) = corrSign/(oldMat(yy-1,xx)*oldMat(yy,xx)*newMat(yy-1,xx));
                        end
                    end
                    
                    case 10
                        % this stim allows for a four point glider equal to
                        % 0. pretty dirty need to validate its use
                        
                        oldMat = stimData.glidMem(:,:,delay);
                        newMat(:,1) = floor(3*rand(sizeY,1,1))-1;

                        for xx = 2:sizeX
                            for yy = 1:sizeY
                                if ~isinf(1/(oldMat(yy,xx-1)*oldMat(yy,xx)*newMat(yy,xx-1)))
                                    newMat(yy,xx) = 0;
                                else
                                    newMat(yy,xx) = floor(3*rand)-1;
                                end
                            end
                        end
            end
            
            stimData.glidMem = cat(3,newMat,stimData.glidMem(:,:,1:end-1));
        end
    end
    
    bitMap(:,:,cc) = c*stimData.glidMem(:,:,1);
end

bitMap = 0.5*(bitMap+1);

if p.twoEyes
    rightEye = fliplr(bitMap);

    bitMap = CombEyes(bitMap,rightEye,p,f);
end
 

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
