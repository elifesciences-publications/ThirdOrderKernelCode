function [texStr,stimData] = GliderFilter(Q)

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

if isfield(p,'cSTDL')
    cSTDL = p.cSTDL;
else
    cSTDL = 0;
end

if isfield(p,'cSTDR')
    cSTDR = p.cSTDR;
else
    cSTDR = 0;
end

cL = cSTDL*randn+cL;
cR = cSTDR*randn+cR;

framesPerUp = p.framesPerUp;
sizeX = round(360/p.numDegX);
if p.numDegY == 0
    sizeY = 1;
else
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
end
maxDelayL = 0;
maxDelayR = 0;
checkForTwoEyes = 0;
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

%%%%% note this stimulus is designed so that the first correlation occurs
%%%%% on the first timepoint of a new epoch, but this does NOT work if
%%%%% there is an updateL difference between the two epochs

phiL = p.phiL;
phiR = p.phiR;

texStr.opts = 'full'; % see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

if Q.timing.framenumber == 1
    stimData = 2*(round(rand(sizeY,sizeX,maxDelayL+maxDelayR)))-1;
end

bitMap = zeros(sizeY,sizeX,framesPerUp);
hzFrame = Q.timing.framenumber*framesPerUp-(framesPerUp-1):Q.timing.framenumber*framesPerUp;
updateFrameL = mod(hzFrame-1,updateL) == 0;

for cc = 1:framesPerUp
    if updateFrameL(cc)
        try
            if delayL == 0
                stimData = cat(3,2*(round(rand(sizeY,sizeX,1)))-1,stimData(:,:,[1:maxDelayL-1 maxDelayL+1:maxDelayL+maxDelayR]));
            else
                stimData = cat(3,phiL*circshift(stimData(:,:,delayL),[dirYL,dirXL]),stimData(:,:,[1:maxDelayL-1 maxDelayL+1:maxDelayL+maxDelayR]));

                % generate new ends on the cylinder so that its always random
                stimData(:,[1:(dirXL*(dirXL>0)) (end+dirXL+1):(end*(dirXL<0))],1) = 2*(round(rand(sizeY,abs(dirXL),1)))-1;
                stimData([1:(dirYL*(dirYL>0)) (end+dirYL+1):(end*(dirYL<0))],:,1) = 2*(round(rand(abs(dirYL),sizeX,1)))-1;
            end
        catch err
            stimData = 2*(round(rand(sizeY,sizeX,maxDelayL+maxDelayR+1)))-1;
        end
    end
    
    bitMap(:,:,cc) = cL*stimData(:,:,1);
end

bitMap = (bitMap+1)/2;

if p.twoEyes
    rightEye = zeros(sizeY,sizeX,framesPerUp);
    updateFrameR = mod(hzFrame-1,updateR) == 0;
    
    for cc = 1:framesPerUp
        if updateFrameR(cc)
            try
                if delayR == 0
                    stimData = cat(3,stimData(:,:,1:maxDelayL),2*(round(rand(sizeY,sizeX,1)))-1,stimData(:,:,maxDelayL+1:maxDelayL+maxDelayR-1));
                else
                    stimData = cat(3,stimData(:,:,1:maxDelayL),phiR*circshift(stimData(:,:,maxDelayL+delayR),[dirYR,dirXR]),stimData(:,:,maxDelayL+1:maxDelayL+maxDelayR-1));

                    % generate new ends on the cylinder so that its always random
                    stimData(:,[1:(dirXR*(dirXR>0)) (end+dirXR+1):(end*(dirXR<0))],maxDelayL+1) = 2*(round(rand(sizeY,abs(dirXR),1)))-1;
                    stimData([1:(dirYR*(dirYR>0)) (end+dirYR+1):(end*(dirYR<0))],:,maxDelayL+1) = 2*(round(rand(abs(dirYR),sizeX,1)))-1;
                end
            
            catch err
                stimData = 2*(round(rand(sizeY,sizeX,maxDelayL+maxDelayR+1)))-1;
            end
        end
    

        rightEye(:,:,cc) = cR*stimData(:,:,maxDelayL+1);
    end
    
    rightEye = (rightEye+1)/2;
    
    bitMap = twoEyes(bitMap,rightEye,p,f);
end
 
% stimData(11) = min(bitMap(:));
% stimData(12) = max(bitMap(:));
% stimData(13) = mean(bitMap(:));
% stimData(14) = std(bitMap(:));
% stimData(15:20) = bitMap(1,1:6,1);

if Q.stims.xtPlot
    %bitMapPrint = min([10 size(bitMap,2)]);
    write_xtPlot(bitMap(1,:,:),Q);
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
