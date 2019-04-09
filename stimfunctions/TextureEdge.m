function [texStr,stimData] = TextureEdge(Q)
% A moving edge between two textured regions

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% input parameters

glid1 = p.glid1;
glid2 = p.glid2;
pol1 = p.pol1;
pol2 = p.pol2;
wid1 = p.wid1; % in pixels
wid2 = p.wid2; % in pixels

framesPerUp = p.framesPerUp;
updateRate = p.updateRate;
    lifespan = 60 * framesPerUp / updateRate;
    % flips per stimulus update
pixX = p.pixX; % in degrees
pixY = p.pixY; % in degrees

diagDirec1 = p.diagDirec1; % 1: right
diagDirec2 = p.diagDirec2; % 1: right

contrast = p.contrast;
mLum = p.mLum;
edgeVel = p.edgeVel;

%% derived parameters

btmpWd = floor(360/pixX);
btmpHt = floor(2/tand(pixY));
cycleWd = wid1 + wid2;
% edgeVel = abs(edgeVel);
ceilCycles = ceil(btmpWd/cycleWd);
fullWd = ceilCycles*cycleWd;

% generate tMap - mapping from frame number (mod upsPerCycle) to position
if edgeVel == 0
    upsPerCycle = 1;
    tMap = zeros(1,upsPerCycle);
else
    upsPerCycle = abs(round(cycleWd*pixX/edgeVel*updateRate));
    tMap = linspace(0,cycleWd-cycleWd/upsPerCycle,upsPerCycle);
end

%% first flip initialization

if f == 0
    stimData.t = floor(rand*upsPerCycle); % determine where to start in cycle randomly
    stimData.age = 0;
end

%% Loop over frames in bitMap

for zz = 1:framesPerUp   
    if stimData.age == 0          
        
        %% generate each glider map        
        gliders = {'glid1','glid2'};
        
        %% select glider type
        for qq = 1:2                         
            di2 = 0; dj2 = 0;
            evalc(['thisGlider = ' sprintf('%s',gliders{qq})]);
            evalc(['pol = ' sprintf('pol%i',qq) ';']);
            switch thisGlider
                case 1 % div 3
                    dj1 = 1;
                    dj2 = 1;
                    di1 = 1;
                    di2 = 0;
                    glidOrder = 3;
                case 2 % con 3
                    dj1 = 1;
                    dj2 = 0;
                    di1 = 1;
                    di2 = 1;
                    glidOrder = 3;
                case 3 % R 2
                    dj1 = 1;
                    di1 = 1;
                    glidOrder = 2;
                case 4 % elbow
                    dj1 = 1;
                    dj2 = 0;
                    di1 = 1;
                    di2 = 2;
                    glidOrder = 3;
                case 5 % late knight
                    dj1 = 1;
                    dj2 = 1;
                    di1 = 1;
                    di2 = 2;
                    glidOrder = 3;
                case 6 % early knight
                    dj1 = 0;
                    dj2 = 1;
                    di1 = 1;
                    di2 = 2;
                    glidOrder = 3;
            end
            
            maxDispI = max([di1 di2]);
            maxDispJ = max([dj1 dj2]);
        
            %% loop over bitmap

            % generate seed
            preSlice = 0;
            while(any(preSlice(:) == 0)) % probably unnecessary, but there is 
                                         % /a/ chance that this method of
                                         % generating +/- 1 would generate a
                                         % zero, so preventing that here
                preSlice = randn(btmpHt + maxDispI, btmpWd + maxDispJ);
                preSlice = sign(preSlice);
            end

            % loop through pixels
            if glidOrder == 2
                for ii=maxDispI+1:btmpHt+maxDispI; 
                    for jj = maxDispJ+1:btmpWd+maxDispJ;
                        preSlice(ii,jj) = pol * preSlice(ii-di1,jj-dj1); 
                    end
                end            
            elseif glidOrder == 3
                for ii=maxDispI+1:btmpHt+maxDispI; 
                    for jj = maxDispJ+1:btmpWd+maxDispJ;
                        preSlice(ii,jj) = pol * preSlice(ii-di1,jj-dj1) * preSlice(ii-di2,jj-dj2); 
                    end
                end             
            end 
            
            % save preSlice
            evalc(['thisDiagDirec = ' sprintf('diagDirec%i',qq) ';']);
            bothGlids(:,:,qq) = preSlice(maxDispI+1:end,maxDispJ+1:end);
            if thisDiagDirec == -1
                bothGlids(:,:,qq) = fliplr(bothGlids(:,:,qq));
            end
            
        end
            
        %% Overlay the two bitmaps 
        
        core = [ones(1,wid1) zeros(1,wid2)];
        startMask = floor(tMap(stimData.t+1));
        
        if edgeVel > 0
            rotCore = [ zeros(fullWd-startMask,startMask) eye(fullWd-startMask);...
                eye(startMask) zeros(startMask,fullWd-startMask) ];
        else
            rotCore = [ zeros(fullWd-startMask,startMask) eye(fullWd-startMask);...
                eye(startMask) zeros(startMask,fullWd-startMask) ]';
        end 
        
        coreMap = repmat(core,btmpHt,ceilCycles);
        coreMap = coreMap * rotCore;
        coreMap = coreMap(:,1:btmpWd); 
        stimData.preMap = bothGlids(:,:,1) .* coreMap + bothGlids(:,:,2) .* (1 - coreMap);       
         
        % step forward in time
        stimData.t = mod(stimData.t+1,upsPerCycle);
    end
    
    % generate bitmap and update age every frame
    bitMap(:,:,zz) = mLum * ( 1 + contrast * stimData.preMap);
    stimData.age = mod(stimData.age+1,lifespan);
end

%always include this line in a stim function to make the texture from the
%bitmap
texStr.tex = CreateTexture(bitMap,Q);
end