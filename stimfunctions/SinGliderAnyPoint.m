function [texStr,stimData] = SinGliderAnyPoint(Q)

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
corrTypeL = p.corrTypeL;
corrTypeR = p.corrTypeR;

corrSignL = p.corrSignL;
corrSignR = p.corrSignR;

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
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDeg*pi/180)));
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
        
        stimData.glidMemL = 2*(round(rand(sizeY,sizeX,maxDelayL)))-1;
        stimData.glidMemR = 2*(round(rand(sizeY,sizeX,maxDelayR)))-1;
    end
end

bitMap = zeros(sizeY,sizeX,framesPerUp);
newMatL = zeros(sizeY,sizeX);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
updateFrameL = mod(hzFrame-1,updateL) == 0;

for cc = 1:framesPerUp
    if updateFrameL(cc)
        if delayL == 0
            stimData.glidMemL = cat(3,2*(round(rand(sizeY,sizeX,1)))-1,stimData.glidMemL(:,:,1:end-1));
        else
            switch corrTypeL
                case 1
                    newMatL = corrSignL*circshift(stimData.glidMemL(:,:,delayL),[dirYL,dirXL]);
                    
                    % generate new ends on the cylinder so that its always random
                    newMatL(:,[1:(dirXL*(dirXL>0)) (end+dirXL+1):(end*(dirXL<0))]) = 2*(round(rand(sizeY,abs(dirXL),1)))-1;
                    newMatL([1:(dirYL*(dirYL>0)) (end+dirYL+1):(end*(dirYL<0))],:) = 2*(round(rand(abs(dirYL),sizeX,1)))-1;
                case 4
                    oldMatL = stimData.glidMemL(:,:,delayL);
                    newMatL(:,1) = 2*(round(rand(sizeY,1,1)))-1;
                    
                    for xx = 2:sizeX
                        for yy = 1:sizeY
                            newMatL(yy,xx) = corrSignL/(oldMatL(yy,xx-1)*oldMatL(yy,xx)*newMatL(yy,xx-1));
                        end
                    end
            end
            
            stimData.glidMemL = cat(3,newMatL,stimData.glidMemL(:,:,1:end-1));
        end
    end
    
    bitMap(:,:,cc) = cL*stimData.glidMemL(:,:,1);
    bitMap(:,:,cc) = (0.5-0.5*cos(2*pi*hzFrame(cc)/updateL))*bitMap(:,:,cc);
end

bitMap = (bitMap+1)/2;

if p.twoEyes
    rightEye = zeros(sizeY,sizeX,framesPerUp);
    newMatR = zeros(sizeY,sizeX);
    updateFrameR = mod(hzFrame-1,updateR) == 0;
    
    for cc = 1:framesPerUp
        if updateFrameR(cc)
            if delayR == 0
                stimData.glidMemR = cat(3,2*(round(rand(sizeY,sizeX,1)))-1,stimData.glidMemR(:,:,1:end-1));
            else
                switch corrTypeR
                    case 1
                        newMatR = corrSignR*circshift(newMatR,[dirYR,dirXR]);
                        
                        % generate new ends on the cylinder so that its always random
                        newMatR(:,[1:(dirXR*(dirXR>0)) (end+dirXR+1):(end*(dirXR<0))]) = 2*(round(rand(sizeY,abs(dirXR),1)))-1;
                        newMatR([1:(dirYR*(dirYR>0)) (end+dirYR+1):(end*(dirYR<0))],:) = 2*(round(rand(abs(dirYR),sizeX,1)))-1;
                    case 4
                        oldMatR = stimData.glidMemR(:,:,delayR);
                        newMatR(:,1) = 2*(round(rand(sizeY,1,1)))-1;

                        for xx = 2:sizeX
                            for yy = 2:sizeY
                                newMatR(yy,xx) = corrSignR/(oldMatR(yy,xx-1)*oldMatR(yy,xx)*newMatR(yy,xx-1));
                            end
                        end
                end

                stimData.glidMemR = cat(3,newMatR,stimData.glidMemR(:,:,1:end-1));
            end
        end

        rightEye(:,:,cc) = cR*stimData.glidMemR(:,:,1);
        rightEye(:,:,cc) = (0.5-0.5*cos(2*pi*hzFrame(cc)/updateR))*rightEye(:,:,cc);
    end
    
    rightEye = (rightEye+1)/2;
    
    bitMap = CombEyes(bitMap,rightEye,p,f);
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
