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

%%%%%%%%%%%%%% Positive Dt is defined as going forward in time
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
    if ~isfield(stimData,'glidMem') || (sizeY ~= size(stimData.glidMem,1)) || (sizeX ~= size(stimData.glidMem,2)) || (lastContrast==0)
        for ii = 1:size(Q.stims.params,2)
            thisEpochMaxDelay = max([Q.stims.params(ii).dt 0]-min([Q.stims.params(ii).dt 0]));
            
            if thisEpochMaxDelay > maxDelay
                maxDelay = thisEpochMaxDelay;
            end
        end
        
        stimData.glidMem = 2*(round(rand(sizeY,sizeX,maxDelay+1)))-1;
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
            stimData.glidMem = cat(3,ones(sizeY,sizeX),stimData.glidMem(:,:,1:end-1));

            % generate the left right top and bottom buffers where we can't
            % define the gliders
            stimData.glidMem((1:topBuffer),:,1) = 2*round(rand(topBuffer,sizeX))-1;
            stimData.glidMem((end-bottomBuffer+1):end,:,1) = 2*round(rand(bottomBuffer,sizeX))-1;
            stimData.glidMem(:,1:leftBuffer,1) = 2*round(rand(sizeY,leftBuffer))-1;
            stimData.glidMem(:,(end-rightBuffer+1):end,1) = 2*round(rand(sizeY,rightBuffer))-1;

            if ~isempty(dt)
                for yy = (topBuffer+1):(sizeY-bottomBuffer)
                    for xx = (leftBuffer+1):(sizeX-rightBuffer)
                        for ct = 1:length(dt)
                            stimData.glidMem(yy,xx,1) = stimData.glidMem(yy,xx,1).*stimData.glidMem(yy+dy(ct),xx+dx(ct),-dt(ct)+1);
                        end

                        % since parity is 1 or -1 and all the values in our glider are
                        % 1 or -1 this division could be a multiplication. However, in
                        % principle if you used a non binary image you would divide
                        % instead of multiply so I'll keep it here
                        stimData.glidMem(yy,xx,1) = parity./stimData.glidMem(yy,xx,1);
                    end
                end
            else
                stimData.glidMem(:,:,1) = 2*round(rand(sizeY,sizeX))-1;
            end
        end
    else
        if framesPerUp >= 12
            stimData.glidMem(:,:,1) = (-ones(sizeY,sizeX)).^hzFrame(cc);
            c = 1;
        end
    end
    
    bitMap(:,:,cc) = c*stimData.glidMem(:,:,1);
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
