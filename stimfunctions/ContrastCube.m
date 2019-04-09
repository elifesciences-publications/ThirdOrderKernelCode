function [texStr,stimData] = ContrastCube(Q)

% Newsome Dot stimulus. A dot born in frame A appears in frame A and frame
% A+ deltaT, translated by deltaX, deltaY and with a new contrast value determined
% by Hi, Lo, and increment.

sii = Q.stims.currStimNum;
p = Q.stims.currParam; % this is what we've got to work with in terms of parameters for this stimulus
f = Q.timing.framenumber - Q.timing.framelastchange + 1; % relative frame number
stimData = Q.stims.stimData;
floc = Q.flyloc; % could potentially use this to update the stimulus as well

texStr.opts = 'full'; % or 'rightleft','rightleftfront', etc. see drawTexture for deets
texStr.dim = 2; % or 2
texStr.scale = [1 1 1]; % using the different lengthscales appropriately.

%% input parameters

dotWd = p.dotWd;
dotHt = p.dotHt;

framesPerUp = p.framesPerUp;
updateRate = p.updateRate;
density = p.density;

deltaT = p.deltaT;
deltaX = p.deltaX; % negative numbers --> leftward velocity
deltaY = p.deltaY; % negative numbers --> upward velocity

tauBack = p.tauBack;
cubeVal = p.cubeVal;
spaceBorder = p.spaceBorder;

mLum = p.mLum; % out of 1
val = p.val;
dotsPol = p.dotsPol;
dotsCorr = p.dotsCorr;

%% derived parameters

frameSpan = 60 * framesPerUp/updateRate;

btmpWd = floor(360/dotWd);
btmpHt = floor(2/tand(dotHt));
numPix = btmpWd * btmpHt; 

population = ceil(btmpWd*btmpHt*density/2);
act_pop = round(population*(1-(1-1/numPix)^population));

% The probability that a background pixel overlaps with another background
% pixel or a shadow pixel. Every such overlap results in the loss of TWO
% background-contrast dots. Necessary for contrast scaling. 

%% adjust bg

% adjust the background scaling to account for the effect of the background
% population. Not adjusting for the shadow population because this is
% evenly balanced by the dots population.
if isfield(p,'correctBg')
    if p.correctBg
        mLum = (numPix*mLum - 2*forPop * forVal - 2*bgPop * bgVal) / ...
            ( numPix - 2*(forPop + bgPop) );
    end
end

%% initialize dot matrix

% dim 1: dot identity
% dim 2: x, y, val
% dim 3: intercalated populations

if f == 1
    stimData.frameAge = 0;
    if isfield(stimData,'dots')
        stimData = rmfield(stimData,{'dots'});
    end
    % random initialization
    stimData.dots(:,1,:) = ceil(rand(population,1,deltaT+1+tauBack)*btmpWd);
    stimData.dots(:,2,:) = ceil(rand(population,1,deltaT+1+tauBack)*btmpHt);
    if ~dotsPol
        stimData.dots(:,3,:) = randn(population,1,deltaT+1+tauBack) > 0;
    else
        stimData.dots(:,3,:) = dotsPol;
    end
end

%% Cycle through flips

for qq = 1:framesPerUp
    if stimData.frameAge == 0

        % roll everything back by a frame
        stimData.dots(:,:,2:end) = stimData.dots(:,:,1:end-1);
         % generate new "now" populations
        stimData.dots(:,1,1) = ceil(rand(population,1,1)*btmpWd);
        stimData.dots(:,2,1) = ceil(rand(population,1,1)*btmpHt);
         % Assign polarities
        if ~dotsPol
            stimData.dots(:,3,1) = sign(randn(population,1,1));
        else
            stimData.dots(:,3,1) = dotsPol;
        end
        
        %% draw the bitmap

        % Along the third dimension, display the first and 1+deltaT'th slice. 
        preMap = zeros(btmpHt+2*abs(deltaY)+2*spaceBorder,btmpWd+2*abs(deltaX)+2*spaceBorder);
        
        for ww = 1:1+deltaT+tauBack
            for zz = 1:population
                xr = stimData.dots(zz,1,ww);
                yr = stimData.dots(zz,2,ww);
                preMap(yr+abs(deltaY)+spaceBorder:yr+abs(deltaY)+spaceBorder+deltaY,...
                    xr+abs(deltaX)+spaceBorder:xr+abs(deltaX)+spaceBorder+deltaX) = cubeVal;
            end
        end
        
        for ww = [1+tauBack 1+deltaT+tauBack]                   
            if ~dotsCorr
                dotsShiftX = ( ww == 1+deltaT+tauBack )*sign(randn);
                dotsShiftY = ( ww == 1+deltaT+tauBack )*sign(randn);
            else
                dotsShiftX = ( ww == 1+deltaT+tauBack );
                dotsShiftY = ( ww == 1+deltaT+tauBack );
            end
            
            for zz = 1:population   
                % dot location shifts
                xf = stimData.dots(zz,1,ww) + deltaX*dotsShiftX;
                yf = stimData.dots(zz,2,ww) + deltaY*dotsShiftY; 
                pf = stimData.dots(zz,3,ww);
                % dot itself
                preMap(yf+abs(deltaY)+spaceBorder,xf+abs(deltaX)+spaceBorder) = pf; % want bitMap to range from 0 to 1
            end            
        end
        preMap = mLum * (preMap * val + 1);   
        stimData.preMap = preMap;
        
    end    
    bitMap(:,:,qq) = stimData.preMap((1+abs(deltaY)):(btmpHt+abs(deltaY)),...
        (1+abs(deltaX)):(btmpWd+abs(deltaX)));
    
    stimData.frameAge = mod(stimData.frameAge+1,frameSpan);
end
    
stimData.mat(1) = mean(bitMap(:)); % To make sure compensating correctly
texStr.tex = CreateTexture(bitMap,Q);
% 
% if f == 30
%     keyboard
% end

end