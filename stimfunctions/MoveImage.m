function [texStr,stimData] = MoveImage(Q)

% this is to provide the general structure for the texture generating codes
% to be used with PTB in this framework. 

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
c = p.cL;
velH = p.velHL;
velV = p.velVL;
framesPerUp = p.framesPerUp;
mlum = p.mlumL;
resX = p.resX;
resY = p.resY;

texStr.opts = 'full'; % see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

% Size of the elements of the random pattern
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


% Resolution of the rendering and shifts in degrees per pixel
if resX == 0
    imSizeX = 1;
    resX = inf;
else
    imSizeX = round(360/p.resX);
end

if resY == 0
    imSizeY = 1;
    resY = inf;
else
    imSizeY = round(2/tan(p.resY*pi/180));
end


%%%%% note this stimulus is designed so that the first correlation occurs
%%%%% on the first timepoint of a new epoch, but this does NOT work if
%%%%% there is an updateL difference between the two epochs
if f == 1
    % make a random bitmap and upsample it so that it has a resolution of
    % resX by resY (in degrees per pixel)
    switch p.imageType
        case 1 %Trinary Bars
            stimData.pic = imresize(2*round(rand(sizeY,sizeX))-1,[imSizeY imSizeX],'nearest');
        case 2 %Binary Bars
            stimData.pic = imresize(randn(sizeY,sizeX),[imSizeY imSizeX],'nearest');
    end
    % save the image position horizontally and vertically
    stimData.posHV = zeros(2,1);
end

bitMap = zeros(imSizeY,imSizeX,framesPerUp,1,1,1);

for cc = 1:framesPerUp
    stimData.posHV(1) = stimData.posHV(1) + velH/(60*framesPerUp);
    stimData.posHV(2) = stimData.posHV(2) + velV/(60*framesPerUp);

    dirX = round(stimData.posHV(1)/resX);
    dirY = round(stimData.posHV(2)/resY);
    
    bitMap(:,:,cc) = circshift(stimData.pic,[dirY,dirX]);
end


bitMap = mlum*(1 + c*bitMap);
if p.twoEyes % Mirror on right eye
    rightEye = bitMap(:,end:-1:1,:);
    
    bitMap = CombEyes(bitMap,rightEye,p,f);
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
