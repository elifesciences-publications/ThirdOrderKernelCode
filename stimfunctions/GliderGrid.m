function [texStr,stimData] = GliderGrid(Q)

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
gridType = p.gridType;
framesPerUp = p.framesPerUp;
sizeX = round(360/p.numDegX);
if p.numDegY == 0
    sizeY = 1;
else
    sizeY = round(Q.cylinder.cylinderHeight/(Q.cylinder.cylinderRadius*tan(p.numDegY*pi/180)));
end

stimSizeX = round(360/p.stimSizeX);
if p.stimSizeY == 0
    stimSizeY = 1;
else
    stimSizeY = round(2/tan(p.stimSizeY*pi/180));
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
    stimData.mat = 2*(round(rand(stimSizeY,stimSizeX,maxDelayL+maxDelayR)))-1;
    stimData.mem = zeros(1,2,1);
end

bitMap = zeros(sizeY,sizeX,framesPerUp);
hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
updateFrameL = mod(hzFrame-1,updateL) == 0;


for cc = 1:framesPerUp
    if updateFrameL(cc)
        try
            if delayL == 0
                stimData.mat = cat(3,2*(round(rand(stimSizeY,stimSizeX,1)))-1,stimData.mat(:,:,[1:maxDelayL-1 maxDelayL+1:maxDelayL+maxDelayR]));
            else
                stimData.mat = cat(3,phiL*circshift(stimData.mat(:,:,delayL),[dirYL,dirXL]),stimData.mat(:,:,[1:maxDelayL-1 maxDelayL+1:maxDelayL+maxDelayR]));

                % generate new ends on the cylinder so that its always random
                stimData.mat(:,[1:(dirXL*(dirXL>0)) (end+dirXL+1):(end*(dirXL<0))],1) = 2*(round(rand(stimSizeY,abs(dirXL),1)))-1;
                stimData.mat([1:(dirYL*(dirYL>0)) (end+dirYL+1):(end*(dirYL<0))],:,1) = 2*(round(rand(abs(dirYL),stimSizeX,1)))-1;
            end
        catch err
            stimData.mat = 2*(round(rand(stimSizeY,stimSizeX,maxDelayL+maxDelayR+1)))-1;
        end
    end
    
    sizeDiffX = round(sizeX/stimSizeX);
    sizeDiffY = round(sizeY/stimSizeY);
    newStim = zeros(sizeY,sizeX);
    
    for ii = 1:stimSizeX;
        for jj = 1:stimSizeY;
            newStim(sizeDiffY*jj-sizeDiffY+1:sizeDiffY*jj,sizeDiffX*ii-sizeDiffX+1:sizeDiffX*ii) = stimData.mat(jj,ii,1);
        end
    end
    bitMap(:,:,cc) = cL*newStim(:,:);
end

switch gridType
    case 0
        gridUnit = 1;
    case 1
        gridUnit = [1 0; 0 0];
    case 2
        gridUnit = [1 1 0; 0 0 0];
    case 3
        gridUnit = [1 0; 1 0; 0 0];
    case 4
        gridUnit = [1; 0];
    case 5
        gridUnit = [1 0];
    case 6
        gridUnit = [1 1 0 0; 0 0 0 0];
    case 7
        gridUnit = [1; 0; 0; 0];
    case 8
        gridUnit = [1 1 1 1 0 0 0 0; 0 0 0 0 0 0 0 0];
    case 9
        gridUnit = [1 1 0 0];
    case 10
        gridUnit = [1; 1; 0; 0;];
    case 11
        gridUnit = [1 0 0 0];
    case 12
        gridUnit = [1 0 0];
    case 13
        gridUnit = [1 -1 0 0];
    case 14
        gridUnit = [1 1 0 0 0 0];
    case 15
        gridUnit = [1 1 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
    case 16
        gridUnit = [1 0 0 1 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0];
    case 17
        gridUnit = [1; 0; 0];
    case 18
        gridUnit = [1 1 0 0 0];
    case 19
        gridUnit = [1 0 1 0 0 0];
    case 20
        gridUnit = [1 0 0 1 0 0 0];
end

gridMat = repmat(gridUnit,[ceil(sizeY/size(gridUnit,1)) ceil(sizeX/size(gridUnit,2)) framesPerUp]);

gridMat = gridMat(1:end-mod(size(gridUnit,1)-mod(sizeY,size(gridUnit,1)),size(gridUnit,1)),:,:);
gridMat = gridMat(:,1:end-mod(size(gridUnit,2)-mod(sizeX,size(gridUnit,2)),size(gridUnit,2)),:);

bitMap = bitMap.*gridMat;

bitMap = (bitMap+1)/2;

if f == 1
    stimData.mem(1,1) = floor(size(gridUnit,2)*rand);
    stimData.mem(1,2) = floor(size(gridUnit,1)*rand);
end

% make sure the stim appears in random places
bitMap = circshift(bitMap,[stimData.mem(1,2) stimData.mem(1,1)]);

if p.twoEyes
    rightEye = zeros(sizeY,sizeX,framesPerUp);
    updateFrameR = mod(hzFrame-1,updateR) == 0;
    
    for cc = 1:framesPerUp
        if updateFrameR(cc)
            try
                if delayR == 0
                    stimData.mat = cat(3,stimData.mat(:,:,1:maxDelayL),2*(round(rand(sizeY,sizeX,1)))-1,stimData.mat(:,:,maxDelayL+1:maxDelayL+maxDelayR-1));
                else
                    stimData.mat = cat(3,stimData.mat(:,:,1:maxDelayL),phiR*circshift(stimData.mat(:,:,maxDelayL+delayR),[dirYR,dirXR]),stimData.mat(:,:,maxDelayL+1:maxDelayL+maxDelayR-1));

                    % generate new ends on the cylinder so that its always random
                    stimData.mat(:,[1:(dirXR*(dirXR>0)) (end+dirXR+1):(end*(dirXR<0))],maxDelayL+1) = 2*(round(rand(sizeY,abs(dirXR),1)))-1;
                    stimData.mat([1:(dirYR*(dirYR>0)) (end+dirYR+1):(end*(dirYR<0))],:,maxDelayL+1) = 2*(round(rand(abs(dirYR),sizeX,1)))-1;
                end
            
            catch err
                stimData.mat = 2*(round(rand(sizeY,sizeX,maxDelayL+maxDelayR+1)))-1;
            end
        end
    

        rightEye(:,:,cc) = cR*stimData.mat(:,:,maxDelayL+1);
    end
    
    rightEye = (rightEye+1)/2;
    
    bitMap = CombEyes(bitMap,rightEye,p,f);
end
 
% stimData.mat(11) = min(bitMap(:));
% stimData.mat(12) = max(bitMap(:));
% stimData.mat(13) = mean(bitMap(:));
% stimData.mat(14) = std(bitMap(:));
% stimData.mat(15:20) = bitMap(1,1:6,1);

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
