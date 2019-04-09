function [texStr,stimData] = GliderArbitraryMirrored(Q)

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number

stimData = Q.stims.stimData;

update = round((60*p.framesPerUp)/p.updateRate);

if mod((60*p.framesPerUp)/p.updateRate,1)~=0
    error('update rate requested is not a factor of projector dispaly rate. Rounding and continuing');
end
    
dt = p.dt;
dx = p.dx; %direction and amplitude of the motion
dy = p.dy;

if length(dx)~=length(dt) || length(dy)~=length(dt)
    error('dt/dx/dy vectors must be same size');
end

%%%%%%%%%%%%%% Positive Dt is defined as going backward in time so a dt=1
%%%%%%%%%%%%%% is a delay of 1 frame backward
%%%%%%%%%%%%%% positive x is to the right, positive y is up

% add in the implicit 0 point
fullDt = [dt 0];
fullDx = [dx 0];
fullDy = [dy 0];

fullDt = fullDt - max(fullDt);

% find dt's which equal 0
dtMinLoc = fullDt==0;

% find the new zero point which is the largest dx value which is also dt=0
% find dx's which equal max dx
dxMaxLoc = fullDx==max(fullDx(dtMinLoc));

newReferencePoint = dxMaxLoc & dtMinLoc;

dyMaxLoc = fullDy==max(fullDy(newReferencePoint));

newReferencePoint = newReferencePoint & dyMaxLoc;

% subtract off dx and dy's so that the dx and dy at the reference point is 0
fullDx = fullDx - fullDx(newReferencePoint);
fullDy = fullDy - fullDy(newReferencePoint);

dt = fullDt(~newReferencePoint);
dx = fullDx(~newReferencePoint);
dy = fullDy(~newReferencePoint);

c = p.c;
framesPerUp = p.framesPerUp;

parity = p.parity;

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

%%%%% note this stimulus is designed so that the first correlation occurs
%%%%% on the first timepoint of a new epoch, but this does NOT work if
%%%%% there is an update difference between the two epochs
if ~isfield(stimData,'lastContrast');
    stimData.lastContrast = 0;
end

lastContrast = stimData.lastContrast;

if f == 1
    if ~isfield(stimData,'glidMem') || (sizeY ~= size(stimData.scintMem,1)) || (sizeX ~= size(stimData.scintMem,2)) || (lastContrast==0)
        for ii = 1:size(Q.stims.params,2)
            thisEpochMaxDelay = max([Q.stims.params(ii).dt 0]-min([Q.stims.params(ii).dt 0]));
            
            if thisEpochMaxDelay > maxDelay
                maxDelay = thisEpochMaxDelay;
            end
        end
        
        stimData.scintMem = 2*(round(rand(sizeY,sizeX,maxDelay+1)))-1;
        stimData.thisFrame = zeros(sizeY,sizeX);
    end
end

% left buffer is the absolute value of the minimum of dx so long as that
% minimum is negative
leftBuffer = abs(min(fullDx));
rightBuffer = max(fullDx);

topBuffer = abs(min(fullDy));
bottomBuffer = max(fullDy);

bitMap = zeros(sizeY,sizeX,framesPerUp);

hzFrame = f*framesPerUp-(framesPerUp-1):f*framesPerUp;
updateFrame = mod(hzFrame-1,update) == 0;

for cc = 1:framesPerUp
    c = p.c;
    
    if c~=0
        if updateFrame(cc)
            stimData.thisFrame = zeros(sizeY,sizeX);
            stimData.scintMem = cat(3,2*round(rand(sizeY,sizeX))-1,stimData.scintMem(:,:,1:end-1));

            if ~isempty(dt)
                multVals = ones(sizeY,sizeX);

                % structure of scintillator is seed + product across dtdxdy circshift(seed,[dy dx dt])
                for ct = 1:length(dt)
                    multVals = multVals.*circshift(stimData.scintMem(:,:,-dt(ct)+1),[dy(ct) -dx(ct)]);
                end

                % since parity is 1 or -1 and all the values in our glider are
                % 1 or -1 this division could be a multiplication. However, in
                % principle if you used a non binary image you would divide
                % instead of multiply so I'll keep it here
                stimData.thisFrame = parity./multVals+stimData.scintMem(:,:,1);
            else
                stimData.thisFrame = stimData.scintMem(:,:,1) + 2*round(rand(sizeY,sizeX))-1; 
            end
        end
    else
        % this is a way to make the stimulus appear middle gray even at
        % very low bit depths. Simply alternate every frame between white
        % and black
        if framesPerUp >= 12
            stimData.thisFrame = (-ones(sizeY,sizeX)).^hzFrame(cc);
            c = 1;
        end
    end
    
    bitMap(:,:,cc) = c*stimData.thisFrame(:,:,1);
end

bitMap = 0.5*(bitMap+1);

if p.twoEyes
    rightEye = fliplr(bitMap);

    bitMap = CombEyes(bitMap,rightEye,p,f);
end

if f == p.duration
    stimData.lastContrast = p.c;
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
